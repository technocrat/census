# SPDX-License-Identifier: MIT
# Coordinate Reference System definitions for different regions

"""
    CRS_STRINGS

A collection of Albers Equal Area CRS strings optimized for different regions.
Each CRS is centered on the approximate geographic center of its region.
"""
const CRS_STRINGS = Dict{String,String}(
    # New England (Concordia)
    "concordia" => "+proj=aea +lat_0=44 +lon_0=-70 +lat_1=40 +lat_2=48 +datum=NAD83 +units=m +no_defs",
    
    # Midwest (Metropolis)
    "metropolis" => "+proj=aea +lat_0=38 +lon_0=-85 +lat_1=30 +lat_2=45 +datum=NAD83 +units=m +no_defs",
    
    # Pacific Northwest (Cascadia)
    "cascadia" => "+proj=aea +lat_0=45 +lon_0=-120 +lat_1=40 +lat_2=50 +datum=NAD83 +units=m +no_defs",
    
    # Southwest (Sonora)
    "sonora" => "+proj=aea +lat_0=32 +lon_0=-110 +lat_1=25 +lat_2=40 +datum=NAD83 +units=m +no_defs",
    
    # Southeast (Dixie)
    "dixie" => "+proj=aea +lat_0=32 +lon_0=-85 +lat_1=25 +lat_2=40 +datum=NAD83 +units=m +no_defs",
    
    # Great Plains (Lonestar)
    "lonestar" => "+proj=aea +lat_0=35 +lon_0=-100 +lat_1=30 +lat_2=40 +datum=NAD83 +units=m +no_defs",
    
    # Rocky Mountains (Slope)
    "slope" => "+proj=aea +lat_0=40 +lon_0=-110 +lat_1=35 +lat_2=45 +datum=NAD83 +units=m +no_defs",
    
    # Northeast (Factor)
    "factor" => "+proj=aea +lat_0=42 +lon_0=-75 +lat_1=35 +lat_2=45 +datum=NAD83 +units=m +no_defs",
    
    # Great Lakes (Heart)
    "heart" => "+proj=aea +lat_0=42 +lon_0=-90 +lat_1=35 +lat_2=45 +datum=NAD83 +units=m +no_defs",
    
    # Desert Southwest (Desert)
    "desert" => "+proj=aea +lat_0=35 +lon_0=-115 +lat_1=30 +lat_2=40 +datum=NAD83 +units=m +no_defs",
    
    # Pacific Coast (Pacific)
    "pacific" => "+proj=aea +lat_0=37 +lon_0=-120 +lat_1=32 +lat_2=42 +datum=NAD83 +units=m +no_defs",
    
    # Cumberland Basin (Cumber)
    "cumber" => "+proj=aea +lat_0=36 +lon_0=-85 +lat_1=30 +lat_2=42 +datum=NAD83 +units=m +no_defs",

    # Colorado River Basin (Powell)
    "powell" => "+proj=aea +lat_1=25 +lat_2=47 +lat_0=36 +lon_0=-110 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
)

"""
    get_crs(region::String)::String

Get the CRS string for a specific region.

# Arguments
- `region::String`: Name of the region (must be a key in `CRS_STRINGS`)

# Returns
- `String`: The CRS string for the specified region

# Throws
- `KeyError`: If the region is not found in `CRS_STRINGS`
"""
function get_crs(region::String)::String
    if !haskey(CRS_STRINGS, region)
        throw(KeyError("Region '$region' not found in CRS_STRINGS"))
    end
    return CRS_STRINGS[region]
end

# Export the constants and functions
export CRS_STRINGS, get_crs 