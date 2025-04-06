# SPDX-License-Identifier: MIT

"""
    Basin-specific constants for Census.jl

This file contains constants related to river basins that require the get_geo_pop function.
These constants are defined here to avoid circular dependencies.
"""

using DataFrames
using .CensusDB: execute

# Import required functions from parent module
import ..Census: CensusDB

# Initialize constants as empty arrays
const OHIO_BASIN_KY_GEOIDS = String[]
const OHIO_BASIN_TN_GEOIDS = String[]

"""
    init_basin_constants()

Initialize constants that depend on get_geo_pop and other functions.
This function sets:
- OHIO_BASIN_KY_GEOIDS: Kentucky counties in the Ohio River Basin
- OHIO_BASIN_TN_GEOIDS: Tennessee counties in the Ohio River Basin
"""
function init_basin_constants()
    CensusDB.with_connection() do conn
        # Get Kentucky counties
        ky_query = """
        SELECT geoid FROM census.counties 
        WHERE stusps = 'KY' 
        AND ST_X(ST_Centroid(geom)) > -89.0
        ORDER BY geoid;
        """
        ky_result = DataFrame(execute(conn, ky_query))
        append!(empty!(OHIO_BASIN_KY_GEOIDS), ky_result.geoid)

        # Get Tennessee counties
        tn_query = """
        SELECT geoid FROM census.counties 
        WHERE stusps = 'TN' 
        AND ST_X(ST_Centroid(geom)) > -89.0
        ORDER BY geoid;
        """
        tn_result = DataFrame(execute(conn, tn_query))
        append!(empty!(OHIO_BASIN_TN_GEOIDS), tn_result.geoid)
    end
end

"""
    get_ohio_basin_ky_geoids() -> Vector{String}

Get GEOIDs for Kentucky counties in the Ohio River basin.
"""
function get_ohio_basin_ky_geoids()
    ky_query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'KY'
        AND ST_Y(ST_Centroid(geom)) > 37.5
        ORDER BY geoid;
    """
    
    ky_result = DataFrame(execute(conn, ky_query))
    return ky_result.geoid
end

"""
    get_ohio_basin_tn_geoids() -> Vector{String}

Get GEOIDs for Tennessee counties in the Ohio River basin.
"""
function get_ohio_basin_tn_geoids()
    tn_query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'TN'
        AND ST_Y(ST_Centroid(geom)) > 36.5
        ORDER BY geoid;
    """
    
    tn_result = DataFrame(execute(conn, tn_query))
    return tn_result.geoid
end

# Export the constants and initialization function
export OHIO_BASIN_KY_GEOIDS, OHIO_BASIN_TN_GEOIDS, init_basin_constants 