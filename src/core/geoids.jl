# SPDX-License-Identifier: MIT

using LibPQ
using DataFrames
using ArchGDAL

"""
    get_western_geoids() -> Vector{String}

Returns GEOIDs for counties west of 100°W longitude and east of 115°W longitude
to get the high plains counties with historically low rainfall
(< 20 inches per year) requiring irrigation.
"""
function get_western_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) < -100.0
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_eastern_geoids() -> Vector{String}

Returns GEOIDs for counties between 90°W and 100°W longitude
to get the eastern counties with historically high rainfall 
(> 20 inches per year) not requiring irrigation.
"""
function get_eastern_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) > -100
    AND ST_X(ST_Centroid(geom)) < -90
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_colorado_basin_geoids()::Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()::Vector{String}
    # Get the path to the shapefile using absolute path from project root
    project_root = dirname(dirname(@__DIR__))
    shapefile_path = joinpath(project_root, "data", "Colorado_River_Basin_County_Boundaries", "Colorado_River_Basin_County_Boundaries.shp")
    
    # Print the path for debugging
    @info "Looking for shapefile at: $shapefile_path"
    
    # Check if the file exists
    if !isfile(shapefile_path)
        @warn "Shapefile not found at: $shapefile_path"
        return String[]
    end
    
    # Read the shapefile and extract GEOIDs
    ds = ArchGDAL.read(shapefile_path)
    layer = ArchGDAL.getlayer(ds, 0)
    geoids = String[]
    
    if ArchGDAL.nfeature(layer) == 0
        ArchGDAL.destroy(ds)
        return geoids
    end
    
    for feature in layer
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end
    
    ArchGDAL.destroy(ds)
    unique!(geoids)
    return geoids
end

"""
    get_west_montana_geoids() -> Vector{String}

Returns GEOIDs for counties in western Montana that are part of the Powell nation state.
"""
function get_west_montana_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'MT'
    AND ST_X(ST_Centroid(geom)) < -112.5
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_florida_south_geoids() -> Vector{String}

Returns GEOIDs for Florida counties with centroids south of 29°N latitude.
This includes all of southern Florida including the Keys.
"""
function get_florida_south_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'FL'
    AND ST_Y(ST_Centroid(geom)) < 29.0
    ORDER BY ST_Y(ST_Centroid(geom)) DESC;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})

Store the geoids for a nation state in the database.

# Arguments
- `nation_state::String`: The name of the nation state
- `geoids::Union{Vector{String}, Vector{Union{Missing, String}}}`: Vector of geoids to associate with the nation state

# Example
```julia
set_nation_state_geoids("Powell", powell_geoids)
```
"""
function set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})
    conn = get_db_connection()
    try
        # Start a transaction
        LibPQ.execute(conn, "BEGIN;")
        
        # First, clear the nation_state for any counties that currently have it
        LibPQ.execute(conn, 
            "UPDATE census.counties SET nation_state = NULL WHERE nation_state = \$1;",
            [nation_state]
        )
        
        # Filter out missing values and convert to array
        valid_geoids = filter(!ismissing, collect(String, geoids))
        
        if !isempty(valid_geoids)
            # Then set the new nation_state for all specified counties in one query
            LibPQ.execute(conn, 
                "UPDATE census.counties SET nation_state = \$1 WHERE geoid = ANY(\$2::text[]);",
                [nation_state, valid_geoids]
            )
        end
        
        # Commit the transaction
        LibPQ.execute(conn, "COMMIT;")
    catch e
        # Rollback on error
        LibPQ.execute(conn, "ROLLBACK;")
        rethrow(e)
    finally
        close(conn)
    end
end

"""
    get_east_of_cascade_geoids() -> Vector{String}

Returns GEOIDs for counties east of the Cascade Mountains.
"""
function get_east_of_cascade_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps IN ('WA', 'OR')
    AND ST_X(ST_Centroid(geom)) > -120.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_west_of_cascades() -> Vector{String}

Returns GEOIDs for counties west of the Cascade Mountains.
"""
function get_west_of_cascades()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps IN ('WA', 'OR')
    AND ST_X(ST_Centroid(geom)) < -120.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_cascades() -> Vector{String}

Returns GEOIDs for counties east of the Cascade Mountains.
"""
function get_east_of_cascades()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps IN ('WA', 'OR')
    AND ST_X(ST_Centroid(geom)) > -120.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_southern_kansas_geoids() -> Vector{String}

Returns GEOIDs for counties in southern Kansas.
"""
function get_southern_kansas_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'KS'
    AND ST_Y(ST_Centroid(geom)) < 38.5
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_northern_kansas_geoids() -> Vector{String}

Returns GEOIDs for counties in northern Kansas.
"""
function get_northern_kansas_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'KS'
    AND ST_Y(ST_Centroid(geom)) >= 38.5
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_ne_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in northeastern Missouri.
"""
function get_ne_missouri_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'MO'
    AND ST_Y(ST_Centroid(geom)) >= 39.0
    AND ST_X(ST_Centroid(geom)) >= -92.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_southern_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in southern Missouri.
