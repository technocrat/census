# SPDX-License-Identifier: MIT

# Core functionality for the Census package

using LibPQ

# Import get_db_connection from Census module
import Census: get_db_connection

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

"""
    is_valid_postal_code(code::AbstractString) -> Bool

Check if a given string is a valid U.S. postal code.

# Arguments
- `code::AbstractString`: The postal code to validate

# Returns
- `true` if the code is valid, `false` otherwise

# Examples
```julia
julia> is_valid_postal_code("CA")
true

julia> is_valid_postal_code("XX")
false
```
"""
function is_valid_postal_code(code::AbstractString)
    return uppercase(code) ∈ VALID_POSTAL_CODES
end

"""
    get_state_name(code::AbstractString) -> String

Get the full state name for a given postal code.

# Arguments
- `code::AbstractString`: A valid U.S. postal code

# Returns
- The full state name as a string

# Throws
- `ArgumentError` if the code is not valid

# Examples
```julia
julia> get_state_name("CA")
"California"

julia> get_state_name("XX")
ERROR: ArgumentError: Invalid postal code: XX
```
"""
function get_state_name(code::AbstractString)
    if !is_valid_postal_code(code)
        throw(ArgumentError("Invalid postal code: $code"))
    end
    return VALID_STATE_NAMES[uppercase(code)]
end

"""
    get_postal_code(state_name::AbstractString) -> String

Get the postal code for a given state name.

# Arguments
- `state_name::AbstractString`: The full name of a U.S. state

# Returns
- The two-letter postal code as a string

# Throws
- `ArgumentError` if the state name is not valid

# Examples
```julia
julia> get_postal_code("California")
"CA"

julia> get_postal_code("Not a State")
ERROR: ArgumentError: Invalid state name: Not a State
```
"""
function get_postal_code(state_name::AbstractString)
    if state_name ∉ keys(VALID_STATE_CODES)
        throw(ArgumentError("Invalid state name: $state_name"))
    end
    return VALID_STATE_CODES[state_name]
end 