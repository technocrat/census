# SPDX-License-Identifier: MIT
using Census

# Test the path construction
project_root = dirname(dirname(dirname(dirname(@__FILE__))))
shapefile_path = joinpath(project_root, "data", "Colorado_River_Basin_County_Boundaries", "Colorado_River_Basin_County_Boundaries.shp")

println("Project root: ", project_root)
println("Shapefile path: ", shapefile_path)
println("File exists: ", isfile(shapefile_path))

# Also print the current directory for reference
println("Current directory: ", pwd()) 