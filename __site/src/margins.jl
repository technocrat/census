using DataFrames

"""
    add_margins(df::DataFrame; 
                margin_row_name="Total", 
                margin_col_name="Total",
                cols_to_sum=nothing)
    
Add row and column totals to a DataFrame containing numeric data.

# Arguments
- `df`: Input DataFrame
- `margin_row_name`: Label for the row margin (default: "Total")
- `margin_col_name`: Label for the column margin (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with margins added
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
                    cols_to_sum=nothing)
    
Add only row totals to a DataFrame containing numeric data.

# Arguments
- `df`: Input DataFrame
- `margin_col_name`: Label for the column margin (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with row margins added
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
                     cols_to_sum=nothing)
    
Add only column totals to a DataFrame containing numeric data.

# Arguments
- `df`: Input DataFrame
- `margin_row_name`: Label for the row margin (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with column margins added
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