# SPDX-License-Identifier: MIT

"""
Census.jl Module (No Visualization Version)

Main module for the Census.jl package, providing functions for working with 
US Census data, with visualization dependencies removed for compatibility.

## Module Export Policy
While Census.jl aims to export all necessary functions and types to allow using 
only `using Census`, some Julia-specific limitations with complex reexports may 
require direct imports in scripts for reliable operation.

### For Scripts
In scripts (files outside the package), it's recommended to:
1. Import Census: `using Census`
2. Directly import DataFrames/DataFramesMeta as needed: `using DataFrames, DataFramesMeta`

See the `create_script` function to generate a properly configured script template.
"""
module Census

# Standard imports
using DataFrames
using HTTP
using JSON3
using Base.Iterators: partition
using Statistics: mean
using Dates: Year, today
using GeoInterface
# Visualization packages removed
# using CairoMakie: Figure, save, display, text!, CairoMakie
# using GeoMakie: GeoAxis, poly!, DataAspect, GeoMakie
using LibGEOS
using WellKnownGeometry
using LibPQ
using DataFramesMeta  # Add this for the subset function
using Clustering      # For data binning functionality
using StatsBase       # For data binning functionality
import Breakers       # For data binning functionality
using ArchGDAL
using GeometryBasics: Point2f, Polygon, GeometryBasics
using Dates
# using Plots  # Visualization package removed

# Include core functionality first
include("core/core.jl")
include("core/constants.jl")
include("core/acs.jl")
include("core/db.jl")
include("core/ClassInt.jl")  # Our pure Julia implementation of ClassInt
include("core/crs.jl")       # CRS strings for different regions
include("core/geoids.jl")    # Nation state geoid management

# Include analysis module
include("analysis/Analysis.jl")

# Include geographic functionality first to define key functions
include("geo/geo.jl")
# Skip visualization modules to avoid dependency issues
# include("geo/map_poly.jl")
# include("viz/viz.jl")  # Fixed path to viz.jl

# Include other utility functions after geo functions to prevent overwrites
include("core/util.jl")      # Utility functions for working with census data

# Define the init_census_data function directly in the Census module
"""
    init_census_data() -> DataFrame

Initialize census data by loading county-level information.

# Returns
- `DataFrame`: A DataFrame containing county data with the following columns:
  - `geoid::String`: FIPS code for the county
  - `stusps::String`: State postal code
  - `county::String`: County name (renamed from 'name')
  - `geom::String`: WKT geometry string
  - `pop::Int`: Total population

# Example
```julia
us = init_census_data()
# Filter to specific state
ca = subset(us, :stusps => ByRow(==("CA")))
```

# Notes
- This function queries the census.counties and census.variable_data tables
- It uses a database connection from LibPQ
- Returns all counties in the United States with their population data
- Automatically renames the 'name' column to 'county' for consistency
"""
function init_census_data()
    conn = LibPQ.Connection("dbname=tiger")
    
    query = """
        SELECT c.geoid, c.stusps, c.name, c.nation, ST_AsText(c.geom) as geom, vd.value as pop
        FROM census.counties c
        LEFT JOIN census.variable_data vd
            ON c.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        ORDER BY c.geoid;
    """
    
    result = LibPQ.execute(conn, query)
    df = DataFrame(result)
    LibPQ.close(conn)
    
    # Rename 'name' column to 'county'
    rename!(df, :name => :county)
    
    return df
end

