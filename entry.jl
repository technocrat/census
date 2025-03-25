# SPDX-License-Identifier: MIT
using Census
using DrWatson
@quickactivate "Census"  

# Defidf paths directly
const SCRIPT_DIR   = projectdir("scripts")
const OBJ_DIR      = projectdir("obj")
const PARTIALS_DIR = projectdir("_layout/partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))

df = get_geo_pop(postals)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
include(joinpath(srcdir(), "get_nation_state.jl"))
# Add nation column by matching state abbreviations with nations and titles
df.nation = [get_nation_state(state) for state in df.stusps]

# create population totals by state
pop_state = combine(groupby(df, :stusps), :pop => sum => :total)
# Create population totals by nation
pop = combine(groupby(df, :nation), :pop => sum => :total)
sort!(pop, :nation)

gdp_state = make_nation_state_gdp_df(postals)
# Assign nations based on state membership
gdp_state.nation = fill("", nrow(gdp_state))
for (i, states) in enumerate(nations)
    gdp_state.nation = ifelse.(in.(gdp_state.stusps, Ref(states)), Titles[i], gdp_state.nation)
end

gdp = combine(groupby(gdp_state, :nation), :gdp => sum => :total)
sort!(gdp, :nation)
gdp = gdp[1:end-1, :]

age_dfs = collect_state_ages(nations, state_names)

# Calculate nation-level dependency ratios
nation_deps = DataFrame(nation = String[], dependency_ratio = Float64[])
for (i, nation_df) in enumerate(age_dfs)
    nation_name = Titles[i]
    # Get population weights for states in this nation
    nation_states = nations[i]
    state_pops = filter(row -> row.stusps in nation_states, pop_state)
    total_pop = sum(state_pops.total)
    weights = state_pops.total ./ total_pop
    
    # Calculate weighted average dependency ratio
    weighted_ratio = sum(nation_df.dependency_ratio .* weights)
    push!(nation_deps, (nation_name, weighted_ratio))
end
sort!(nation_deps, :nation)

educ = CSV.read(datadir()*"/educational_attainment.csv",DataFrame)
include(srcdir()*"/process_education_by_nation.jl")
educ_attainment = process_education_by_nation(educ, nations)

# Create dictionary mapping state abbreviations to nation titles
state_to_nation = Dict{String,String}()
for (i, states) in enumerate(nations)
    for state in states
        state_to_nation[state] = Titles[i]
    end
end

