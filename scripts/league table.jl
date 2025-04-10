# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "cons.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))

# Define paths directly
const SCRIPT_DIR = @__DIR__
const OBJ_DIR = joinpath(dirname(SCRIPT_DIR), "obj")
const PARTIALS_DIR = joinpath(dirname(SCRIPT_DIR), "_layout", "partials")
const SRC_DIR = joinpath(dirname(SCRIPT_DIR), "src")
const DATA_DIR = joinpath(dirname(SCRIPT_DIR), "data")

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SRC_DIR, "get_geo_pop.jl"))
df = get_geo_pop(postals)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
include(joinpath(SRC_DIR, "get_nation_state.jl"))
# Add nation column by matching state abbreviations with nations and titles
df.nation = [get_nation_state(state) for state in df.stusps]
df.nation = [abbr_to_full[nation] for nation in df.nation]
pop = combine(groupby(df, :nation), :pop => sum => :total)
sort!(pop, :nation)
rename!(pop, [:nation => :Nation, :total => :Population])
state_pop = combine(groupby(df, :stusps), :pop => sum => :total)
include(joinpath(SRC_DIR, "make_nation_state_gdp_df.jl"))
include(joinpath(SRC_DIR, "get_state_gdp.jl"))
include(joinpath(SRC_DIR, "q.jl"))
gdp_state = make_nation_state_gdp_df(postals)
gdp_state = drop_last(gdp_state)

gdp_state.state = [reverse_state_dict[state] for state in gdp_state.state]
gdp_state.nation = [state_to_nation[state] for state in gdp_state.state]
gdp = combine(groupby(gdp_state, :nation), :gdp => sum => :total)
sort!(gdp, :nation)
gdp.Nation = Titles
include(joinpath(SRC_DIR, "query_state_ages.jl"))
age_dfs = collect_state_ages(nations, state_names)

# Calculate nation-level dependency ratios
nation_deps = DataFrame(Nation = String[], Dependency_Ratio = Float64[])

for (i, nation_df) in enumerate(age_dfs)
    nation_name = Titles[i]
    # Get population weights for states in this nation
    nation_states = nations[i]
    
    # Filter state_pop for states in this nation and calculate total population
    nation_state_pops = filter(row -> row.stusps in nation_states, state_pop)
    total_pop = sum(nation_state_pops.total)
    
    # Calculate weights based on state populations
    weights = nation_state_pops.total ./ total_pop
    
    # Calculate weighted average dependency ratio
    weighted_ratio = sum(nation_df.dependency_ratio .* weights)
    # Round to 2 decimal places for readability
    weighted_ratio = round(weighted_ratio, digits=2)
    
    # Add to results DataFrame
    push!(nation_deps, (Nation = nation_name, Dependency_Ratio = weighted_ratio))
end

# Sort by nation name for consistency
sort!(nation_deps, :Nation)

# Convert dependency ratios to strings with % signs
transform!(nation_deps, :Dependency_Ratio => ByRow(x -> string(x) * "%") => :Dependency_Ratio)

educ = CSV.read(joinpath(DATA_DIR, "educational_attainment.csv"), DataFrame)
include(joinpath(SRC_DIR, "process_education_by_nation.jl"))
educ_attainment = process_education_by_nation(educ, nations)

# Calculate nation-level dependency ratios
nation_deps = DataFrame(Nation = String[], Dependency_Ratio = Float64[])
for (i, nation_df) in enumerate(age_dfs)
    nation_name = Titles[i]
    # Get population weights for states in this nation
    nation_states = nations[i]
    
    # Filter the state population dataframe for states in this nation
    # Using the correct column name for state abbreviations
    state_pops = filter(row -> row.stusps in nation_states, state_pop)
    
    # Sum the populations for these states
    total_pop = sum(state_pops.total)
    
    # Create weights for each state
    weights = []
    
    # Match states in nation_df with their corresponding weights
    for (j, state) in enumerate(nation_df.state_name)
        # Convert full state name to abbreviation using your reverse dictionary
        state_abbr = reverse_state_dict[state]
        
        # Find the population for this state
        state_pop_row = filter(row -> row.stusps == state_abbr, state_pops)
        if !isempty(state_pop_row)
            push!(weights, state_pop_row[1, :total] / total_pop)
        else
            push!(weights, 0.0)  # Handle case where state isn't found
        end
    end
    
    # Calculate weighted average dependency ratio
    weighted_ratio = sum(nation_df.dependency_ratio .* weights)
    # Round to 2 decimal places for readability
    weighted_ratio = round(weighted_ratio, digits=2)
    push!(nation_deps, (Nation = nation_name, Dependency_Ratio = weighted_ratio))
end
# Sort by nation name for consistency
sort!(nation_deps, :Nation)

# Convert dependency ratios to strings with % signs
transform!(nation_deps, :Dependency_Ratio => ByRow(x -> string(x) * "%") => :Dependency_Ratio)

pop.nation = titlecase.(pop.nation)
gdp = gdp[!, [:Nation, :total]]
#rename!(pop, [:nation => :Nation, :total => :Population])
#rename!(gdp, [:nation => :Nation, :total => :GDP])
rename!(nation_deps, [:nation => :Nation, :dependency_ratio => :Dependency_Ratio])  
rename!(gdp, [:total => :GDP])
df = innerjoin(pop, gdp, on=:Nation)

df = innerjoin(df, educ_attainment, on=:Nation)
df = innerjoin(df, nation_deps, on=:Nation)
sort!(df,:Nation)
df.Dependency_Ratio = round.(df.Dependency_Ratio, digits=2)
df.per_capita_gdp = Int64.(round.(df.GDP ./ df.Population, digits=0))

df.Dependency_Ratio = string.(df.Dependency_Ratio) .* "%"
df = format_with_commas(df)

df = df[!,[1,2,3,7,4,5,6,]]
pretty_table(df, 
            backend=Val(:html),
            alignment=[:l,:r,:r,:r,:r,:r,:r],
            show_subheader=false,
            header=["Nation", "Population", "GDP", "Per Capita GDP","College Degree", "Graduate Degree", "Dependency Ratio"],
            highlighters = (hl_alternating,))
include(joinpath(SCRIPT_DIR, "output_league_table.jl"))
output_league_table(df)