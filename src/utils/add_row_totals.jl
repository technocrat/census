# SPDX-License-Identifier: MIT

"""
    add_row_totals(df::DataFrame; total_row_name="Total", cols_to_sum=nothing) -> DataFrame

Add a row of totals to a DataFrame. Returns a new DataFrame with the totals row appended.

# Arguments
- `df::DataFrame`: Input DataFrame

# Keywords
- `total_row_name::String="Total"`: Label for the totals row in non-numeric columns
- `cols_to_sum::Union{Nothing,Vector{String}}=nothing`: Specific columns to sum. If nothing, sums all numeric columns

# Returns
- `DataFrame`: New DataFrame with totals row appended

# Example
```julia
df = DataFrame(
    region = ["North", "South"],
    sales = [100, 200],
    units = [10, 20]
)
df_with_totals = add_row_totals(df)
```

# Notes
- Missing values are skipped when calculating sums
- Non-numeric columns get the total_row_name value
- Original DataFrame is not modified
"""
function add_row_totals(df::DataFrame; 
                      total_row_name::String="Total",
                      cols_to_sum::Union{Nothing,Vector{String}}=nothing)
    
    # Input validation
    if isempty(df)
        throw(ArgumentError("DataFrame must not be empty"))
    end
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    else
        # Validate specified columns exist
        missing_cols = setdiff(cols_to_sum, names(df))
        if !isempty(missing_cols)
            throw(ArgumentError("Columns not found in DataFrame: $(join(missing_cols, ", "))"))
        end
    end
    
    # Create a new row with column totals
    new_row = Dict{Symbol, Any}()
    
    # For each column in the dataframe
    for col in names(df)
        if col in cols_to_sum
            # Sum numeric columns
            col_values = skipmissing(df[!, col])
            if isempty(col_values)
                new_row[Symbol(col)] = missing
            else
                new_row[Symbol(col)] = sum(col_values)
            end
        else
            # Use the margin name for non-numeric columns
            new_row[Symbol(col)] = total_row_name
        end
    end
    
    # Append the totals row
    push!(result_df, new_row)
    
    return result_df
end

export add_row_totals
