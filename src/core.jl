# SPDX-License-Identifier: MIT

# Core functionality for the Census package

using LibPQ

"""
    get_db_connection() -> LibPQ.Connection

Creates a connection to the PostgreSQL database using default parameters.

# Returns
- A `LibPQ.Connection` object representing an active database connection

# Database Parameters
- Host: $DB_HOST
- Port: $DB_PORT
- Database: $DB_NAME
"""
function get_db_connection()
    conn = LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
    return conn
end

# ... existing code ... 