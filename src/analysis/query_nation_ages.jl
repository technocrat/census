# SPDX-License-Identifier: MIT

"""
Functions for querying age-related data at the nation level.
"""

using DataFrames
using .CensusDB: execute

"""
    query_nation_ages(nation_state::String) -> DataFrame

Query age-related data for a specific nation state.

# Arguments
- `nation_state::String`: Name of the nation state

# Returns
- `DataFrame`: Age-related data for the nation state

# Example
```julia
df = query_nation_ages("concord")
```
"""
function query_nation_ages(nation_state::String)
    query = """
        SELECT c.geoid, c.name, v.variable_name, v.value
        FROM census.counties c
        JOIN census.variable_data v ON c.geoid = v.geoid
        WHERE c.nation = \$1
        AND v.variable_name LIKE 'age_%'
        ORDER BY c.geoid, v.variable_name;
    """
    
    result = execute(conn, query, [nation_state])
    return DataFrame(result)
end

export query_nation_ages
