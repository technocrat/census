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

project_root = dirname(dirname(dirname(dirname(@__FILE__))))
shapefile_path = joinpath(project_root, "data", "Colorado_River_Basin_County_Boundaries", "Colorado_River_Basin_County_Boundaries.shp")

println("Project root: ", project_root)
println("Shapefile path: ", shapefile_path)
println("File exists: ", isfile(shapefile_path))

# Also print the current directory for reference
println("Current directory: ", pwd()) 