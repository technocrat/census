# SPDX-License-Identifier: MIT

"""
Database connection management for Census package.
"""
module CensusDB

using LibPQ
using Base.Threads

# Connection pool
const MAX_CONNECTIONS = 10
const connection_pool = Channel{LibPQ.Connection}(MAX_CONNECTIONS)
const pool_initialized = Ref(false)

"""
    init_connection_pool()

Initialize the database connection pool with up to MAX_CONNECTIONS connections.
"""
function init_connection_pool()
    if !pool_initialized[]
        @sync for _ in 1:MAX_CONNECTIONS
            @async begin
                conn = LibPQ.Connection("dbname=geocoder")
                put!(connection_pool, conn)
            end
        end
        pool_initialized[] = true
    end
end

"""
    get_connection() -> LibPQ.Connection

Get a connection from the pool. If pool is empty, waits for a connection.
"""
function get_connection()
    take!(connection_pool)
end

"""
    return_connection(conn::LibPQ.Connection)

Return a connection to the pool.
"""
function return_connection(conn::LibPQ.Connection)
    put!(connection_pool, conn)
end

"""
    with_connection(f::Function)

Execute function f with a database connection, ensuring the connection
is returned to the pool afterward.
"""
function with_connection(f::Function)
    conn = get_connection()
    try
        return f(conn)
    finally
        return_connection(conn)
    end
end

"""
    execute(conn::LibPQ.Connection, query::String, params::Vector{Any}=Any[]) -> LibPQ.Result

Execute a SQL query with optional parameters.

# Arguments
- `conn::LibPQ.Connection`: Database connection
- `query::String`: SQL query to execute
- `params::Vector{Any}`: Optional vector of parameters for the query

# Returns
- `LibPQ.Result`: Query result
"""
function execute(conn::LibPQ.Connection, query::String, params::Vector{Any}=Any[])
    LibPQ.execute(conn, query, params)
end

# Clean up connections when module is garbage collected
atexit() do
    while isready(connection_pool)
        close(take!(connection_pool))
    end
end

export init_connection_pool, get_connection, return_connection, with_connection, execute

end # module CensusDB 