function add_row_totals(df::DataFrame; 
                      total_row_name="Total",
                      cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Create a new row with column totals
    new_row = Dict{Symbol, Any}()
    
    # For each column in the dataframe
    for col in names(df)
        if col in cols_to_sum
            # Sum numeric columns
            new_row[Symbol(col)] = sum(skipmissing(df[!, col]))
        else
            # Use the margin name for non-numeric columns
            new_row[Symbol(col)] = total_row_name
        end
    end
    
    # Append the totals row
    push!(result_df, new_row)
    
    return result_df
end
