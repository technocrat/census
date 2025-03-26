# SPDX-License-Identifier: MIT
using Census
using HTTP
using JSON3
using DataFrames
using URIs

struct CensusQuery
    year::Int
    acs_period::String
    variables::Vector{String}
    geography::String
    api_key::String
end

function CensusQuery(;
    year::Int=2023,
    acs_period::String="5",
    variables::Vector{String}=["S0101_C01_001E"],
    geography::String="county",
    api_key::String=ENV["CENSUS_API_KEY"]
)
    CensusQuery(year, acs_period, variables, geography, api_key)
end

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

function get_census_data(; kwargs...)
    query = CensusQuery(; kwargs...)
    fetch_census_data(query)
end
