# SPDX-License-Identifier: MIT

# Replace codes with full names
function expand_state_codes(stusps::Vector{String})
	return([state_names[state] for state in stusps])
end
