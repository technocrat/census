#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

"""
This script is used to initialize the GEOID constants for the Census package.
It should be run once to generate the constants, which are then stored in constants.jl.
"""

using .CensusDB: execute, with_connection

# Import the database connection function
include("../src/core/db.jl")
using .CensusDB

# All the GEOID generating functions from geoids.jl
include("../src/core/geoids.jl")

"""
    initialize_geoids()

Initialize geographic identifiers (GEOIDs) for various regions.

# Side effects
- Queries the database for GEOIDs based on geographic criteria
- Updates the Census.GEOIDS dictionary with the results

# Example
```julia
initialize_geoids()
```
"""
function initialize_geoids()
    with_connection() do conn
        # Western states
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR', 'CA', 'NV', 'ID', 'MT', 'WY', 'UT', 'CO', 'AZ', 'NM')
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["western"] = df.geoid
        
        # Eastern states
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps NOT IN ('WA', 'OR', 'CA', 'NV', 'ID', 'MT', 'WY', 'UT', 'CO', 'AZ', 'NM', 'HI', 'AK')
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["eastern"] = df.geoid
        
        # East of Utah
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps NOT IN ('WA', 'OR', 'CA', 'NV', 'ID', 'UT', 'AZ', 'HI', 'AK')
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["east_of_utah"] = df.geoid
        
        # West of Cascades
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR')
        AND ST_X(ST_Centroid(geom)) < -122
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["west_of_cascades"] = df.geoid
        
        # East of Cascades
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR')
        AND ST_X(ST_Centroid(geom)) > -122
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["east_of_cascades"] = df.geoid
        
        # Southern Kansas
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'KS'
        AND ST_Y(ST_Centroid(geom)) < 38.5
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["southern_kansas"] = df.geoid
        
        # Northern Kansas
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'KS'
        AND ST_Y(ST_Centroid(geom)) > 38.5
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["northern_kansas"] = df.geoid
        
        # Colorado Basin
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('CO', 'WY', 'UT')
        AND ST_Y(ST_Centroid(geom)) > 39
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["colorado_basin"] = df.geoid
        
        # Northeast Missouri
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) > 39
        AND ST_X(ST_Centroid(geom)) > -92
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["ne_missouri"] = df.geoid
        
        # Southern Missouri
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) < 37.5
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["southern_missouri"] = df.geoid
        
        # Northern Missouri
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) > 39
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["northern_missouri"] = df.geoid
        
        # Missouri River Basin
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('MO', 'KS', 'NE', 'IA')
        AND ST_Y(ST_Centroid(geom)) > 39
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["missouri_river_basin"] = df.geoid
        
        # Slope
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('ND', 'SD', 'MT')
        AND ST_Y(ST_Centroid(geom)) > 45
        ORDER BY geoid;
        """
        df = execute(conn, query) |> DataFrame
        Census.GEOIDS["slope"] = df.geoid
    end
    
    return nothing
end

# Function to format a vector of GEOIDs as a Julia constant definition
function format_constant(name::String, geoids::Vector{String}, description::String)
    constant_def = """
\"\"\"
    $(name)::Vector{String}

