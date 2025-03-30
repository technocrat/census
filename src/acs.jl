# SPDX-License-Identifier: MIT

"""
    CensusQuery(;
        year::Int=2023,
        acs_period::String="5",
        variables::Vector{String}=["S0101_C01_001E"],
        geography::String="county",
        api_key::String=ENV["CENSUS_API_KEY"]
    ) -> CensusQuery

Create a CensusQuery object with default parameters for accessing the Census API.

# Keyword Arguments
- `year::Int=2023`: Census year to query
- `acs_period::String="5"`: ACS period ("1" or "5" for 1-year or 5-year estimates)
- `variables::Vector{String}=["S0101_C01_001E"]`: Census variable codes to retrieve
- `geography::String="county"`: Geographic level ("state", "county", etc.)
- `api_key::String=ENV["CENSUS_API_KEY"]`: Census API key from environment

# Returns
- `CensusQuery`: A configured query object for Census API requests

# Example
```julia
# Basic query with defaults
query = CensusQuery()

# Custom query for state-level median income
query = CensusQuery(
    year = 2022,
    variables = ["B19013_001E"],
    geography = "state"
)
```

# Notes
- Defaults to total population variable (S0101_C01_001E)
- Requires CENSUS_API_KEY environment variable
- Uses most recent ACS 5-year estimates by default
"""
function CensusQuery(;
    year::Int=2023,
    acs_period::String="5",
    variables::Vector{String}=["S0101_C01_001E"],
    geography::String="county",
    api_key::String=ENV["CENSUS_API_KEY"]
)
    CensusQuery(year, acs_period, variables, geography, api_key)
end

"""
    build_census_query(q::CensusQuery) -> String

Build a Census API URL from a CensusQuery object.

# Arguments
- `q::CensusQuery`: Query configuration object

# Returns
- `String`: Complete URL for Census API request

# URL Structure
- Base: https://api.census.gov/data/
- Path: {year}/acs/acs{period}/subject
- Parameters:
  - get: NAME and requested variables
  - for: geographic level
  - key: API key

# Example
```julia
query = CensusQuery(year=2022, variables=["B19013_001E"])
url = build_census_query(query)
# Returns: "https://api.census.gov/data/2022/acs/acs5/subject?get=NAME,B19013_001E&for=county:*&key=..."
```

# Notes
- Uses the Subject Tables API endpoint
- Automatically includes NAME field in results
- Requests all areas (*) for specified geography
"""
function build_census_query(q::CensusQuery)
    forepart = "https://api.census.gov/data/"
    typepart = "acs/"
    gluepart = "subject?get=NAME,"
    addnglue = "&for="
    selector = ":*&key="

    string(
        forepart,
        q.year, "/",
        typepart,
        "acs", q.acs_period, "/",
        gluepart,
        join(q.variables, ","),
        addnglue,
        q.geography,
        selector,
        q.api_key
    )
end

"""
    fetch_census_data(query::CensusQuery) -> DataFrame

Fetch and parse data from the Census API using a CensusQuery configuration.

# Arguments
- `query::CensusQuery`: Query configuration object

# Returns
- `DataFrame`: Processed Census data with columns:
  - `NAME`: Area name
  - `S0101_C01_001E`: Requested variable values (as Int64)
  - `state`: State FIPS code
  - `county`: County FIPS code
  - `GEOID`: Combined state and county FIPS code

# Processing Steps
1. Builds API URL from query
2. Makes HTTP GET request
3. Parses JSON response
4. Converts to DataFrame
5. Adds GEOID column

# Example
```julia
query = CensusQuery()
df = fetch_census_data(query)
```

# Notes
- Handles JSON array format from Census API
- Converts numeric strings to Int64
- Creates GEOID by concatenating state and county codes
- Requires active internet connection
"""
function fetch_census_data(query::CensusQuery)
    url = build_census_query(query)
    response = HTTP.get(URI(url))
    json_data = JSON3.read(String(response.body))

    headers = Symbol.(Vector(json_data[1]))
    rows = Vector(json_data[2:end])

    df = DataFrame(
        NAME=[row[1] for row in rows],
        S0101_C01_001E=parse.(Int64, [row[2] for row in rows]),
        state=[row[3] for row in rows],
        county=[row[4] for row in rows]
    )
    df.GEOID = df.state .* df.county
    return df
end

"""
    get_census_data(; kwargs...) -> DataFrame

Convenience function to create a CensusQuery and fetch data in one step.

# Keyword Arguments
Same as CensusQuery constructor:
- `year::Int=2023`: Census year
- `acs_period::String="5"`: ACS period
- `variables::Vector{String}=["S0101_C01_001E"]`: Census variables
- `geography::String="county"`: Geographic level
- `api_key::String=ENV["CENSUS_API_KEY"]`: API key

# Returns
- `DataFrame`: Census data (see fetch_census_data for details)

# Example
```julia
# Get county population estimates
df = get_census_data(
    year = 2022,
    variables = ["S0101_C01_001E"],
    geography = "county"
)
```

# Notes
- Combines CensusQuery creation and data fetching
- Uses default values if not specified
- Requires CENSUS_API_KEY environment variable
"""
function get_census_data(; kwargs...)
    query = CensusQuery(; kwargs...)
    fetch_census_data(query)
end
