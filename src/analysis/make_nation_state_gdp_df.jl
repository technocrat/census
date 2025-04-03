# SPDX-License-Identifier: MIT

"""
    make_nation_state_gdp_df(nation::Vector{String}) -> DataFrame

Create a GDP summary DataFrame for a proposed nation state.

# Arguments
- `nation::Vector{String}`: Vector of state postal codes that form the nation state

# Returns
- `DataFrame`: A DataFrame containing:
  - `state::String`: State name
  - `gdp::Int64`: Gross Domestic Product of each state (rounded to nearest integer)
  - Last row contains the total GDP for all states in the nation

# Processing Steps
1. Gets GDP data for all states
2. Rounds GDP values to integers
3. Converts state names to postal codes using reverse_state_dict
4. Filters for states in the specified nation
5. Sorts states by GDP in descending order
6. Keeps only state name and GDP columns
7. Adds a total row

# Example
```julia
# Create GDP DataFrame for Factoria
factoria_states = ["PA", "OH", "MI", "IN", "IL", "WI"]
df = make_nation_state_gdp_df(factoria_states)
# Returns:
# 7×2 DataFrame
#  Row │ state           gdp      
#      │ String          Int64    
# ─────┼────────────────────────
#    1 │ Illinois       858714
#    2 │ Pennsylvania   793677
#    ⋮ │      ⋮          ⋮
#    7 │ Total         2852391
```

# Notes
- Requires the global `reverse_state_dict` for state name to postal code conversion
- Uses `get_state_gdp()` to fetch base GDP data
- GDP values are in millions of dollars
"""
function make_nation_state_gdp_df(nation::Vector{String})	
	state_gdp 		 = get_state_gdp()
	state_gdp.gdp 	 = round.(state_gdp.gdp, digits = 0)
	state_gdp.gdp 	 = Int64.(state_gdp.gdp)
	state_gdp.postal = [get(reverse_state_dict, state, missing) for state in state_gdp.state]
	face      		 = [s in nation for s in state_gdp.postal] 
	masked    		 = state_gdp[face,:]
	s		  		 = sort(masked,:gdp,rev=true)
	s 				 = s[!,[1,2]]
	d 		  		 = vcat(s,DataFrame(state = "Total", gdp = sum(s.gdp)))
	return d
end

