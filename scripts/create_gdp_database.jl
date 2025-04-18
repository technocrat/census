# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

"""
GDP Database Creation Module

This module creates and populates a PostgreSQL database table with GDP data for all states,
with special handling for New England states. It processes county-level GDP data and includes
Connecticut planning region GDP data.

# Dependencies
- Census: Custom package for Census data processing
- CSV: File I/O for CSV files
- DataFrames: Data manipulation and analysis
- LibPQ: PostgreSQL database connectivity

# Files Used
- Input:
  - obj/state_and_county_gdp.csv: County-level GDP data for all states
  - obj/ct_gdp.csv: Connecticut planning region GDP data
- Output:
  - obj/ne_gdp.csv: New England GDP data
  - PostgreSQL table: gdp
"""

using CSV
using LibPQ
using .CensusDB: execute, with_connection

"""
    create_gdp_database()

Create and populate a PostgreSQL database table with GDP data for all states and territories.

# Processing Steps
1. Reads and processes county-level GDP data
2. Handles special case for New England states
3. Incorporates Connecticut planning region GDP data
4. Creates PostgreSQL table with proper indices
5. Populates table with processed data

# Database Schema
- Table: gdp
  - county: VARCHAR(100), part of primary key
  - gdp: NUMERIC(20, 2), GDP value in thousands
  - state: VARCHAR(50), part of primary key
  - is_county: BOOLEAN, indicates if the record is a county or state
- Indices:
  - Primary key on (county, state)
  - Secondary index on state

# Notes
- GDP values are in thousands of dollars in source data
- Special handling for Richmond City/County disambiguation in Virginia
- New England states have separate processing for regional planning areas
- Records are classified as counties or states using VALID_STATE_CODES
"""
function create_gdp_database()
    # Get project root directory
    project_root = dirname(dirname(@__FILE__))

    # Read and process main GDP data
    gdp = CSV.read(joinpath(project_root, "obj", "state_and_county_gdp.csv"), DataFrame)
    gdp = select(gdp, :county, :GDP)
    # remove footnotes
    deleteat!(gdp, [3217, 3218])
    
    # Add is_county flag and handle state records
    gdp.is_county = trues(nrow(gdp))
    gdp.state = fill("", nrow(gdp))
    for i in 1:nrow(gdp)
        if gdp.county[i] in keys(Census.VALID_STATE_CODES)
            gdp.is_county[i] = false
            state_code = Census.VALID_STATE_CODES[gdp.county[i]]
            gdp.state[i] = gdp.county[i]
            gdp.county[i] = state_code
        end
    end
    
    include(joinpath(project_root, "src", "fill_state.jl"))
    rename!(gdp, [:locale, :gdp, :is_county, :state])
    fill_state!(gdp)
    gdp = gdp[gdp.is_county, :]
    gdp = gdp[:, [1, 2, 4]]
    gdp.gdp = gdp.gdp .* 1e3

    # # Process New England states
    # ne = ["CT", "ME", "MA", "NH", "RI", "VT"]  # New England states subset
    # ne_gdp = gdp[in.(gdp.state, Ref(ne)), :]
    
    # Add Connecticut planning region data
    ct_gdp = subset(gdp, :state => ByRow(x -> x == "CT"))
    deleteat!(ct_gdp, nrow(ct_gdp))  # Remove empty state row
    ct_gdp = ct_gdp[:, [1, 2]]  
    rename!(ct_gdp, [:county, :gdp])
    ct_gdp.state = fill("Connecticut", nrow(ct_gdp))
    ct_gdp.is_county = trues(nrow(ct_gdp))  # Connecticut regions are treated as counties

    
    # # Save New England GDP data
    # CSV.write(joinpath(project_root, "obj", "ne_gdp.csv"), ne_gdp)
    
    # Process remaining states
    gdp = filter(:state => x -> x != "CT",gdp)

    
    # Rename Richmond City (largest GDP Richmond jurisdiction)
    richmond_mask = (gdp.locale .== "Richmond") .& (gdp.gdp .> 20_000_000_000)
    gdp.county[richmond_mask] .= "Richmond City"
    gdp = gdp[:, [1,2]]
    rename!(gdp, [:county, :gdp])
    ct_gdp = ct_gdp[:, [1, 2]]  
    gdp = vcat(gdp, ct_gdp)

    # Create and populate database
    with_connection() do conn
        # Create table
        execute(conn, """
            CREATE TABLE IF NOT EXISTS census.gdp (
                county character varying(100),
                gdp numeric,
                state character varying(2),
                is_county boolean,
                created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (county, state)
            );
            CREATE INDEX IF NOT EXISTS idx_gdp_state ON census.gdp(state);
        """)

        # Insert or update data
        for row in eachrow(gdp)
            stmt = """
            INSERT INTO census.gdp (county, gdp, state, is_county)
            VALUES (\$1, \$2, \$3, \$4)
            ON CONFLICT (county, state) 
            DO UPDATE SET 
                gdp = EXCLUDED.gdp,
                is_county = EXCLUDED.is_county;
            """
            execute(conn, stmt, [row.county, row.gdp, row.state, row.is_county])
        end
    end
    
    return gdp
end

# Execute the database creation
create_gdp_database()

