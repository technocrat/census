# SPDX-License-Identifier: MIT

function create_state_to_nation_map(nations)
	state_to_nation = Dict{String, Int}()
	for (i, states) in enumerate(nations)
		for state in states
			state_to_nation[state] = i
		end
	end
	return state_to_nation
end
