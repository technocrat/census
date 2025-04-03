# SPDX-License-Identifier: MIT

"""
    q(query::String) -> DataFrame

Execute a SQL query against a PostgreSQL database named 'geocoder' and return the results as a DataFrame.

# Arguments
- `query::String`: SQL query string to execute

# Returns
- `DataFrame`: Results of the query converted to a DataFrame

# Connection Details
Connects to PostgreSQL database 'geocoder' with user 'geo'

# Notes
- Creates a new connection for each query
- Connection is automatically closed after query execution due to DataFrame conversion
- Requires LibPQ.jl and DataFrames.jl packages

# Example
```julia
results = q("SELECT * FROM addresses LIMIT 10")
"""
function q(query::String)
    conn = LibPQ.Connection("dbname=geocoder")
    return DataFrame(execute(conn, query))
    close(conn)
end
