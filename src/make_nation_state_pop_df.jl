# SPDX-License-Identifier: MIT

function make_nation_state_pop_df(nation::Vector{String})
	state_pop = get_state_pop()
	face      = [s in nation for s in state_pop.stusps] 
	masked    = state_pop[face,:]
	s		  = sort(masked,:pop,rev=true)
	d         = vcat(s,DataFrame(stusps = "Total", pop = sum(s.pop)))
	d.stusps = [state_names[state] for state in d.stusps]	
	return(d)
end

