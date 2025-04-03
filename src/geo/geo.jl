# SPDX-License-Identifier: MIT

using GeoMakie
using CairoMakie
using GeoInterface
using LibGEOS
using WellKnownGeometry

"""
    get_geo_pop(target_states::Vector{String}) -> DataFrame

Retrieve geographic and population data for counties in specified states.

# Arguments
- `target_states::Vector{String}`: Vector of state postal codes (e.g., ["CA", "OR", "WA"])

# Returns
- `DataFrame`: A DataFrame containing:
  - `geoid::String`: Geographic identifier for each county
  - `stusps::String`: State postal code
  - `name::String`: County name
  - `geom::String`: County geometry in WKT (Well-Known Text) format
  - `total_population::Int`: Total population of the county

# Database Details
- Connects to PostgreSQL database named "geocoder"
- Queries the census.counties and census.variable_data tables
- Uses PostGIS for geometry operations

# Example
```julia
# Get geographic data for Pacific states
states = ["WA", "OR", "CA"]
df = get_geo_pop(states)
```

# Notes
- Requires LibPQ for database connection
- Returns WKT format geometries (use parse_geoms to convert to ArchGDAL geometries)
- Closes database connection after query
"""
function get_geo_pop(target_states::Vector{String})
    # Connect to database
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Prepare the query with parameter placeholder
    geo_query = """
        SELECT q.geoid, q.stusps, q.name, ST_AsText(q.geom) as geom, vd.value as total_population
        FROM census.counties q
        LEFT JOIN census.variable_data vd
            ON q.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        WHERE q.stusps = ANY(\$1)
    """
    
    # Execute the query with parameters
    result = execute(conn, geo_query, [target_states])
    
    # Process the result
    df = DataFrame(result)
    
    # Close the connection
    close(conn)
    
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

function map_poly(data::DataFrame; 
                 title::String="Geographic Distribution",
                 colormap=:viridis)
    
    fig = CairoMakie.Figure(size=DEFAULT_PLOT_SIZE)
    
    # Create the map axis
    ga = GeoMakie.GeoAxis(
        fig[1,1],
        title = title,
        dest = GeoMakie.WGS84(),
        coastlines = true,
        lonlims = (-180, 180),
        latlims = (-90, 90)
    )
    
    # Plot the polygons
    for row in eachrow(data)
        geom = GeoInterface.coordinates(row.geometry)
        GeoMakie.poly!(ga, geom,
            color = row.value,
            colormap = colormap,
            strokewidth = 1,
            strokecolor = :black
        )
    end
    
    # Add a colorbar
    CairoMakie.Colorbar(fig[1,2], colormap=colormap,
        label="Value",
        width=20,
        height=Relative(0.5)
    )
    
    return fig
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

# Export all public functions
export get_geo_pop,
       parse_geoms,
       convert_to_polygon,
       map_poly,
       geo_plot 