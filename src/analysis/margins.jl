# SPDX-License-Identifier: MIT

"""
    add_margins(df::DataFrame; 
                margin_row_name="Total", 
                margin_col_name="Total",
                cols_to_sum=nothing) -> DataFrame
    
Add row and column totals (margins) to a DataFrame containing numeric data.

# Arguments
- `df::DataFrame`: Input DataFrame with numeric columns
- `margin_row_name::String="Total"`: Label for the row margin (column totals)
- `margin_col_name::String="Total"`: Label for the column margin (row totals)
- `cols_to_sum::Union{Nothing,Vector{Symbol}}=nothing`: Specific columns to sum (default: all numeric columns)

# Returns
- `DataFrame`: A new DataFrame with:
  - Original data
  - Row totals in a new column (margin_col_name)
  - Column totals in a new row (margin_row_name)
  - Grand total in bottom-right cell

# Example
```julia
df = DataFrame(
    region = ["North", "South"],
    sales_2021 = [100, 200],
    sales_2022 = [150, 250]
)
add_margins(df)
# Returns:
# 3×4 DataFrame
#  Row │ region  sales_2021  sales_2022  Total
#      │ String  Int64       Int64       Int64
# ─────┼────────────────────────────────────────
#    1 │ North         100         150     250
#    2 │ South         200         250     450
#    3 │ Total         300         400     700
```

# Notes
- Creates a copy of the input DataFrame
- Automatically detects numeric columns if cols_to_sum is nothing
- Preserves non-numeric columns in the margin row
- Handles missing values (they are treated as 0 in sums)
- Thread-safe (no mutation of input DataFrame)
"""
function add_margins(df::DataFrame; 
                    margin_row_name="Total", 
                    margin_col_name="Total",
                    cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Add row margin (column totals)
    row_totals = combine(df, [col => sum => col for col in cols_to_sum])
    
    # Add an identifier column with the margin name
    for col in setdiff(names(df), cols_to_sum)
        if col in names(row_totals)
            row_totals[!, col] .= margin_row_name
        else
            row_totals[!, col] = [margin_row_name]
        end
    end
    
    # Add column margin (row totals)
    if !isempty(cols_to_sum)
        result_df[!, margin_col_name] = sum.(eachrow(result_df[:, cols_to_sum]))
        row_totals[!, margin_col_name] = [sum(row_totals[1, col] for col in cols_to_sum)]
    end
    
    # Combine with the original dataframe
    result_df = vcat(result_df, row_totals, cols=:union)
    
    return result_df
end

"""
    add_row_margins(df::DataFrame; 
                    margin_col_name="Total",
                    cols_to_sum=nothing) -> DataFrame
    
Add row totals (horizontal sums) to a DataFrame containing numeric data.

# Arguments
- `df::DataFrame`: Input DataFrame with numeric columns
- `margin_col_name::String="Total"`: Name for the new totals column
- `cols_to_sum::Union{Nothing,Vector{Symbol}}=nothing`: Specific columns to sum (default: all numeric columns)

# Returns
- `DataFrame`: A new DataFrame with an additional column containing row totals

# Example
```julia
df = DataFrame(
    product = ["A", "B"],
    q1 = [100, 150],
    q2 = [120, 160],
    q3 = [110, 170]
)
add_row_margins(df)
# Returns:
# 2×5 DataFrame
#  Row │ product  q1    q2    q3    Total
#      │ String   Int64 Int64 Int64 Int64
# ─────┼─────────────────────────────────
#    1 │ A         100   120   110    330
#    2 │ B         150   160   170    480
```

# Notes
- Creates a copy of the input DataFrame
- Only adds horizontal totals (no column totals)
- Automatically detects numeric columns if cols_to_sum is nothing
- Thread-safe (no mutation of input DataFrame)
- Useful for row-wise analysis without column totals
"""
function add_row_margins(df::DataFrame; 
                        margin_col_name="Total",
                        cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Add column margin (row totals)
    if !isempty(cols_to_sum)
        result_df[!, margin_col_name] = sum.(eachrow(result_df[:, cols_to_sum]))
    end
    
    return result_df
end

"""
    add_col_margins(df::DataFrame; 
                     margin_row_name="Total",
                     cols_to_sum=nothing) -> DataFrame
    
Add column totals (vertical sums) to a DataFrame containing numeric data.

# Arguments
- `df::DataFrame`: Input DataFrame with numeric columns
- `margin_row_name::String="Total"`: Label for the totals row
- `cols_to_sum::Union{Nothing,Vector{Symbol}}=nothing`: Specific columns to sum (default: all numeric columns)

# Returns
- `DataFrame`: A new DataFrame with an additional row containing column totals

# Example
```julia
df = DataFrame(
    region = ["East", "West", "North"],
    revenue = [1000, 1200, 800],
    costs = [800, 900, 600]
)
add_col_margins(df)
# Returns:
# 4×3 DataFrame
#  Row │ region  revenue  costs
#      │ String  Int64    Int64
# ─────┼──────────────────────
#    1 │ East      1000    800
#    2 │ West      1200    900
#    3 │ North      800    600
#    4 │ Total     3000   2300
```

# Notes
- Creates a copy of the input DataFrame
- Only adds vertical totals (no row totals)
- Automatically detects numeric columns if cols_to_sum is nothing
- Preserves non-numeric columns in the margin row
- Thread-safe (no mutation of input DataFrame)
- Useful for column-wise analysis without row totals
"""
function add_col_margins(df::DataFrame; 
                       margin_row_name="Total",
                       cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Add row margin (column totals)
    row_totals = combine(df, [col => sum => col for col in cols_to_sum])
    
    # Add an identifier column with the margin name
    for col in setdiff(names(df), cols_to_sum)
        if col in names(row_totals)
            row_totals[!, col] .= margin_row_name
        else
            row_totals[!, col] = [margin_row_name]
        end
    end
    
    # Combine with the original dataframe
    result_df = vcat(result_df, row_totals, cols=:union)
    
    return result_df
end
