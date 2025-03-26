function make_postal_codes(nation::Vector{String})
    return [PostalCode(state) for state in nation]
end