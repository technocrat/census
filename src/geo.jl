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
    conn = get_db_connection()
    query = """
    SELECT geoid 
    FROM census.counties 
    WHERE ST_X(ST_Centroid(geom)) BETWEEN $min_long AND $max_long
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
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