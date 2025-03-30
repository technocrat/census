# SPDX-License-Identifier: MIT

"""
    get_gop_vote() -> DataFrame

Retrieve and aggregate Republican Party votes by state from the census database.

# Returns
- `DataFrame`: A DataFrame containing:
  - `stusps::String`: State postal code
  - `gop::Int`: Total Republican votes in the state

# Data Processing
- Queries county-level Republican vote data from census.counties and census.variable_data tables
- Filters out territories (PR, VI, AS, GU, MP)
- Aggregates votes by state
- Removes rows with missing nation values
- Sorts results by nation and state code

# Example
```julia
df = get_gop_vote()
# Returns:
# 50×2 DataFrame
#  Row │ stusps  gop      
#      │ String  Int      
# ─────┼─────────────────
#    1 │ AK      189951
#    2 │ AL      1441170
#    ⋮ │   ⋮       ⋮
```

# Notes
- Uses the 'republican' variable from the census database
- Excludes U.S. territories from the results
- Requires a valid database connection through the `q` function
"""
function get_gop_vote()
    geo_query = """
        SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as gop
        FROM census.counties us
        LEFT JOIN census.variable_data vd
            ON us.geoid = vd.geoid
            AND vd.variable_name = 'republican'
    """
    us = q(geo_query)
    
    us = dropmissing(us, :nation)
    sort!(us,[:nation,:stusps])
    mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]

    us = us[mask,:] 
    return(combine(groupby(us, :stusps), :gop => sum => :gop))
end
