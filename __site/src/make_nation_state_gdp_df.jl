# SPDX-License-Identifier: MIT

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

pop = combine(groupby(df, :nation), :pop => sum => :total)
sort!(pop, :nation)

gdp_state 		 = make_nation_state_gdp_df(postals)
gdp_stusps 		 = [reverse_state_dict[state] for state in gdp_state.state]
gdp_state.nation = [get_nation_state(state) for state in gdp_stusps]

gdp = combine(groupby(gdp_state, :nation), :gdp => sum => :total)
gdp = gdp[1:end-1, :]
sort!(gdp, :nation)
rename!(gdp, :total => :GDP)	

df = leftjoin(pop, gdp, on=:nation)
rename!(df, [:nation => :Nation, :total => :Population, :GDP => :GDP])	
df.per_capita = df.GDP ./ df.Population
