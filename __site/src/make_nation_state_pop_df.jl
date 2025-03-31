# SPDX-License-Identifier: MIT

"""
    make_nation_state_pop_df(nation::Vector{String}) -> DataFrame

Create a population summary DataFrame for a proposed nation state.

# Arguments
- `nation::Vector{String}`: Vector of state postal codes that form the nation state

# Returns
- `DataFrame`: A DataFrame containing:
  - `stusps::String`: Full state names (converted from postal codes)
  - `pop::Int`: Total population of each state
  - Last row contains the total population for all states in the nation

# Processing Steps
1. Gets population data for all states
2. Filters for states in the specified nation
3. Sorts states by population in descending order
4. Adds a total row
5. Converts state postal codes to full state names

# Example
```julia
# Create population DataFrame for Factoria
factoria_states = ["PA", "OH", "MI", "IN", "IL", "WI"]
df = make_nation_state_pop_df(factoria_states)
# Returns:
# 7×2 DataFrame
#  Row │ stusps           pop      
#      │ String           Int      
# ─────┼────────────────────────────
#    1 │ Illinois        12812508
#    2 │ Pennsylvania    12801989
#    ⋮ │      ⋮            ⋮
#    7 │ Total          65853516
```

# Notes
- Requires the global `state_names` dictionary for postal code to full name conversion
- Uses `get_state_pop()` to fetch base population data
"""
function make_nation_state_pop_df(nation::Vector{String})
	state_pop = get_state_pop()
	face      = [s in nation for s in state_pop.stusps] 
	masked    = state_pop[face,:]
	s		  = sort(masked,:pop,rev=true)
	d         = vcat(s,DataFrame(stusps = "Total", pop = sum(s.pop)))
	d.stusps = [state_names[state] for state in d.stusps]	
	return(d)
end

