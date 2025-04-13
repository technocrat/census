#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Run this script to fix visualization dependencies in Census.jl

println("Census.jl Visualization Fix Script")
println("==================================")

# First check if we're on macOS
if !Sys.isapple()
    println("This script is designed for macOS. You're running on $(Sys.KERNEL)")
    println("You may need to adapt this script for your system.")
end

println("\nStep 1: Setting environment variables for library paths")
ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "/opt/homebrew/lib:" * get(ENV, "DYLD_FALLBACK_LIBRARY_PATH", "")
ENV["LIBXML2_PATH"] = "/opt/homebrew/lib"
println("✓ Environment variables set")

println("\nStep 2: Installing packages without auto-precompilation")
using Pkg

# Disable automatic precompilation
ENV["JULIA_PKG_PRECOMPILE_AUTO"] = "0"

# Basic packages first
println("Installing core packages...")
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Statistics")
Pkg.add("LibPQ")
Pkg.add("CSV")
Pkg.add("Dates")
Pkg.add("HTTP")
Pkg.add("JSON3")
Pkg.add("GeoInterface")
Pkg.add("LibGEOS")
Pkg.add("WellKnownGeometry")
Pkg.add("GeometryBasics")
Pkg.add("ArchGDAL")
Pkg.add("StatsBase")
Pkg.add("Clustering")
Pkg.add("Colors")

# Now try visualization packages
println("\nInstalling visualization packages...")
for pkg in ["CairoMakie", "GeoMakie"]
    try
        Pkg.add(pkg)
        println("✓ Successfully added $pkg")
    catch e
        println("✗ Failed to add $pkg: $e")
    end
end

println("\nStep 3: Testing visualization packages")
try
    # Try loading visualization packages
    println("Testing if CairoMakie can be loaded...")
    using CairoMakie
    println("✓ CairoMakie loaded successfully")

    println("Testing if GeoMakie can be loaded...")
    using GeoMakie
    println("✓ GeoMakie loaded successfully")

    # Create a basic test plot
    println("\nCreating a test plot...")
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], title="Test Plot")
    scatter!(ax, rand(10), rand(10), color=:blue, markersize=15)
    text!(ax, "Visualization working!", position=(0.5, 0.5), align=(:center, :center), textsize=30)
    
    # Save to a file
    test_file = joinpath(dirname(@__DIR__), "visualization_test.png")
    save(test_file, fig)
    
    if isfile(test_file)
        println("✓ Successfully created and saved a test plot to $test_file")
    else
        println("✗ Failed to save the test plot")
    end
catch e
    println("✗ Visualization test failed: $e")
    println("\nTroubleshooting tips:")
    println("1. Make sure you have installed system dependencies:")
    println("   brew install libxml2 gtk+3 libffi pcre dbus glib")
    println("2. Try running Julia with the DYLD_FALLBACK_LIBRARY_PATH environment variable:")
    println("   DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib julia")
    println("3. Check that your Julia version is compatible with the visualization packages")
end

println("\nStep 4: Creating a visualization-enabled preamble")
viz_preamble = """
# SPDX-License-Identifier: MIT
# Visualization-enabled preamble for Census.jl

# Set library paths for macOS
if Sys.isapple()
    ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "/opt/homebrew/lib:" * get(ENV, "DYLD_FALLBACK_LIBRARY_PATH", "")
    ENV["LIBXML2_PATH"] = "/opt/homebrew/lib"
end

# Basic imports
using DataFrames, DataFramesMeta
using Statistics, StatsBase
using Dates, CSV, LibPQ
using HTTP, JSON3, GeoInterface, LibGEOS, WellKnownGeometry
using GeometryBasics, ArchGDAL

# Try to load visualization packages
viz_loaded = false
try
    @info "Loading visualization packages..."
    using CairoMakie, GeoMakie
    global viz_loaded = true
    @info "Visualization packages loaded successfully!"
catch e
    @warn "Could not load visualization packages" exception=e
end

# Database initialization and basic queries
function initialize_county_data()
    @info "Loading county data from database..."
    try
        conn = LibPQ.Connection("dbname=tiger")
        
        query = \"\"\"
            SELECT c.geoid, c.stusps, c.name as county, c.nation, ST_AsText(c.geom) as geom, vd.value as pop
            FROM census.counties c
            LEFT JOIN census.variable_data vd
                ON c.geoid = vd.geoid
                AND vd.variable_name = 'total_population'
            ORDER BY c.geoid;
        \"\"\"
        
        result = LibPQ.execute(conn, query)
        df = DataFrame(result)
        LibPQ.close(conn)
        
        @info "Loaded \$(nrow(df)) counties from census data"
        return df
    catch e
        @error "Failed to load county data: \$e"
        return DataFrame()
    end
end

# Load county data
@info "Loading county data..."
counties = initialize_county_data()

# Status report
if viz_loaded
    @info "Visualization support is available"
else
    @info "Visualization support is NOT available"
end
"""

viz_preamble_path = joinpath(dirname(@__DIR__), "scripts", "viz_preamble.jl")
write(viz_preamble_path, viz_preamble)
println("✓ Created visualization-enabled preamble at $viz_preamble_path")

println("\nStep 5: Instructions for using visualization")
println("""
To use visualization in your Census.jl scripts:

1. Include the visualization-enabled preamble:
   include("scripts/viz_preamble.jl")

2. Make sure to run Julia with the correct environment variables:
   DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib julia your_script.jl

3. Or use the following line at the top of your scripts:
   if Sys.isapple()
       ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "/opt/homebrew/lib:" * get(ENV, "DYLD_FALLBACK_LIBRARY_PATH", "")
       ENV["LIBXML2_PATH"] = "/opt/homebrew/lib"
   end

4. Test that visualization works with:
   julia -e 'include("scripts/viz_preamble.jl"); if @isdefined(CairoMakie) println("Visualization OK!") end'
""")

println("\nSetup complete!") 