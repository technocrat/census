"""
Submodule for handling geographic ID constants and queries.
"""
module geoids

using LibPQ
using DataFrames
using ArchGDAL

# Import get_geo_pop from parent module
import ..Census: get_geo_pop

# Database connection parameters
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

# Longitude boundaries for regions
const WESTERN_BOUNDARY = -115.0
const EASTERN_BOUNDARY = -90.0
const CONTINENTAL_DIVIDE = -109.5
const SLOPE_WEST = -120.0
const SLOPE_EAST = -115.0
const UTAH_BORDER = -109.0
const CENTRAL_MERIDIAN = -100.0

# Include the implementation and CRS definitions
include("impl.jl")
include("crs.jl")

# Pre-compute commonly used geoid sets
const western_geoids = get_western_geoids()
const eastern_geoids = get_eastern_geoids()
const east_of_utah_geoids = get_east_of_utah_geoids()
const east_of_cascade_geoids = get_east_of_cascade_geoids()
const southern_kansas_geoids = get_southern_kansas_geoids()
const northern_kansas_geoids = get_northern_kansas_geoids()
const colorado_basin_geoids = get_colorado_basin_geoids()
const ne_missouri_geoids = get_ne_missouri_geoids()
const southern_missouri_geoids = get_southern_missouri_geoids()
const northern_missouri_geoids = get_northern_missouri_geoids()
const missouri_river_basin_geoids = get_missouri_river_basin_geoids()

# Export public functions
export get_db_connection,
       get_western_geoids,
       get_eastern_geoids,
       get_east_of_utah_geoids,
       get_east_of_cascade_geoids,
       get_southern_kansas_geoids,
       get_northern_kansas_geoids,
       get_colorado_basin_geoids,
       get_ne_missouri_geoids,
       get_southern_missouri_geoids,
       get_northern_missouri_geoids,
       get_missouri_river_basin_geoids,
       get_crs

# Export constants
export DB_HOST,
       DB_PORT,
       DB_NAME,
       WESTERN_BOUNDARY,
       EASTERN_BOUNDARY,
       CONTINENTAL_DIVIDE,
       SLOPE_WEST,
       SLOPE_EAST,
       UTAH_BORDER,
       CENTRAL_MERIDIAN,
       CRS_STRINGS

# Export pre-computed geoid sets
export western_geoids,
       eastern_geoids,
       east_of_utah_geoids,
       east_of_cascade_geoids,
       southern_kansas_geoids,
       northern_kansas_geoids,
       colorado_basin_geoids,
       ne_missouri_geoids,
       southern_missouri_geoids,
       northern_missouri_geoids,
       missouri_river_basin_geoids,
       east_of_sierras_geoids

end # module 