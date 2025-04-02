# SPDX-License-Identifier: MIT

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
    FROM Census.counties
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
to get the eastern counties with historically highlighters rainfall 
(> 20 inches per year) not requiring irrigation.
"""
function get_eastern_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM Census.counties
    WHERE ST_X(ST_Centroid(geom)) > -100
    AND ST_X(ST_Centroid(geom)) < -90
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_utah_geoids() -> Vector{String}

Returns GEOIDs for counties east of Utah's border (109°W longitude).
"""
function get_east_of_utah_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM Census.counties
    WHERE ST_X(ST_Centroid(geom)) > $UTAH_BORDER
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_cascade_geoids()::Vector{String}

Returns GEOIDs for counties between 115°W and 120°W longitude—used to get
trans-Cascade counties of WA and OR.
"""
function get_east_of_cascade_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) BETWEEN $SLOPE_WEST AND $SLOPE_EAST
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_southern_kansas_geoids() -> Vector{String}

Returns GEOIDs for Kansas counties south of Osage County, an approximate
boundary for the Missouri Basin
"""
function get_southern_kansas_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM Census.counties WHERE geoid = '20167'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM Census.counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_Y(ST_Centroid(c.geom)) < ST_Y(ST_Centroid(o.geom))  -- South of Osage County
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_northern_kansas_geoids() -> Vector{String}

Returns GEOIDs for Kansas counties north of Osage County, an approximate
boundary for the Missouri Basin
"""
function get_northern_kansas_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM Census.counties WHERE geoid = '20167'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM Census.counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_Y(ST_Centroid(c.geom)) > ST_Y(ST_Centroid(o.geom))  -- North of Osage County
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_colorado_basin_geoids()::Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Colorado Basin boundaries https://coloradoriverbasin-lincolninstitute.hub.arcgis.com/datasets/a922a3809058416b8260813e822f8980_0/explore?location=36.663436%2C-110.573590%2C5.51
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()::Vector{String}
    shapefile_path = joinpath(dirname(@__DIR__), "..", "data", "Colorado_River_Basin_County_Boundaries")

    # Read the shapefile
    dataset = ArchGDAL.read(shapefile_path)

    # Extract GEOIDs from the feature layer
    layer = ArchGDAL.getlayer(dataset, 0)
    geoids = String[]

    for feature in layer
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end

    ArchGDAL.destroy(dataset)
    return sort(unique(geoids))
end

"""
Get Missouri county geoids that are north of St. Charles County and east of Schuyler County,
plus Schuyler and Adair counties, which drain into the Mississippi River.
"""
function get_ne_missouri_geoids()::Vector{String}
    query = """
    WITH reference_counties AS (
        SELECT 
            geom as schuyler_geom,
            ST_XMin(geom) as schuyler_west
        FROM census.counties 
        WHERE name = 'Schuyler' AND stusps = 'MO'
    ),
    st_charles AS (
        SELECT ST_YMax(geom) as st_charles_north
        FROM census.counties 
        WHERE name = 'St. Charles' AND stusps = 'MO'
    )
    SELECT DISTINCT c.geoid, c.name
    FROM census.counties c, reference_counties r, st_charles s
    WHERE c.stusps = 'MO'
    AND (
        -- Include Schuyler and Adair counties regardless of position
        c.name IN ('Schuyler', 'Adair')
        OR (
            -- All other counties must be north of St. Charles and east of Schuyler
            ST_YMin(c.geom) > s.st_charles_north  -- North of St. Charles
            AND ST_XMin(c.geom) > r.schuyler_west  -- East of Schuyler
        )
    )
    ORDER BY c.name;
    """

    conn = get_db_connection()
    result = DataFrame(LibPQ.execute(conn, query))
    close(conn)
    return result.geoid
end

"""
Get Missouri counties that are south of Perry County's southern boundary,
excluding Vernon, Cedar, Polk, Dallas, Webster, Laclede, Wright, Texas, Dent 
and Iron counties, which generally do not drain into the Missouri River.
"""
function get_southern_missouri_geoids()::Vector{String}
    query = """
    WITH perry_boundary AS (
        SELECT ST_YMin(ST_Envelope(geom)) as southern_boundary
        FROM census.counties 
        WHERE name = 'Perry' AND stusps = 'MO'
    )
    SELECT c.geoid, c.name
    FROM census.counties c, perry_boundary p
    WHERE c.stusps = 'MO'
    AND ST_Y(ST_Centroid(c.geom)) < p.southern_boundary
    AND c.name NOT IN ('Vernon', 'Cedar', 'Polk', 'Dallas', 'Webster', 
                      'Laclede', 'Wright', 'Texas', 'Dent', 'Iron', 
                      'Washington', 'St. Francois', 'St. Louis') 
    ORDER BY c.name;
    """

    conn = get_db_connection()
    result = LibPQ.execute(conn, query)
    close(conn)

    DataFrame(result).geoid
end

function get_northern_missouri_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid 
    FROM census.counties 
    WHERE stusps = 'MO' AND geoid NOT IN (
        SELECT geoid FROM census.counties WHERE geoid = ANY(\$1)
    )
    """
    result = LibPQ.execute(conn, query, [get_southern_missouri_geoids()])
    close(conn)
    return DataFrame(result).geoid
