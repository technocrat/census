# SPDX-License-Identifier: MIT
# Minimal preamble script to avoid precompilation issues
# Run this script for basic functionality without visualization

# Ensure packages are installed
using Pkg
@info "Installing required packages..."
for pkg in ["DataFrames", "DataFramesMeta", "Statistics", "LibPQ", "CSV", "Dates"]
    if !haskey(Pkg.project().dependencies, pkg)
        @info "Adding $pkg"
        Pkg.add(pkg)
    end
end

# Basic imports only
@info "Loading packages..."
using DataFrames
using DataFramesMeta
using Statistics
using LibPQ
using CSV
using Dates

# Database initialization and basic queries
"""
    initialize_county_data() -> DataFrame

Initialize county data by loading it directly from the database.
Returns a DataFrame with basic county information without requiring the full Census module.
"""
function initialize_county_data()
    @info "Connecting to database to load county data..."
    try
        conn = LibPQ.Connection("dbname=tiger")
        
        query = """
            SELECT c.geoid, c.stusps, c.name as county, ST_AsText(c.geom) as geom, vd.value as pop
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

# Filter to specific states (example usage)
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
    @info "$(nrow(state_counties)) counties found in $state_code"
    return state_counties
end

# Example usage
# ca_counties = get_state_counties(counties, "CA")

@info """
Minimal preamble loaded successfully. The following functionality is available:

- counties: DataFrame with all US counties and populations
- get_state_counties(counties, "XX"): Get counties for a specific state code

For visualization and more advanced features, you'll need to load the full Census module:

using CairoMakie, GeoMakie
include(joinpath(dirname(dirname(@__FILE__)), "src/Census.jl"))
using .Census
""" 