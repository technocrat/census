# SPDX-License-Identifier: MIT
# Visualization-enabled preamble for Census.jl
# This script properly sets library paths to find system libraries

# First, ensure the system can find libxml2
if Sys.isapple()
    # Add Homebrew lib directory to dynamic library path
    ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "/opt/homebrew/lib:" * get(ENV, "DYLD_FALLBACK_LIBRARY_PATH", "")
    
    # Explicitly set the path to the libxml2 libraries
    ENV["LIBXML2_PATH"] = "/opt/homebrew/lib"
    
    @info "Set macOS library paths to include Homebrew libraries"
end

# Basic imports 
using Pkg
using DataFrames
using DataFramesMeta
using Statistics
using LibPQ
using CSV
using Dates

# Try to load visualization packages
viz_loaded = false
try
    @info "Attempting to load visualization packages..."
    using CairoMakie, GeoMakie
    viz_loaded = true
    @info "Successfully loaded visualization packages!"
catch e
    @warn "Failed to load visualization packages" exception=e
    @info """
    To fix visualization packages:
    1. Install system dependencies:
       brew install libxml2
       
    2. If that doesn't work, try:
       brew install gtk+3 libffi pcre dbus glib
    """
end

# Initialize county data
function initialize_county_data()
    @info "Connecting to database to load county data..."
    try
        conn = LibPQ.Connection("dbname=tiger")
        
        query = """
            SELECT c.geoid, c.stusps, c.name as county, c.nation, ST_AsText(c.geom) as geom, vd.value as pop
            FROM census.counties c
            LEFT JOIN census.variable_data vd
                ON c.geoid = vd.geoid
                AND vd.variable_name = 'total_population'
            ORDER BY c.geoid;
        """
        
        result = LibPQ.execute(conn, query)
        df = DataFrame(result)
        LibPQ.close(conn)
        
        @info "Loaded $(nrow(df)) counties from census data"
        return df
    catch e
        @error "Failed to load county data: $e"
        return DataFrame()
    end
end

# Load county data
@info "Loading county data..."
counties = initialize_county_data()

# Filter to specific states
function get_state_counties(counties::DataFrame, state_code::String)
    if isempty(counties)
        @warn "County data not loaded"
        return DataFrame()
    end
    
    state_counties = subset(counties, :stusps => ByRow(==(state_code)))
    @info "$(nrow(state_counties)) counties found in $state_code"
    return state_counties
end

# Try to load Census.jl if visualization packages loaded successfully
census_loaded = false
if viz_loaded
    try
        @info "Attempting to load full Census module..."
        include(joinpath(dirname(dirname(@__FILE__)), "src/Census.jl"))
        using .Census
        census_loaded = true
        @info "Successfully loaded Census module with visualization support!"
    catch e
        @warn "Failed to load Census module" exception=e
    end
end

# Status report
if viz_loaded && census_loaded
    @info "All functionality loaded successfully including visualization"
elseif viz_loaded
    @info "Visualization packages loaded but Census module failed"
else
    @info "Using basic functionality without visualization"
end 