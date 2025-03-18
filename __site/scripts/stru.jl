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