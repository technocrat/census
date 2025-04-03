# SPDX-License-Identifier: MIT

"""
    get_childbearing_population(df::DataFrame) -> Float64

Calculate the total childbearing population (women aged 15-44) from a demographic DataFrame.

# Arguments
- `df::DataFrame`: A DataFrame containing age-sex population data, where:
  - Rows 4-9 correspond to age groups 15-44
  - Column 2 contains female population counts

# Returns
- `Float64`: Total childbearing population in thousands

# Notes
- Assumes specific DataFrame structure from Census age-sex tables
- Age groups are expected to be:
  - Row 4: 15-19 years
  - Row 5: 20-24 years
  - Row 6: 25-29 years
  - Row 7: 30-34 years
  - Row 8: 35-39 years
  - Row 9: 40-44 years
- Returns the sum divided by 1000 to convert to thousands

# Example
```julia
df = get_us_ages()  # Get age-sex population data
cbp = get_childbearing_population(df)  # Get childbearing population in thousands
```
"""
function get_childbearing_population(df)
    return Float64.(sum(df[4:9, 2]) / 1e3)
end