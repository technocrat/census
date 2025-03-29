# SPDX-License-Identifier: MIT

"""
    get_geo_pop(postals::Vector{String}) -> DataFrame

Returns a DataFrame containing geographic information for the specified postal codes.
"""
function get_geo_pop(postals::Vector{String})
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, 
           ST_Centroid(geom) as centroid, 
           ST_AsText(geom) as geom
    FROM Census.counties
    WHERE stusps = ANY(\$1)
    ORDER BY stusps, name;
    """
    result = execute(conn, query, [postals])
    close(conn)
    return DataFrame(result)
end

"""
    map_poly(df::DataFrame, title::String, dest::String) -> Nothing

Plots a map of the geographic data in the DataFrame.

# Arguments
- `df::DataFrame`: DataFrame containing geographic data with columns :geom and :name
- `title::String`: Title for the map
- `dest::String`: Destination name for the map (used for CRS and filename)
"""
function map_poly(df::DataFrame, title::String, dest::String)
    # Create the plot
    fig = Figure()
    ax = GeoAxis(fig[1, 1],
        dest=dest,
        title=title
    )

    # Parse the WKT geometries
    geoms = parse_geoms(df.geom)

    # Plot the data
    for (i, geom) in enumerate(geoms)
        multi_poly = geom
        n_polys = ArchGDAL.ngeom(multi_poly)
        
        for p_idx in 0:(n_polys-1)
            poly = ArchGDAL.getgeom(multi_poly, p_idx)
            ext_ring = ArchGDAL.getgeom(poly, 0)
            ring_text = ArchGDAL.toWKT(ext_ring)
            
            coords_text = replace(ring_text, "LINEARRING (" => "")
            coords_text = replace(coords_text, ")" => "")
            
            point_list = Point2f[]
            for pair in split(coords_text, ",")
                parts = split(strip(pair))
                if length(parts) >= 2
                    x = parse(Float32, parts[1])
                    y = parse(Float32, parts[2])
                    push!(point_list, Point2f(x, y))
                end
            end
            
            if !isempty(point_list)
                poly_obj = GeometryBasics.Polygon(point_list)
                poly!(
                    ax,
                    poly_obj,
                    color=:lightgray,
                    strokecolor=:black,
                    strokewidth=1
                )
            end
        end
    end

    # Add labels
    for row in eachrow(df)
        text!(ax, row.centroid, text=row.name, color=:black, fontsize=8)
    end

    # Create filename with title and datetime
    timestamp = Dates.format(now(), "yyyy-mm-dd_HHMMSS")
    filename = joinpath("plots", "$(title)_$(timestamp).png")
    
    # Ensure plots directory exists
    mkpath("plots")
    
    # Save the plot
    save(filename, fig)
end

"""
    parse_geoms(geoms::Vector{Union{Missing, String}}) -> Vector{ArchGDAL.IGeometry}

Parses a vector of WKT geometry strings into ArchGDAL geometries.
Handles missing values by filtering them out.
"""
function parse_geoms(geoms::Vector{Union{Missing, String}})
    valid_geoms = filter(!ismissing, geoms)
    return [ArchGDAL.fromWKT(geom) for geom in valid_geoms]
end

"""
    convert_to_polygon(geom::ArchGDAL.IGeometry) -> GeometryBasics.Polygon

Converts an ArchGDAL geometry to a GeometryBasics.Polygon.
Handles both Polygon and MultiPolygon geometries.
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

"""
    plot_map(df::DataFrame, title::String, dest::String) -> Nothing

Convenience function for plotting a map with the given DataFrame, title, and destination.
"""
function plot_map(df::DataFrame, title::String, dest::String)
    map_poly(df, title, dest)
end

# Export all public functions
export get_geo_pop,
       map_poly,
       parse_geoms,
       plot_map 