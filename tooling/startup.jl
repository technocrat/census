#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Julia startup script for Census.jl
# Place this in ~/.julia/config/ directory for automatic loading

# Only run this in interactive sessions
if isinteractive()
    # Set environment variables
    census_dir = expanduser("~/projects/Census.jl")
    
    # Add Census directory to LOAD_PATH if it exists
    if isdir(census_dir) && !(census_dir in LOAD_PATH)
        push!(LOAD_PATH, census_dir)
        println("✅ Added Census.jl to LOAD_PATH")
        
        # Try to preload Census for convenience
        try
            # First load DataFrames and DataFramesMeta to ensure they're available
            @eval using DataFrames, DataFramesMeta
            
            # Then load Census
            @eval using Census
            println("✅ Census module preloaded with DataFrames and DataFramesMeta")
        catch e
            println("⚠️ Census module available but not preloaded")
            println("   Use 'using Census' to load it")
            
            # Still try to load DataFrames and DataFramesMeta
            try
                @eval using DataFrames, DataFramesMeta
                println("✅ DataFrames and DataFramesMeta loaded")
            catch df_error
                println("❌ Error loading DataFrames or DataFramesMeta: $df_error")
            end
        end
    end
    
    # Print startup message
    println("\n=== Census.jl Environment Ready ===")
    println("Run 'using Census' to load the module if not already loaded")
    println("For troubleshooting, run:")
    println("include(\"$(joinpath(census_dir, "fix_package_loading.jl"))\")")
end 