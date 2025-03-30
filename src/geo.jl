# SPDX-License-Identifier: MIT

"""
    get_geo_pop(target_states::Vector{String}) -> DataFrame

Returns a DataFrame containing geographic information for the specified postal codes.
"""
function get_geo_pop(target_states::Vector{String})
    target_states = make_postal_codes(target_states)
    # Connect to database
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Convert PostalCode objects to their string values for the query
    state_codes = [pc.code for pc in target_states]
    
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
    result = execute(conn, geo_query, [state_codes])
    
    # Process the result
    df = DataFrame(result)
    
    # Close the connection
    close(conn)
    
    return df
end

"""
    parse_geoms(geoms::Vector{Union{Missing, String}}) -> Vector{Union{Missing, ArchGDAL.IGeometry}}

Parses a vector of WKT geometry strings into ArchGDAL geometries.
Returns missing for any geometries that fail to parse.
"""
function parse_geoms(geoms::Vector{Union{Missing, String}})
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

# Export all public functions
export get_geo_pop,
       parse_geoms,
       convert_to_polygon 