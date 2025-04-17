#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT: test_michigan_peninsula.jl
# Simple script to test Michigan Peninsula GEOIDs

# Define Michigan Peninsula GEOIDs directly
MICHIGAN_PENINSULA_GEOID_LIST = [
    "26003",
    "26013",
    "26033",
    "26041", 
    "26043",
    "26053",
    "26061",
    "26071",
    "26083",
    "26095",
    "26097",
    "26103",
    "26109",
    "26131",
    "26153",
]

println("Michigan Peninsula GEOIDs:")
for geoid in MICHIGAN_PENINSULA_GEOID_LIST
    println(geoid)
end

println("\nTotal: $(length(MICHIGAN_PENINSULA_GEOID_LIST)) counties") 