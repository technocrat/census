# SPDX-License-Identifier: MIT

"""
    get_dem_vote() -> DataFrame

Retrieve and aggregate Democratic Party votes by state from the census database.

# Returns
- `DataFrame`: A DataFrame containing:
  - `stusps::String`: State postal code
  - `dem::Int`: Total Democratic votes in the state

# Data Processing
- Queries county-level Democratic vote data from census.counties and census.variable_data tables
- Filters out territories (PR, VI, AS, GU, MP)
- Aggregates votes by state
- Removes rows with missing nation values
- Sorts results by nation and state code

# Example
```julia
df = get_dem_vote()
# Returns:
# 50×2 DataFrame
#  Row │ stusps  dem      
#      │ String  Int      
# ─────┼─────────────────
#    1 │ AK      153778
#    2 │ AL      849624
#    ⋮ │   ⋮       ⋮
```

# Notes
- Uses the 'democratic' variable from the census database
- Excludes U.S. territories from the results
- Requires a valid database connection through the `q` function
"""
function get_dem_vote()
    geo_query = """
        SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as dem
        FROM census.counties us
        LEFT JOIN census.variable_data vd
            ON us.geoid = vd.geoid
            AND vd.variable_name = 'democratic'
    """
    us = q(geo_query)
    
    us = dropmissing(us, :nation)
    sort!(us,[:nation,:stusps])
    mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]

    us = us[mask,:] 
    return(combine(groupby(us, :stusps), :dem => sum => :dem))
end