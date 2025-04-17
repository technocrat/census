# SPDX-License-Identifier: MIT

using GeoMakie
using CairoMakie
using GeoInterface
using LibGEOS
using WellKnownGeometry
using ArchGDAL
using GeometryBasics: Point2f, Polygon
using DataFrames: DataFrame, nrow
using LibPQ

# Remove circular import
# import ..Census: map_poly

# Import CensusDB module correctly
import ..Census.CensusDB: get_connection, return_connection, execute

"""
    get_geo_pop(target_states::Vector{String}) -> DataFrame

Get population data for specified states with geographic information.

# Arguments
- `target_states::Vector{String}`: Vector of state postal codes

# Returns
- `DataFrame`: Population and geographic data for the specified states

# Data Processing
- Queries the census.counties and census.variable_data tables
- Filters by specified state postal codes
- Includes geographic information (geom) and population data

# Example
```julia
df = get_geo_pop(["CA", "OR", "WA"])
```
"""
function get_geo_pop(target_states::Vector{String})
    # Connect to database using CensusDB.get_connection()
    conn = get_connection()
    
    geo_query = """
        SELECT q.geoid, q.stusps, q.name, q.nation, ST_AsText(q.geom) as geom, vd.value as pop
        FROM census.counties q
        LEFT JOIN census.variable_data vd
            ON q.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        WHERE q.stusps = ANY(\$1)
        ORDER BY q.geoid;
    """
    
    result = execute(conn, geo_query, [target_states])
    
    # Process the result
    df = DataFrame(result)
    
    # Return the connection to the pool
    return_connection(conn)
    
    return df
end

# Add method for PostalCode vector
function get_geo_pop(target_states::Vector{PostalCode})
    return get_geo_pop([pc.code for pc in target_states])
end

"""
    parse_geoms(geoms::Union{DataFrame, Vector{Union{Missing, String}}}) -> Vector{Union{Missing, ArchGDAL.IGeometry}}

Parse WKT (Well-Known Text) geometry strings into ArchGDAL geometry objects.

# Arguments
- `geoms`: Either:
  - `DataFrame`: DataFrame with a 'geom' column containing WKT strings
  - `Vector{Union{Missing, String}}`: Vector of WKT strings, possibly with missing values

# Returns
- `Vector{Union{Missing, ArchGDAL.IGeometry}}`: Vector of parsed geometries where:
  - Successfully parsed geometries are ArchGDAL.IGeometry objects
  - Failed parses or missing inputs remain as missing

# Example
```julia
# Parse from vector
wkt = ["POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))", "POINT (30 10)"]
geoms = parse_geoms(wkt)

# Parse from DataFrame
df = DataFrame(geom = wkt)
geoms = parse_geoms(df)
```

# Notes
- Handles missing values gracefully
- Logs warnings for failed parses (limited to 5 warnings)
- Common with data from get_geo_pop() and similar functions
- Uses ArchGDAL.fromWKT for parsing
"""
function parse_geoms(geoms::Union{DataFrame, Vector{Union{Missing, String}}})
    # If input is a DataFrame, get the geom column
    if geoms isa DataFrame
        geoms = geoms.geom
    end
    
    parsed = Vector{Union{Missing, ArchGDAL.IGeometry}}(missing, length(geoms))
    for (i, geom) in enumerate(geoms)
        if !ismissing(geom)
            try
                parsed[i] = ArchGDAL.fromWKT(geom)
            catch e
                @warn "Failed to parse geometry at index $i: $e\nWKT: $geom" maxlog=5
                parsed[i] = missing
            end
        end
    end
    return parsed
end

