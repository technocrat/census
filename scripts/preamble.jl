# SPDX-License-Identifier: MIT
# Census.jl comprehensive preamble script
# This script provides database access and visualization support

# Configure system library paths for macOS visualization support
if Sys.isapple()
    ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "/opt/homebrew/lib:" * get(ENV, "DYLD_FALLBACK_LIBRARY_PATH", "")
    ENV["LIBXML2_PATH"] = "/opt/homebrew/lib" 
end

# Basic imports
using Pkg
using DataFrames, DataFramesMeta
using Statistics
using LibPQ
using CSV
using Dates

Pkg.activate(joinpath(@__DIR__, ".."))
# First include the Census module
# census_path = "/Users/technocrat/projects/Census.jl/src/Census.jl"
# @info "Census path: $census_path"
# include(census_path)
using Census
# After including, import Census to make its exports available
#import Main.Census
@info "Census module loaded"

# Directly load visualization packages
try
    using CairoMakie, GeoMakie
    using GeometryBasics, WellKnownGeometry
    using ArchGDAL, GeoInterface, LibGEOS
    @info "Visualization packages loaded"
catch e
    @warn "Could not load visualization packages" exception=e
end

# Load GeoIDs package
try
    using GeoIDs
    if isdefined(GeoIDs, :initialize_database)
        GeoIDs.initialize_database()
    end
    @info "GeoIDs loaded and initialized"
catch e
    @warn "Could not load GeoIDs" exception=e
end

# Load Breakers package
try
    using Breakers
    @info "Breakers loaded"
catch e
    @warn "Could not load Breakers" exception=e
end

# Database initialization
"""
    initialize_county_data() -> DataFrame

Initialize county data by loading it directly from the database.
Returns a DataFrame with basic county information.
"""
function initialize_county_data()
    @info "Loading county data from database..."
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
        
        @info "Loaded $(nrow(df)) counties"
        return df
    catch e
        @error "Failed to load county data" exception=e
        return DataFrame()
    end
end

# Load county data
counties = initialize_county_data()

# Initialize census data using Census module if available
if isdefined(Main, :Census)
    us = Census.init_census_data()
    @info "Census data initialized through Census module"
else
    us = counties
    @warn "Census module not available, using direct county data"
end

# Filter to specific states
"""
    get_state_counties(counties::DataFrame, state_code::String) -> DataFrame

Filter the counties DataFrame to a specific state using the state postal code.
"""
function get_state_counties(counties::DataFrame, state_code::String)
    if isempty(counties)
        @warn "County data not loaded"
        return DataFrame()
    end
    
    state_counties = subset(counties, :stusps => ByRow(==(state_code)))
    return state_counties
end

@info "Preamble loaded successfully with Census module"

