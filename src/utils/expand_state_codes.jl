# SPDX-License-Identifier: MIT

"""
    expand_state_codes(stusps::Vector{String}) -> Vector{String}

Convert state postal codes to full state names.

# Arguments
- `stusps::Vector{String}`: Vector of state postal codes (e.g., ["CA", "NY"])

# Returns
- Vector{String}: Vector of full state names (e.g., ["California", "New York"])

# Example
```julia
expand_state_codes(["CA", "NY"])  # Returns ["California", "New York"]
```
"""
function expand_state_codes(stusps::Vector{String})
	return [VALID_STATE_NAMES[state] for state in stusps]
end
