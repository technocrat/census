# SPDX-License-Identifier: MIT

"""
    get_state_pop() -> DataFrame

Retrieve and aggregate total population by state from the census database.

# Returns
- `DataFrame`: A DataFrame containing:
  - `stusps::String`: State postal code
  - `pop::Int`: Total population of the state

# Data Processing
- Queries county-level population data from census.counties and census.variable_data tables
- Filters out territories (PR, VI, AS, GU, MP)
- Aggregates population by state
- Removes rows with missing nation values
- Sorts results by nation and state code

# Example
```julia
df = get_state_pop()
# Returns:
# 50×2 DataFrame
#  Row │ stusps  pop      
#      │ String  Int      
# ─────┼─────────────────
#    1 │ AK      733391
#    2 │ AL      5024279
#    ⋮ │   ⋮       ⋮
```

# Notes
- Uses the 'total_population' variable from the census database
- Excludes U.S. territories from the results
- Requires a valid database connection through the `q` function
"""
function get_state_pop()
	geo_query = """
		SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as pop
		FROM census.counties us
		LEFT JOIN census.variable_data vd
			ON us.geoid = vd.geoid
			AND vd.variable_name = 'total_population'
	"""
	us = q(geo_query)
	
	us = dropmissing(us, :nation)
	sort!(us,[:nation,:stusps])
	mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]
	us = us[mask,:]	
	return(combine(groupby(us, :stusps), :pop => sum => :pop))
end