end

"""
Get Missouri River Basin county geoids by combining northern and southern Missouri counties,
excluding those that drain into the Mississippi River.
"""
function get_missouri_river_basin_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid 
    FROM census.counties 
    WHERE stusps = 'MO' AND geoid NOT IN (
        SELECT geoid FROM census.counties WHERE geoid = ANY(\$1) OR geoid = ANY(\$2)
    )
    """
    result = LibPQ.execute(conn, query, [get_ne_missouri_geoids(), get_southern_missouri_geoids()])
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_west_of_cascades()::Vector{String}

Returns GEOIDs for counties west of the Cascade Mountains (west of 120°W longitude).
"""
function get_west_of_cascades()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) < $SLOPE_WEST
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_cascades()::Vector{String}

Returns GEOIDs for counties east of the Cascade Mountains (east of 115°W longitude).
"""
function get_east_of_cascades()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) > $SLOPE_EAST
    ORDER BY lon;
    """
    result = LibPQ.execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

# Define static geoid sets
# const east_of_sierras_geoids = ["06049", "06035", "06051", "06027"]

"""
    setup_nation_states_table()

Creates or updates the nation_state column in the census.counties table.
"""
function setup_nation_states_table()
    conn = get_db_connection()
    query = """
    DO \$\$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'census' 
            AND table_name = 'counties' 
            AND column_name = 'nation_state'
        ) THEN
            ALTER TABLE census.counties 
            ADD COLUMN nation_state VARCHAR(50);
        END IF;
    END \$\$;
    """
    LibPQ.execute(conn, query)
    close(conn)
end

"""
    set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})

Associates the given geoids with a nation state in the database. Handles both Vector{String} and 
Vector{Union{Missing, String}}, filtering out any missing values.
"""
function set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})
    # Filter out missing values and convert to Vector{String}
    clean_geoids = filter(!ismissing, geoids)
    
    conn = get_db_connection()
    # First ensure the table is set up
    setup_nation_states_table()
    
    # Update the nation state for these geoids
    query = """
    UPDATE census.counties 
    SET nation_state = \$1 
    WHERE geoid = ANY(\$2::text[]);
    """
    LibPQ.execute(conn, query, [nation_state, "{" * join(clean_geoids, ",") * "}"])
    close(conn)
end

"""
    get_nation_state_geoids(nation_state::String)::Vector{String}

Retrieves all geoids associated with a given nation state.
"""
function get_nation_state_geoids(nation_state::String)::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid 
    FROM census.counties 
    WHERE nation_state = \$1
    ORDER BY geoid;
    """
    result = LibPQ.execute(conn, query, [nation_state])
    close(conn)
    return DataFrame(result).geoid
end

"""
    clear_nation_state_geoids(nation_state::String)

Removes the nation state association for all counties of the given nation state.
"""
function clear_nation_state_geoids(nation_state::String)
    conn = get_db_connection()
    query = """
    UPDATE census.counties 
    SET nation_state = \$1 
    WHERE nation_state = \$1;
    """
    LibPQ.execute(conn, query, [nation_state])
    close(conn)
end
