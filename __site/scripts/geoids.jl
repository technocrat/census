"""
Module for handling geographic ID constants and queries.
"""

using LibPQ
using DataFrames
using ArchGDAL
using Census

# Database connection parameters
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

# Notable Geographic IDs
const OSAGE_COUNTY_KS = "20167"  # Used as reference for Southern Kansas
const LOS_ANGELES_COUNTY = "06037"

# Longitude boundaries for regions
const WESTERN_BOUNDARY = -115.0
const EASTERN_BOUNDARY = -90.0
const CONTINENTAL_DIVIDE = -109.5
const SLOPE_WEST = -120.0
const SLOPE_EAST = -115.0
const UTAH_BORDER = -109.0
const CENTRAL_MERIDIAN = -100.0

"""
    get_db_connection() -> LibPQ.Connection

Creates a connection to the PostgreSQL database using default parameters.
"""
function get_db_connection()
    conn = LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
    return conn
end

"""
    get_western_geoids() -> DataFrame

Returns GEOIDs for counties west of 100°W longitude and east of 115°W longitude.
"""
function get_western_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) < $WESTERN_BOUNDARY
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_eastern_geoids() -> DataFrame

Returns GEOIDs for counties between 90°W and 100°W longitude.
"""
function get_eastern_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) > $EASTERN_BOUNDARY
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_east_of_utah_geoids() -> DataFrame

Returns GEOIDs for counties east of Utah's border (109°W longitude).
"""
function get_east_of_utah_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) > $UTAH_BORDER
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_slope_geoids() -> DataFrame

Returns GEOIDs for counties between 115°W and 120°W longitude.
"""
function get_slope_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) BETWEEN $SLOPE_WEST AND $SLOPE_EAST
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_southern_kansas_geoids() -> DataFrame

Returns GEOIDs for Kansas counties south of Osage County.
"""
function get_southern_kansas_geoids()
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM counties WHERE geoid = '$OSAGE_COUNTY_KS'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_DWithin(c.geom, o.geom, 100000)
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_colorado_basin_geoids() -> DataFrame

Returns GEOIDs for counties within the Colorado River Basin.
"""
function get_colorado_basin_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps
    FROM counties
    WHERE stusps IN ('CO', 'UT', 'AZ', 'NM', 'WY')
    AND ST_Intersects(geom, (
        SELECT ST_Buffer(geom, 50000)
        FROM counties
        WHERE geoid = '$OSAGE_COUNTY_KS'
    ))
    ORDER BY stusps, name;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

export get_western_geoids,
       get_eastern_geoids,
       get_east_of_utah_geoids,
       get_slope_geoids,
       get_southern_kansas_geoids,
       get_colorado_basin_geoids 