$(description)
\"\"\"
const $(name) = [
    $(join(map(g -> "\"$g\"", geoids), ", "))
]
"""
    return constant_def
end

# Generate all constants
function generate_constants(conn)
    constants = Dict{String, Tuple{Vector{String}, String}}()
    
    # Add each constant with its description
    constants["WESTERN_GEOIDS"] = (get_western_geoids(conn), 
        "Western region: Counties west of 100°W longitude and Oklahoma panhandle")
    
    constants["EASTERN_GEOIDS"] = (get_eastern_geoids(conn),
        "Eastern region: Counties between 90°W and 100°W longitude, excluding Oklahoma panhandle")
    
    constants["COLORADO_BASIN_GEOIDS"] = (get_colorado_basin_geoids(conn),
        "GEOIDs for counties in the Colorado River Basin")
    
    constants["WEST_MONTANA_GEOIDS"] = (get_west_montana_geoids(),
        "GEOIDs for counties in western Montana")
    
    constants["FLORIDA_SOUTH_GEOIDS"] = (get_florida_south_geoids(),
        "GEOIDs for Florida counties south of 29°N latitude")
    
    constants["EAST_OF_CASCADE_GEOIDS"] = (get_east_of_cascade_geoids(),
        "GEOIDs for counties east of the Cascade Mountains")
    
    constants["WEST_OF_CASCADES_GEOIDS"] = (get_west_of_cascades_geoids(conn),
        "West of Cascades: Counties west of the Cascade Mountains")
    
    constants["EAST_OF_CASCADES_GEOIDS"] = (get_east_of_cascades_geoids(conn),
        "East of Cascades: Counties east of the Cascade Mountains")
    
    constants["SOUTHERN_KANSAS_GEOIDS"] = (get_southern_kansas_geoids(conn),
        "Southern Kansas: Counties south of 38.5°N latitude")
    
    constants["NORTHERN_KANSAS_GEOIDS"] = (get_northern_kansas_geoids(conn),
        "Northern Kansas: Counties north of 38.5°N latitude")
    
    constants["NE_MISSOURI_GEOIDS"] = (get_ne_missouri_geoids(conn),
        "Northeastern Missouri: Counties east of 92°W and north of 39°N")
    
    constants["SOUTHERN_MISSOURI_GEOIDS"] = (get_southern_missouri_geoids(conn),
        "Southern Missouri: Counties south of 37.5°N")
    
    constants["NORTHERN_MISSOURI_GEOIDS"] = (get_northern_missouri_geoids(conn),
        "Northern Missouri: Counties north of 39°N")
    
    constants["MISSOURI_RIVER_BASIN_GEOIDS"] = (get_missouri_river_basin_geoids(conn),
        "Missouri River Basin: Counties intersecting the Missouri River watershed")
    
    constants["SLOPE_GEOIDS"] = (get_slope_geoids(conn),
        "Slope region: North Dakota counties between 120°W and 115°W")
    
    constants["EAST_OF_UTAH_GEOIDS"] = (get_east_of_utah_geoids(conn),
        "East of Utah: Counties east of Utah's eastern boundary")
    
    constants["SOCAL_GEOIDS"] = (get_socal_geoids(),
        "GEOIDs for Southern California counties")
    
    constants["EAST_OF_SIERRAS_GEOIDS"] = (get_east_of_sierras_geoids(),
        "GEOIDs for California counties bordering Nevada plus Plumas County")
    
    constants["EXCLUDE_FROM_VA_GEOIDS"] = (get_exclude_from_va_geoids(),
        "GEOIDs for Virginia counties northeast of Highland County")
    
    constants["NON_MISS_BASIN_LA_GEOIDS"] = (get_non_miss_basin_la_geoids(),
        "GEOIDs for Louisiana parishes not in the Mississippi Basin")
    
    constants["EXCLUDE_FROM_LA_GEOIDS"] = (get_exclude_from_la_geoids(),
        "GEOIDs for excluded Louisiana parishes")
    
    constants["OHIO_BASIN_VA_GEOIDS"] = (get_ohio_basin_va_geoids(),
        "GEOIDs for Virginia counties in the Ohio River Basin")
    
    constants["OHIO_BASIN_AL_GEOIDS"] = (get_ohio_basin_al_geoids(),
        "GEOIDs for Alabama counties in the Ohio River Basin")
    
    constants["OHIO_BASIN_MS_GEOIDS"] = (get_ohio_basin_ms_geoids(),
        "GEOIDs for Mississippi counties in the Ohio River Basin")
    
    constants["OHIO_BASIN_NC_GEOIDS"] = (get_ohio_basin_nc_geoids(),
        "GEOIDs for North Carolina counties in the Ohio River Basin")
    
    constants["OHIO_BASIN_GA_GEOIDS"] = (get_ohio_basin_ga_geoids(),
        "GEOIDs for Georgia counties in the Ohio River Basin")
    
    constants["OHIO_BASIN_MD_GEOIDS"] = (get_ohio_basin_md_geoids(),
        "GEOIDs for Maryland counties in the Ohio River Basin")
    
    constants["HUDSON_BAY_DRAINAGE_GEOIDS"] = (get_hudson_bay_drainage_geoids(),
        "GEOIDs for counties in the Hudson Bay drainage basin")
    
    constants["MISS_RIVER_BASIN_SD_GEOIDS"] = (get_miss_river_basin_sd_geoids(),
        "GEOIDs for South Dakota counties in the Mississippi River Basin")
    
    return constants
end

# Generate the constants section for constants.jl
function generate_constants_section(constants::Dict{String, Tuple{Vector{String}, String}})
    sections = String[]
    push!(sections, "# Geographic constants")
    push!(sections, "const WESTERN_BOUNDARY = -100.0")
    push!(sections, "const EASTERN_BOUNDARY = -90.0")
    push!(sections, "const UTAH_EASTERN_BOUNDARY = -111.047")
    push!(sections, "const CASCADE_BOUNDARY = -121.0\n")
    push!(sections, "# GEOID constants for regions")
    
    for (name, (geoids, description)) in sort(collect(constants))
        push!(sections, format_constant(name, geoids, description))
    end
    
    return join(sections, "\n")
end

# Main execution
function main()
    println("Initializing database connection...")
    conn = get_db_connection()
    
    println("Generating GEOID constants...")
    constants = generate_constants(conn)
    
    # Generate constants section
    constants_section = generate_constants_section(constants)
    
    # Write to a temporary file first
    temp_file = "geoid_constants.tmp"
    write(temp_file, constants_section)
    println("Generated constants written to $temp_file")
    println("\nTo update constants.jl, manually review the generated constants")
    println("and then copy the relevant section into src/constants.jl")
    
    close(conn)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end 