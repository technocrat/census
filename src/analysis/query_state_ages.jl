# SPDX-License-Identifier: MIT

"""
Functions for querying age-related data at the state level.
"""

using DataFrames
using .CensusDB: execute

"""
    query_state_ages(state::String) -> DataFrame

Query age-related data for a specific state.

# Arguments
- `state::String`: State postal code (e.g., "CA" for California)

# Returns
- `DataFrame`: Age-related data for the state

# Example
```julia
df = query_state_ages("CA")
```
"""
function query_state_ages(state::String)
    query = """
        SELECT c.geoid, c.name, v.variable_name, v.value
        FROM census.counties c
        JOIN census.variable_data v ON c.geoid = v.geoid
        WHERE c.stusps = \$1
        AND v.variable_name LIKE 'age_%'
        ORDER BY c.geoid, v.variable_name;
    """
    
    result = execute(conn, query, [state])
    return DataFrame(result)
end

export query_state_ages
