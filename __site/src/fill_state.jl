"""
    fill_state!(df::DataFrame) -> DataFrame

Add a new column 'state' to the input DataFrame where each row contains either:
- The value of `locale` from the same row if `is_county` is false (indicating the row represents a state)
- The value of `locale` from the most recent preceding row where `is_county` was false (indicating the state containing the county)

# Arguments
- `df::DataFrame`: DataFrame containing columns:
    - `locale::String`: Name of geographic entity (state or county)
    - `is_county::Bool`: true if the row represents a county, false if it represents a state

# Returns
- Modified input DataFrame with new column 'state'

# Example
```julia
df = DataFrame(
    locale = ["California", "Alameda", "Nevada", "Clark"],
    is_county = [false, true, false, true]
)

fill_state!(df)
"""
function fill_state!(df)
    current_state = nothing
    df.state = map(1:nrow(df)) do i
        if !df.is_county[i]
            current_state = df.locale[i]
        end
        current_state
    end
    return df
end
