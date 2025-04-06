# SPDX-License-Identifier: MIT

"""
    fill_state!(df::DataFrame) -> DataFrame

Add a new column 'state' to the input DataFrame based on the locale and is_county columns.

# Arguments
- `df::DataFrame`: DataFrame containing:
    - `locale::String`: Name of geographic entity (state or county)
    - `is_county::Bool`: true if row represents a county, false if state

# Returns
- `DataFrame`: Modified input DataFrame with new 'state' column

# Behavior
For each row:
- If `is_county` is false: 'state' gets the value of `locale` (row represents a state)
- If `is_county` is true: 'state' gets the value from the most recent state row

# Example
```julia
df = DataFrame(
    locale = ["California", "Alameda", "Nevada", "Clark"],
    is_county = [false, true, false, true]
)
fill_state!(df)
# Returns:
# locale     is_county  state
# California false      California
# Alameda    true      California
# Nevada     false      Nevada
# Clark      true      Nevada
```

# Throws
- `ArgumentError`: If required columns are missing or empty
- `ArgumentError`: If first row is not a state (is_county = true)
"""
function fill_state!(df::DataFrame)
    # Input validation
    if !hasproperty(df, :locale) || !hasproperty(df, :is_county)
        throw(ArgumentError("DataFrame must have 'locale' and 'is_county' columns"))
    end
    
    if isempty(df)
        throw(ArgumentError("DataFrame must not be empty"))
    end
    
    if df.is_county[1]
        throw(ArgumentError("First row must be a state (is_county = false)"))
    end
    
    # Add state column
    current_state = nothing
    df.state = map(1:nrow(df)) do i
        if !df.is_county[i]
            current_state = df.locale[i]
        elseif isnothing(current_state)
            throw(ArgumentError("Found county before any state at row $i"))
        end
        current_state
    end
    
    return df
end

export fill_state!
