"""
# Data Processing Module

This module provides functions for data manipulation, type conversion, and formatting.
It includes utilities for handling DataFrames, numeric formatting, and data type conversions.
"""

using DataFrames
using Decimals
using Format

# Constants for data processing
const SMALL_NUMBER_THRESHOLD = 99
const COMMA_SEPARATOR = ","

"""
    convert_decimals_to_int64!(df::DataFrame)

Convert any Decimal columns in a DataFrame to Int64 type.

# Arguments
- `df::DataFrame`: Input DataFrame to modify

# Returns
- The modified DataFrame with Decimal columns converted to Int64

# Notes
- Modifies the DataFrame in-place
- Preserves Missing values
- Handles both pure Decimal and Union{Missing, Decimal} types
"""
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

"""
    filter_dataframes()

Get names of all DataFrame variables in the current namespace.

# Returns
- Vector of Symbol names representing DataFrame variables

# Notes
- Uses Main module to find DataFrame variables
- Useful for debugging and introspection
"""
function filter_dataframes()
    # Get variable names in the current namespace
    df_names = filter(name -> isa(getfield(Main, name), DataFrame), names(Main))
    return df_names
end

"""
    format_with_commas(df::DataFrame)

Convert numeric columns in a DataFrame to strings with comma separators for thousands.

# Arguments
- `df::DataFrame`: Input DataFrame to format

# Returns
- New DataFrame with formatted values, leaving non-numeric columns unchanged

# Features
- Preserves missing values, converting them to the string "missing"
- Adds commas every three digits for readability
- Creates a copy of the input DataFrame to avoid modifying the original
- Only processes columns of type Number or Union{Missing, Number}

# Example
```julia
df = DataFrame(a = [1234, 567, missing], b = ["x", "y", "z"])
formatted_df = format_with_commas(df)
# Result:
# 3×2 DataFrame
#  Row │ a         b      
#      │ String    String 
# ─────┼─────────────────
#    1 │ 1,234    x
#    2 │ 567      y
#    3 │ missing  z
```
"""
function format_with_commas(df::DataFrame)
    formatted_df = copy(df)
    
    for col in names(formatted_df)
        if eltype(df[!, col]) <: Union{Missing, Number}
            formatted_df[!, col] = map(formatted_df[!, col]) do x
                if ismissing(x)
                    "missing"
                elseif abs(x) <= SMALL_NUMBER_THRESHOLD  # Only format numbers > 99 or < -99 with commas
                    string(x)
                else
                    sign_str      = x < 0 ? "-" : ""  # Extract sign for negative numbers
                    num_str       = reverse(string(abs(x)))  # Convert number to string and reverse
                    chunks        = [num_str[i:min(i+2, end)] for i in 1:3:length(num_str)]
                    formatted_num = reverse(join(chunks, COMMA_SEPARATOR))  # Add commas and reverse back
                    sign_str * formatted_num  # Prepend sign if negative
                end
            end
        end
    end
    
    return formatted_df
end

"""
    clean_column_names!(df::DataFrame)

Clean DataFrame column names by removing special characters and converting to lowercase.

# Arguments
- `df::DataFrame`: Input DataFrame to modify

# Returns
- The modified DataFrame with cleaned column names

# Notes
- Modifies the DataFrame in-place
- Replaces spaces and special characters with underscores
- Converts all characters to lowercase
"""
function clean_column_names!(df::DataFrame)
    new_names = map(names(df)) do name
        # Convert to string, replace spaces and special chars with underscores
        clean_name = replace(string(name), r"[^a-zA-Z0-9]+" => "_")
        # Convert to lowercase and remove leading/trailing underscores
        clean_name = strip(lowercase(clean_name), '_')
        Symbol(clean_name)
    end
    rename!(df, new_names)
    return df
end

"""
    remove_empty_columns!(df::DataFrame)

Remove columns that contain only missing values from a DataFrame.

# Arguments
- `df::DataFrame`: Input DataFrame to modify

# Returns
- The modified DataFrame with empty columns removed

# Notes
- Modifies the DataFrame in-place
- A column is considered empty if all values are missing
"""
function remove_empty_columns!(df::DataFrame)
    empty_cols = filter(names(df)) do col
        all(ismissing, df[!, col])
    end
    select!(df, Not(empty_cols))
    return df
end

"""
    standardize_missing!(df::DataFrame; missing_values=[missing, "", "NA", "N/A", "n/a"])

Standardize missing values in a DataFrame to Julia's missing.

# Arguments
- `df::DataFrame`: Input DataFrame to modify
- `missing_values`: Vector of values to treat as missing (default: [missing, "", "NA", "N/A", "n/a"])

# Returns
- The modified DataFrame with standardized missing values

# Notes
- Modifies the DataFrame in-place
- Converts all specified missing values to Julia's missing
- Preserves column types where possible
"""
function standardize_missing!(df::DataFrame; missing_values=[missing, "", "NA", "N/A", "n/a"])
    for col in names(df)
        if eltype(df[!, col]) <: Union{Missing, String}
            df[!, col] = map(df[!, col]) do x
                x in missing_values ? missing : x
            end
        end
    end
    return df
end 