"""
    convert_to_polygon(geom::ArchGDAL.IGeometry) -> GeometryBasics.Polygon

Convert an ArchGDAL geometry to a GeometryBasics.Polygon for visualization.

# Arguments
- `geom::ArchGDAL.IGeometry`: Input geometry from ArchGDAL

# Returns
- `GeometryBasics.Polygon`: A 2D polygon suitable for plotting with Makie

# Supported Geometry Types
- `wkbPolygon`: Simple polygon
- `wkbMultiPolygon`: Takes first polygon from collection
- `wkbUnknown`: Attempts to treat as polygon

# Example
```julia
# Convert WKT to GeometryBasics.Polygon
wkt = "POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"
geom = ArchGDAL.fromWKT(wkt)
poly = convert_to_polygon(geom)
```

# Notes
- For MultiPolygons, only converts the first polygon
- Extracts exterior ring only (ignores holes)
- Converts coordinates to Point2f for Makie compatibility
- Throws error for unsupported geometry types
"""
function convert_to_polygon(geom::ArchGDAL.IGeometry)
    geomtype = ArchGDAL.getgeomtype(geom)
    if geomtype == ArchGDAL.wkbMultiPolygon
        # For MultiPolygon, take the first polygon
        return convert_to_polygon(ArchGDAL.getgeom(geom, 1))
    elseif geomtype == ArchGDAL.wkbPolygon || geomtype == ArchGDAL.wkbUnknown
        # For Polygon or Unknown, try to get the exterior ring
        try
            ring = ArchGDAL.getgeom(geom, 1)  # First ring is exterior
            points = [ArchGDAL.getpoint(ring, i) for i in 1:ArchGDAL.ngeom(ring)]
            # Convert points to GeometryBasics.Point2f
            points = [GeometryBasics.Point2f(ArchGDAL.getx(p), ArchGDAL.gety(p)) for p in points]
            return GeometryBasics.Polygon(points)
        catch e
            error("Failed to convert geometry to polygon: $e")
        end
    else
        error("Unsupported geometry type: $geomtype")
    end
end

function geo_plot(data::DataFrame;
                 lon_col::Symbol=:longitude,
                 lat_col::Symbol=:latitude,
                 value_col::Symbol=:value,
                 title::String="Geographic Distribution",
                 colormap=:viridis)
    
    fig = CairoMakie.Figure(size=DEFAULT_PLOT_SIZE)
    
    # Create the map axis
    ga = GeoMakie.GeoAxis(
        fig[1,1],
        title = title,
        dest = GeoMakie.WGS84(),
        coastlines = true
    )
    
    # Plot the points
    GeoMakie.scatter!(ga, 
        data[:, lon_col], 
        data[:, lat_col],
        color = data[:, value_col],
        colormap = colormap,
        markersize = 10
    )
    
    # Add a colorbar
    CairoMakie.Colorbar(fig[1,2], 
        colormap = colormap,
        label = string(value_col),
        width = 20,
        height = Relative(0.5)
    )
    
    return fig
end

function get_geoids_by_query(query::String)
    # Use get_connection() instead of get_db_connection()
    conn = get_connection()
    try
        result = execute(conn, query)
        return DataFrame(result).geoid
    finally
        # Return the connection to the pool
        return_connection(conn)
    end
end

"""
    get_centroid_longitude_range_geoids(min_long::Float64, max_long::Float64) -> Vector{String}

Returns GEOIDs for counties with centroids between the specified longitude range.
Longitude values should be in decimal degrees, with negative values for western hemisphere.

# Arguments
- `min_long::Float64`: Minimum longitude (western boundary)
- `max_long::Float64`: Maximum longitude (eastern boundary)

# Returns
- `Vector{String}`: Vector of county GEOIDs within the specified longitude range

# Example
```julia
# Get counties between -110°W and -115°W
geoids = get_centroid_longitude_range_geoids(-115.0, -110.0)
```
"""
function get_centroid_longitude_range_geoids(min_long::Float64, max_long::Float64)
    conn = get_connection()
    try
        query = """
        SELECT geoid 
        FROM census.counties 
        WHERE ST_X(ST_Centroid(geom)) BETWEEN $min_long AND $max_long
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return DataFrame(result).geoid
    finally
        return_connection(conn)
    end
end

"""
    get_110w_to_115w_geoids() -> Vector{String}

Returns GEOIDs for counties with centroids between -110°W and -115°W longitude.

# Returns
- `Vector{String}`: Vector of county GEOIDs within the specified longitude range
"""
function get_110w_to_115w_geoids()
    return get_centroid_longitude_range_geoids(-115.0, -110.0)
end

# Export all public functions
export get_geo_pop,
       parse_geoms,
       convert_to_polygon,
       geo_plot,
       get_geoids_by_query,
       get_centroid_longitude_range_geoids,
       get_110w_to_115w_geoids 