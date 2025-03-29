# SPDX-License-Identifier: MIT

# Constants
const VALID_POSTAL_CODES = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
]

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

# Database connection parameters
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

"""
    get_db_connection() -> LibPQ.Connection

Creates a connection to the PostgreSQL database using default parameters.
"""
function get_db_connection()
    conn = LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
    return conn
end

# Structures
struct CensusQuery
    year::Int
    acs_period::String
    variables::Vector{String}
    geography::String
    api_key::String
end

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

# Methods
function valid_codes()
    return sort(collect(VALID_POSTAL_CODES))
end

# Export all public types, constants, and functions
export VALID_POSTAL_CODES,
       postals,
       VALID_STATE_NAMES,
       VALID_STATE_CODES,
       DB_HOST,
       DB_PORT,
       DB_NAME,
       get_db_connection,
       CensusQuery,
       PostalCode,
       valid_codes 