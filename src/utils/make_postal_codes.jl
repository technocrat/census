"""
    make_postal_codes(nation::Vector{String}) -> Vector{PostalCode}

Takes a vector of state names or postal codes and returns a vector of PostalCode objects.
Each state name/code is validated against VALID_STATE_NAMES and VALID_POSTAL_CODES.

# Arguments
- `nation::Vector{String}`: Vector of state names or postal codes

# Returns
- `Vector{PostalCode}`: Vector of PostalCode objects

# Example
```julia
states = ["California", "NY", "Texas"]
postal_codes = make_postal_codes(states)
```
"""
function make_postal_codes(nation::Vector{String})
    # Validate each state against known valid states
    valid_states = filter(state -> state in VALID_STATE_NAMES || state in VALID_POSTAL_CODES, nation)
    return [PostalCode(state) for state in valid_states]
end

export make_postal_codes