"""
    create_script(filename::AbstractString; overwrite::Bool=false) -> String

Create a new script file with the proper imports and environment setup.

# Arguments
- `filename::AbstractString`: Name of the script file to create
- `overwrite::Bool=false`: Whether to overwrite an existing file

# Returns
- `String`: Path to the created script file

# Example
```julia
# Create a new script
path = create_script("my_analysis.jl") 
```

# Notes
- Creates the script in the scripts/ directory
- Includes proper imports and environment variables
- Sets up init_census_data call
"""
function create_script(filename::AbstractString; overwrite::Bool=false)
    # Ensure filename ends with .jl
    if !endswith(filename, ".jl")
        filename = filename * ".jl"
    end
    
    # Construct full path
    scripts_dir = joinpath(dirname(dirname(@__FILE__)), "scripts")
    if !isdir(scripts_dir)
        mkdir(scripts_dir)
    end
    
    filepath = joinpath(scripts_dir, filename)
    
    # Check if file exists
    if isfile(filepath) && !overwrite
        error("File $filepath already exists. Use overwrite=true to replace it.")
    end
    
    # Script template
    template = """
    #!/usr/bin/env julia
    # SPDX-License-Identifier: MIT
    # SCRIPT
    
    # Use proper package resolution when running from within the package directory
    using Pkg
    Pkg.activate(".")  # Activate the current package environment
    
    # Import Census module (exports all necessary functions)
    using Census
    
    # Initialize census data
    us = init_census_data()
    println("Loaded \$(nrow(us)) counties")
    
    # Your analysis code goes here
    # ...
    
    # Example: Filter to specific state
    # ca = subset(us, :stusps => ByRow(==("CA")))
    # println("California has \$(nrow(ca)) counties")
    """
    
    # Write the file
    write(filepath, template)
    
    return filepath
end

# Placeholder function for map_poly to avoid dependencies 
function map_poly(args...; kwargs...)
    error("Visualization functionality is disabled in this version. Please use the full Census module with CairoMakie and GeoMakie for visualization features.")
end

# Re-export functions from ClassInt module
using .ClassInt: get_breaks, get_breaks_dict

# Re-export functions from Analysis module
using .Analysis: get_us_ages,
                make_growth_table,
                make_nation_state_gdp_df,
                make_nation_state_pop_df,
                ga,
                collect_state_age_dataframes,
                get_childbearing_population,
                get_dem_vote,
                get_gop_vote,
                get_nation_state,
                get_state_pop,
                process

# Export functions from core modules
export get_acs_moe,
       get_acs_moe1,
       get_acs_moe3,
       get_acs_moe5,
       make_census_request,
       get_moe_factor,
       is_special_moe,
       get_special_moe_message,
       add_moe_notes!,
       join_estimates_moe!,
       calculate_moe_sum,
       calculate_moe_ratio,
       calculate_moe_product,
       state_postal_to_fips,
       map_poly

# Export only necessary non-visualization libraries
# export Figure, save, display, GeoMakie, CairoMakie, GeoAxis, poly!, text!, DataAspect
export GeometryBasics, Point2f, Polygon
export ArchGDAL
export Dates #, Plots  # Remove Plots export
export GeoIDs

# Export CRS functionality
export CRS_STRINGS, get_crs, show_crs

# Export directory constants
export DATA_DIR, CACHE_DIR, PLOT_DIR

# Re-export Analysis module functions
export get_us_ages,
       make_growth_table,
       make_nation_state_gdp_df,
       make_nation_state_pop_df,
       ga,
       collect_state_age_dataframes,
       get_childbearing_population,
       get_dem_vote,
       get_gop_vote,
       get_nation_state,
       get_state_pop,
       process

# Export ClassInt functions
export get_breaks, get_breaks_dict

# Export Breakers module itself
export Breakers

# Export utility functions
export get_geo_pop, customcut, list_geoid_sets

# Export initialization functions
export init_census_data
export create_script

# Export DataFramesMeta functions for convenience
export subset, @with, @select, @transform

# Export commonly used DataFrames functions
export DataFrame, 
       combine, 
       select, 
       groupby, 
       innerjoin, 
       leftjoin, 
       rightjoin, 
       outerjoin, 
       dropmissing, 
       filter, 
       sort!, 
       rename!, 
       transform!, 
       describe, 
       nrow, 
       ncol, 
       names, 
       eachrow, 
       eachcol,
       ByRow  # Important for the ByRow transformer

# Export geoids management functions
export set_nation_state_geoids

# Export nation state constants
export CONCORD, METROPOLIS, FACTORIA, LONESTAR, DIXIE, CUMBER, HEARTLAND, DESERT, PACIFIC, SONORA
export NATIONS, NATION_LISTS, TITLES, NATION_STATES, NATION_ABBREVIATIONS

# Export visualization constants and functions
export PLOT_DIR#, save_plot  # Removed save_plot since it depends on visualization

# Export Dates.now function explicitly
export now  # Explicitly export Dates.now

end # module Census