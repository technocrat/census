# Ensure proper package environment
using Pkg
# Get the absolute path to the project directory
project_dir = abspath(joinpath(@__DIR__, ".."))
@info "Project directory: $project_dir" 

# Activate the project
Pkg.activate(project_dir)

# Add ALL required packages for Census.jl
required_pkgs = [
    "HTTP", "JSON3", "GeoInterface", "LibGEOS", "WellKnownGeometry",
    "GeoMakie", "CairoMakie", "Statistics", "DataFrames", "LibPQ",
    "GeoJSON", "GeometryBasics", "ArchGDAL", "DataFramesMeta"
]

# Add all packages to environment
for pkg in required_pkgs
    if !haskey(Pkg.project().dependencies, pkg)
        @info "Adding $pkg to environment"
        Pkg.add(pkg)
    end
end

# Add sister packages to the environment if not already there
breakers_path = expanduser("~/projects/Breakers.jl")
geoids_path = expanduser("~/projects/GeoIDs.jl")

# Develop each package
if !haskey(Pkg.project().dependencies, "Breakers")
    @info "Adding Breakers from $breakers_path"
    Pkg.develop(path=breakers_path)
end

if !haskey(Pkg.project().dependencies, "GeoIDs")
    @info "Adding GeoIDs from $geoids_path"
    Pkg.develop(path=geoids_path)
end

# Instantiate to ensure all packages are installed
Pkg.instantiate()

# Load ALL necessary packages
using DataFrames, DataFramesMeta, CairoMakie, GeoMakie
using StatsBase, Dates, CSV, LibPQ, Statistics
using HTTP, JSON3, GeoInterface, LibGEOS, WellKnownGeometry
using GeometryBasics, ArchGDAL
using Breakers
using GeoIDs

# Load Census module directly by including its main file
census_module_path = joinpath("/Users/technocrat/projects/Census.jl/src", "Census.jl")
@info "Loading Census from $census_module_path"
include(census_module_path)
using .Census


# Optional: Test GeoIDs package functionality to ensure it's working
@info "Testing GeoIDs package functionality..."
if isdefined(Main, :GeoIDs)
    @info "GeoIDs package is properly loaded"
    # Add a test call to a GeoIDs function if needed
else
    @warn "GeoIDs package failed to load properly"
end


