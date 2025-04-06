# SPDX-License-Identifier: MIT

# Core functionality for the Census package

using LibPQ

# Import get_db_connection from Census module
using ..Census: get_db_connection, DB_HOST, DB_PORT, DB_NAME

"""
    valid_codes() -> Vector{String}

Returns a sorted vector of all valid U.S. postal codes.

# Returns
- A vector containing all valid two-letter postal codes for U.S. states and DC

# Examples
```julia
julia> valid_codes()
51-element Vector{String}:
 "AK"
 "AL"
 "AR"
 ⋮
 "WI"
 "WV"
 "WY"
```
"""
function valid_codes()
    return sort(collect(VALID_POSTAL_CODES))
end

# ... existing code ...