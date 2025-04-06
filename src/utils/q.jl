# SPDX-License-Identifier: MIT

"""
Utility function for executing SQL queries.
"""

using DataFrames
using .CensusDB: execute, with_connection

"""
    q(query::String, params::Vector{Any}=Any[]) -> DataFrame

Execute a SQL query and return the results as a DataFrame.

# Arguments
- `query::String`: SQL query to execute
- `params::Vector{Any}`: Optional vector of parameters for the query

# Returns
- `DataFrame`: Query results

# Example
```julia
df = q("SELECT * FROM census.counties WHERE stusps = \$1", ["CA"])
```
"""
function q(query::String, params::Vector{Any}=Any[])
    with_connection() do conn
        return DataFrame(execute(conn, query, params))
    end
end

export q
