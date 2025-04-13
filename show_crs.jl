#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Load the CRS strings directly from the file
include("src/core/crs.jl")

# Print each CRS string on its own line with the region name
println("CRS STRINGS:")
println("-----------")

# Sort the regions alphabetically for better readability
regions = sort(collect(keys(CRS_STRINGS)))

for region in regions
    crs = CRS_STRINGS[region]
    println("$region:")
    println("  $crs")
    println()
end 