# SPDX-License-Identifier: MIT

# Constants for the Census package

"""
    VALID_POSTAL_CODES::Vector{String}

A vector containing all valid two-letter postal codes for U.S. states and the District of Columbia.
"""
const VALID_POSTAL_CODES = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
]

# Transrockies counties in Montana
const west_montana = ["30023", "30029", "30039", "30047", "30053",
                      "30061", "30063", "30081", "30089", "30093"]

                      # Define postals as an alias for VALID_POSTAL_CODES for backward compatibility
const postals = VALID_POSTAL_CODES

const VALID_STATE_NAMES = Dict(
    "AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas",
    "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware",
    "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho",
    "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas",
    "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland",
    "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi",
    "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada",
    "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York",
    "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma",
    "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina",
    "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah",
    "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia",
    "WI" => "Wisconsin", "WY" => "Wyoming", "DC" => "District of Columbia"
)

const VALID_STATE_CODES = Dict(
    "Alabama" => "AL", "Alaska" => "AK", "Arizona" => "AZ", "Arkansas" => "AR",
    "California" => "CA", "Colorado" => "CO", "Connecticut" => "CT", "Delaware" => "DE",
    "Florida" => "FL", "Georgia" => "GA", "Hawaii" => "HI", "Idaho" => "ID",
    "Illinois" => "IL", "Indiana" => "IN", "Iowa" => "IA", "Kansas" => "KS",
    "Kentucky" => "KY", "Louisiana" => "LA", "Maine" => "ME", "Maryland" => "MD",
    "Massachusetts" => "MA", "Michigan" => "MI", "Minnesota" => "MN", "Mississippi" => "MS",
    "Missouri" => "MO", "Montana" => "MT", "Nebraska" => "NE", "Nevada" => "NV",
    "New Hampshire" => "NH", "New Jersey" => "NJ", "New Mexico" => "NM", "New York" => "NY",
    "North Carolina" => "NC", "North Dakota" => "ND", "Ohio" => "OH", "Oklahoma" => "OK",
    "Oregon" => "OR", "Pennsylvania" => "PA", "Rhode Island" => "RI", "South Carolina" => "SC",
    "South Dakota" => "SD", "Tennessee" => "TN", "Texas" => "TX", "Utah" => "UT",
    "Vermont" => "VT", "Virginia" => "VA", "Washington" => "WA", "West Virginia" => "WV",
    "Wisconsin" => "WI", "Wyoming" => "WY", "District of Columbia" => "DC"
)

# Nation state mappings
const NATION_ABBREVIATIONS = Dict(
    "cumber" => "Cumberland",
    "dixie" => "New Dixie",
    "lonestar" => "The Lone Star Republic",
    "metropolis" => "Metropolis",
    "heartland" => "Heartlandia",
    "factoria" => "Factoria",
    "desert" => "Deseret",
    "sonora" => "New Sonora",
    "concord" => "Concordia",
    "pacifica" => "Pacifica"
)

# Nation state definitions
const NATION_STATES = Dict(
    "concord" => ["CT", "MA", "ME", "NH", "RI", "VT"],
    "cumber" => ["WV", "KY", "TN"],
    "desert" => ["UT", "MT", "WY", "CO", "ID"],
    "dixie" => ["NC", "SC", "FL", "GA", "MS", "AL"],
    "factoria" => ["PA", "OH", "MI", "IN", "IL", "WI"],
    "heartland" => ["MN", "IA", "NE", "ND", "SD", "KS", "MO"],
    "lonestar" => ["TX", "OK", "AR", "LA"],
    "metropolis" => ["DE", "MD", "NY", "NJ", "VA", "DC"],
    "pacific" => ["WA", "OR", "AK"],
    "sonora" => ["CA", "AZ", "NM", "NV", "HI"]
)

# Database connection parameters
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

"""
    CensusQuery

A structure representing a query to the Census API.

# Fields
- `year::Int`: The census year to query
- `acs_period::String`: The ACS period (e.g., "1" for 1-year estimates, "5" for 5-year estimates)
- `variables::Vector{String}`: Census variable codes to retrieve
- `geography::String`: Geographic level for the query (e.g., "state", "county")
- `api_key::String`: Census API key for authentication
"""
struct CensusQuery
    year::Int
    acs_period::String
    variables::Vector{String}
    geography::String
    api_key::String
end

"""
    PostalCode

A type representing a valid U.S. postal code.

# Fields
- `code::String`: A two-letter postal code

# Constructor
    PostalCode(code::AbstractString)

Creates a new `PostalCode` instance. Throws an `ArgumentError` if the code is not valid.

# Examples
```julia
julia> pc = PostalCode("CA")
CA

julia> pc = PostalCode("XX")  # Throws ArgumentError
ERROR: ArgumentError: Invalid postal code: XX. Must be one of the 51 valid US postal codes.
```
"""
struct PostalCode
    code::String 
    function PostalCode(code::AbstractString)
        uppercase_code = uppercase(code)
        if uppercase_code ∉ VALID_POSTAL_CODES
            throw(ArgumentError("Invalid postal code: $(code). Must be one of the 51 valid US postal codes."))
        end
        new(uppercase_code)
    end
end

# Base method extensions for PostalCode
Base.string(pc::PostalCode) = pc.code
Base.show(io::IO, pc::PostalCode) = print(io, pc.code)
Base.:(==)(a::PostalCode, b::PostalCode) = a.code == b.code
Base.hash(pc::PostalCode, h::UInt) = hash(pc.code, h)

"""
    US_POSTALS

Vector of all US state postal codes, including territories.
"""
const US_POSTALS = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
    "DC", "PR", "VI", "GU", "AS", "MP"
] 