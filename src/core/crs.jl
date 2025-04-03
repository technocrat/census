# SPDX-License-Identifier: MIT

"""
    CRS_STRINGS

Dictionary of Coordinate Reference System (CRS) strings for different regions.
Each CRS is optimized for its specific region using Albers Equal Area projection.
"""
const CRS_STRINGS = Dict{String,String}(
    # Pacific Coast (Seattle to Sacramento)
    "pacific_coast" => "+proj=aea +lat_0=43.1 +lon_0=-121.5 +lat_1=38.6 +lat_2=47.6 +datum=NAD83 +units=m +no_defs",
    
    # Southern Florida including Keys
    "florida_south" => "+proj=aea +lat_1=24.33333333333333 +lat_2=26.66666666666667 +lat_0=24.0 +lon_0=-82 +x_0=400000 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs",
    
    # Powell (Colorado River Basin)
    "powell" => "+proj=aea +lat_1=25 +lat_2=47 +lat_0=36 +lon_0=-110 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs",
    
    # Philadelphia Region (Long Island to Chesapeake)
    "metropolis" => "+proj=aea +lat_0=39.95 +lon_0=-75.16 +lat_1=37 +lat_2=43 +datum=NAD83 +units=m +no_defs",
    
    # Dallas Region (100th Meridian to Mississippi)
    "lonestar" => "+proj=aea +lat_0=32.8 +lon_0=-96.8 +lat_1=30 +lat_2=37 +datum=NAD83 +units=m +no_defs",
    
    # Erie Region (Great Lakes)
    "erie" => "+proj=aea +lat_0=42.5 +lon_0=-80.0 +lat_1=41 +lat_2=44 +x_0=0 +y_0=0 +lon_1=-87.0 +lon_2=-73.0 +datum=NAD83 +units=m +no_defs"
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

# Example
```julia
# Get CRS string for the Powell region
crs = get_crs("powell")
```
"""
function get_crs(region::String)::String
    if !haskey(CRS_STRINGS, region)
        throw(KeyError("Region '$region' not found in CRS_STRINGS"))
    end
    return CRS_STRINGS[region]
end

# Export the constants and functions
export CRS_STRINGS, get_crs 