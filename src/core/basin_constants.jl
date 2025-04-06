# SPDX-License-Identifier: MIT

"""
    Basin-specific constants for Census.jl

This file contains constants related to river basins that require the get_geo_pop function.
These constants are defined here to avoid circular dependencies.
"""

"""
    OHIO_BASIN_KY_GEOIDS::Vector{String}

GEOIDs for Kentucky counties in the Ohio River Basin, defined as all Kentucky counties
not in the Mississippi River Basin.
"""
const OHIO_BASIN_KY_GEOIDS = setdiff(get_geo_pop(["KY"]).geoid, MISS_BASIN_KY_GEOIDS)

"""
    OHIO_BASIN_TN_GEOIDS::Vector{String}

GEOIDs for Tennessee counties in the Ohio River Basin, defined as all Tennessee counties
not in the Mississippi River Basin.
"""
const OHIO_BASIN_TN_GEOIDS = setdiff(get_geo_pop(["TN"]).geoid, MISS_BASIN_TN_GEOIDS) 