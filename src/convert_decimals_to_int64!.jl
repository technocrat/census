# SPDX-License-Identifier: MIT

# takes a dataframe and coverts any type Decimal columns to type Int64
function convert_decimals_to_int64!(df::DataFrame)
    for col_name in names(df)
        col_type = eltype(df[!, col_name])
        # Check if column contains Decimal values (with or without Missing)
        if col_type <: Decimal || 
           (col_type isa Union && occursin("Decimal", string(col_type)))
            # Convert to Int64 while preserving Missing values
            df[!, col_name] = Int64.(df[!, col_name])
        end
    end
    return df
end