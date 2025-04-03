# SPDX-License-Identifier: MIT

"""
    Great Lakes Region Constants

This module contains constants and functions related to the Great Lakes region.
"""

module GreatLakes

using LibPQ
using DataFrames
using ArchGDAL
using ..Census: DB_HOST, DB_PORT, DB_NAME

# Hardcoded GEOIDs for initialization
const MICHIGAN_PENINSULA_GEOID_LIST = [
    "26053", "26131", "26061", "26083", "26013", "26071", "26103",
    "26003", "26109", "26041", "26053", "26956", "26976", "26033",
    "26043", "26053", "26095", "26097", "20033", "26043", "26053",
    "26153", "26069", "26001", "26007"
]

const METRO_TO_GREAT_LAKES_GEOID_LIST = [
    "36009", "36011", "36013", "36014", "36019",
    "36029", "36031", "36033", "36037", "36041",
    "36043", "36045", "36049", "36051", "36055", "36063", "36065",
    "36067", "36069", "36073", "36075", "36089", "36099", "36117",
    "36121"
]

const GREAT_LAKES_PA_GEOID_LIST = ["42049"]

const GREAT_LAKES_IN_GEOID_LIST = [
    "18127", "18091", "18141", "18039", "18151", "18111", "18073",
    "18149", "18099", "18085", "18113", "18033", "18089", "18087"
]

const GREAT_LAKES_OH_GEOID_LIST = [
    "39055", "39085", "39035", "39103", "39093", "39043", "39077",
    "39033", "39147", "39143", "39123", "39095", "39173", "39063",
    "39007", "39003", "39137", "39065", "39051", "39171", "39069",
    "39161", "39039", "39125", "39175", "39173", "37199"
]

const OHIO_BASIN_IL_GEOID_LIST = [
    "17019", "17183", "17041", "17045", "17029", "17023", "17079",
    "17033", "17159", "17101", "17047", "17165", "17193", "17059",
    "17069", "17151", "17049", "17025", "17191", "17185", "17065",
    "17035", "17075"
]

"""
    get_db_connection() -> LibPQ.Connection

Returns a connection to the Census database.
"""
function get_db_connection()
    return LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
end

"""
    get_michigan_peninsula_geoids() -> Vector{String}

Returns GEOIDs for Michigan's peninsula region counties.
"""
function get_michigan_peninsula_geoids()
    return MICHIGAN_PENINSULA_GEOID_LIST
end

"""
    get_metro_to_great_lakes_geoids() -> Vector{String}

Returns GEOIDs for metropolitan areas connected to the Great Lakes.
"""
function get_metro_to_great_lakes_geoids()
    return METRO_TO_GREAT_LAKES_GEOID_LIST
end

"""
    get_great_lakes_pa_geoids() -> Vector{String}

Returns GEOIDs for Pennsylvania's Great Lakes region counties.
"""
function get_great_lakes_pa_geoids()
    return GREAT_LAKES_PA_GEOID_LIST
end

"""
    get_great_lakes_in_geoids() -> Vector{String}

Returns GEOIDs for Indiana's Great Lakes region counties.
"""
function get_great_lakes_in_geoids()
    return GREAT_LAKES_IN_GEOID_LIST
end

"""
    get_great_lakes_oh_geoids() -> Vector{String}

Returns GEOIDs for Ohio's Great Lakes region counties.
"""
function get_great_lakes_oh_geoids()
    return GREAT_LAKES_OH_GEOID_LIST
end

"""
    get_ohio_basin_il_geoids() -> Vector{String}

Returns GEOIDs for Illinois counties in the Ohio River Basin.
"""
function get_ohio_basin_il_geoids()
    return OHIO_BASIN_IL_GEOID_LIST
end

# Export functions only
export get_michigan_peninsula_geoids,
       get_metro_to_great_lakes_geoids,
       get_great_lakes_pa_geoids,
       get_great_lakes_in_geoids,
       get_great_lakes_oh_geoids,
       get_ohio_basin_il_geoids

end # module GreatLakes 