"""
function get_southern_missouri_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'MO'
    AND ST_Y(ST_Centroid(geom)) < 38.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_northern_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in northern Missouri.
"""
function get_northern_missouri_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps = 'MO'
    AND ST_Y(ST_Centroid(geom)) >= 38.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_missouri_river_basin_geoids() -> Vector{String}

Returns GEOIDs for counties in the Missouri River Basin.
"""
function get_missouri_river_basin_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps IN ('MO', 'KS', 'NE', 'SD', 'ND', 'MT')
    AND ST_X(ST_Centroid(geom)) > -105.0
    AND ST_X(ST_Centroid(geom)) < -90.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_slope_geoids() -> Vector{String}

Returns GEOIDs for counties in the Slope region.
"""
function get_slope_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE stusps IN ('ND', 'SD')
    AND ST_X(ST_Centroid(geom)) > -105.0
    AND ST_X(ST_Centroid(geom)) < -100.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_utah_geoids() -> Vector{String}

Returns GEOIDs for counties east of Utah.
"""
function get_east_of_utah_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) > -111.0
    AND ST_X(ST_Centroid(geom)) < -102.0
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_socal_geoids()

Returns GEOIDs for Southern California counties, including:
- San Luis Obispo, Kern, and San Bernardino counties
- All counties south of these counties
"""
function get_socal_geoids()
    conn = get_db_connection()
    query = """
        WITH socal_counties AS (
            -- Explicitly include the northernmost counties
            SELECT geoid
            FROM census.counties
            WHERE stusps = 'CA'
            AND name IN ('San Luis Obispo', 'Kern', 'San Bernardino')
            
            UNION
            
            -- Include all counties south of these
            SELECT geoid
            FROM census.counties
            WHERE stusps = 'CA'
            AND ST_Y(ST_Centroid(geom)) <= (
                SELECT MAX(ST_Y(ST_Centroid(geom)))
                FROM census.counties
                WHERE name IN ('San Luis Obispo', 'Kern', 'San Bernardino')
                AND stusps = 'CA'
            )
        )
        SELECT geoid
        FROM socal_counties
        ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_sierras_geoids()

Returns GEOIDs for California counties bordering Nevada (except Placer County) plus Plumas County.
These counties form the eastern Sierra region.
"""
function get_east_of_sierras_geoids()
    conn = get_db_connection()
    query = """
        WITH border_counties AS (
            SELECT DISTINCT c1.geoid, c1.name
            FROM census.counties c1
            JOIN census.counties c2 ON ST_Touches(c1.geom, c2.geom)
            WHERE c1.stusps = 'CA' 
            AND c2.stusps = 'NV'
            AND c1.geoid != '06061'  -- Exclude Placer County
            UNION
            SELECT geoid, name
            FROM census.counties
            WHERE stusps = 'CA'
            AND name = 'Plumas'
        )
        SELECT geoid 
        FROM border_counties
        ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_exclude_from_va_geoids() -> Vector{String}

Returns GEOIDs for Virginia counties northeast of Highland County's centroid.
Highland County is explicitly included in the results.
"""
function get_exclude_from_va_geoids()
    conn = get_db_connection()
    query = """
    WITH highland_centroid AS (
        SELECT ST_X(ST_Centroid(geom)) as ref_lon,
               ST_Y(ST_Centroid(geom)) as ref_lat
        FROM census.counties 
        WHERE stusps = 'VA' AND name = 'Highland'
    ),
    northeast_counties AS (
        SELECT c.geoid
        FROM census.counties c, highland_centroid h
        WHERE c.stusps = 'VA'
        AND (ST_Y(ST_Centroid(c.geom)) > h.ref_lat 
             OR (ST_Y(ST_Centroid(c.geom)) = h.ref_lat 
                 AND ST_X(ST_Centroid(c.geom)) > h.ref_lon))
    ),
    highland_county AS (
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'VA' AND name = 'Highland'
    )
    SELECT geoid FROM (
        SELECT geoid FROM northeast_counties
        UNION
        SELECT geoid FROM highland_county
    ) combined
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

# Export all functions
export get_western_geoids,
       get_eastern_geoids,
       get_colorado_basin_geoids,
       get_west_montana_geoids,
       get_florida_south_geoids,
       get_east_of_cascade_geoids,
       get_west_of_cascades,
       get_east_of_cascades,
       get_southern_kansas_geoids,
       get_northern_kansas_geoids,
       get_ne_missouri_geoids,
       get_southern_missouri_geoids,
       get_northern_missouri_geoids,
       get_missouri_river_basin_geoids,
       get_slope_geoids,
       get_east_of_utah_geoids,
       get_socal_geoids,
       set_nation_state_geoids,
       get_east_of_sierras_geoids,
       get_exclude_from_va_geoids 