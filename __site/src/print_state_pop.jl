"""
	print_state_pop(nation::Vector{String})
	
Prints a formatted HTML table of state populations for the specified states.

# Arguments
- `nation::Vector{String}`: A vector of state USPS codes (e.g., `["CA", "NY", "TX"]`) to include in the output.

# Details
The function filters the `state_pop` DataFrame to include only the states specified in `nation`,
sorts them by population in descending order, formats the population numbers with commas,
and displays the result as an HTML table with state codes left-aligned and population values right-aligned.

# Example
```julia
print_state_pop(["CA", "NY", "TX", "FL"])
"""
function output_nation_state_pop(tab::DataFrame)
	pretty_table(t, 
		backend = Val(:html), 
		alignment = [:l,:r], 
		show_subheader = false, 
		header = ["State","Population"])
end
