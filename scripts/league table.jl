# league table
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
include(srcdir()*"/get_geo_pop.jl")
df = get_geo_pop(postals)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
include(joinpath(srcdir(), "get_nation_state.jl"))
# Add nation column by matching state abbreviations with nations and titles
df.nation = [get_nation_state(state) for state in df.stusps]
df.nation = [abbr_to_full[nation] for nation in df.nation]
pop = combine(groupby(df, :nation), :pop => sum => :total)
sort!(pop, :nation)
rename!(pop, [:nation => :Nation, :total => :Population])

include(joinpath(srcdir(),"make_nation_state_gdp_df.jl"))
include(joinpath(srcdir(),"get_state_gdp.jl"))
include(joinpath(srcdir(),"q.jl"))
gdp_state = make_nation_state_gdp_df(postals)
deleteat!(gdp_state, nrow(gdp_state))

gdp_state.state = [reverse_state_dict[state] for state in gdp_state.state]
gdp_state.nation = [state_to_nation[state] for state in gdp_state.state]
gdp = combine(groupby(gdp_state, :nation), :gdp => sum => :total)
sort!(gdp, :nation)

include(joinpath(srcdir(),"query_state_ages.jl"))
age_dfs = collect_state_ages(nations, state_names)

# Calculate nation-level dependency ratios
nation_deps = DataFrame(nation = String[], dependency_ratio = Float64[])
for (i, nation_df) in enumerate(age_dfs)
    nation_name = Titles[i]
    # Get population weights for states in this nation
    nation_states = nations[i]
    state_pops = combine(groupby(filter(row -> row.stusps in nation_states, df), :stusps), :pop => sum)
    total_pop = sum(state_pops.pop_sum)
    weights = state_pops.pop_sum ./ total_pop
    
    # Calculate weighted average dependency ratio
    weighted_ratio = sum(nation_df.dependency_ratio .* weights)
    # Round to 2 decimal places for readability
    weighted_ratio = round(weighted_ratio, digits=2)
    push!(nation_deps, (nation_name, weighted_ratio))
end

# Sort by nation name for consistency
sort!(nation_deps, :nation)

educ = CSV.read(datadir()*"/educational_attainment.csv",DataFrame)
include(srcdir()*"/process_education_by_nation.jl")
educ_attainment = process_education_by_nation(educ, nations)

pop.nation = titlecase.(pop.nation)
gdp.nation = titlecase.(gdp.nation)

rename!(pop, [:nation => :Nation, :total => :Population])
rename!(gdp, [:nation => :Nation, :total => :GDP])
rename!(nation_deps, [:nation => :Nation, :dependency_ratio => :Dependency_Ratio])  

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

output_league_table(df)