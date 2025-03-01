include("libr.jl")
include("cons.jl")
include("func.jl")
include("nations.jl")
include("dict.jl")
include("highlighters.jl")

state_dfs = Dict(
	state => query_state_ages(state) 
	for state in nation
)

results = DataFrame(
	state_name = [state_names[abbrev] for abbrev in keys(state_dfs)],
	dependency_ratio = [calculate_dependency_ratio(df) for df in values(state_dfs)]
)

results.state_name .= keys(state_dfs)
results.state_name = expand_state_codes(results.state_name)
sort!(results,:state_name)
output_nation_ratios(results)