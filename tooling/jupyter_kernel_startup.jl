#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Jupyter kernel startup script for Census.jl
# Place this in your Jupyter kernel directory

# Set environment variables
census_dir = expanduser("~/projects/Census.jl")

# Add Census directory to LOAD_PATH if it exists
if isdir(census_dir) && !(census_dir in LOAD_PATH)
    push!(LOAD_PATH, census_dir)
    @info "Added Census.jl to LOAD_PATH"
    
    # Try to preload Census for convenience
    try
        # First load DataFrames and DataFramesMeta
        Core.eval(Main, :(using DataFrames, DataFramesMeta))
        @info "DataFrames and DataFramesMeta loaded"
        
        # Then load Census module
        Core.eval(Main, :(using Census))
        @info "Census module preloaded with DataFrames and DataFramesMeta"
    catch e
        @warn "Census module available but not preloaded" exception=e
        @info "Use 'using Census' to load it"
        
        # Still try to load DataFrames and DataFramesMeta
        try
            Core.eval(Main, :(using DataFrames, DataFramesMeta))
            @info "DataFrames and DataFramesMeta loaded"
        catch df_error
            @warn "Error loading DataFrames or DataFramesMeta" exception=df_error
        end
    end
end

# Print startup message
@info "Census.jl Environment Ready" 