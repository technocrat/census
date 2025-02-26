using CSV
using DataFrames
using Colors
using Compose
using Graphs
using GraphPlot
using PrettyTables

include("cons.jl")
postals = STATES
ne_states = ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont"]
df = CSV.read("../data/la_migra_filtered.csv",DataFrame)
push!(postals,"PR")
df.stusps = postals
# First, select all columns except the ones to omit
cols_to_exclude = [:population, :same, :in_state, :out_state, :Column61, :Column62]
ne_outflow = select(df, Not(cols_to_exclude))
ne_outflow = filter(:residence => x -> x ∈ ne_states, ne_outflow)

ne_inflow = select(df, Not(cols_to_exclude))
ne_inflow = filter(:residence => (x -> !(x in ne_states)), ne_inflow)
ne_inflow = select(ne_inflow, NE)
ne_inflow.residence = filter(:residence => (x -> !(x in ne_states)), df).residence

# New England states
ne_states = ["CT", "ME", "MA", "NH", "RI", "VT"]

# Function to get inflow for a state
function get_inflow(df, state)
    return sum(skipmissing(df[:, state]))
end

# Function to get outflow for a state
function get_outflow(df, state_abbrev)
    # Find state name mapping
    state_names = Dict(
        "CT" => "Connecticut",
        "ME" => "Maine", 
        "MA" => "Massachusetts",
        "NH" => "New Hampshire",
        "RI" => "Rhode Island",
        "VT" => "Vermont"
    )
    
    full_name = state_names[state_abbrev]
    row_idx = findfirst(df.residence .== full_name)
    if isnothing(row_idx)
        return 0
    end
    # Sum all state columns (excluding non-state columns)
    state_cols = filter(x -> x in ne_states, names(df))
    return sum(skipmissing(Vector(df[row_idx, state_cols])))
end

# First collect all the data
results = [(state, 
            get_inflow(ne_inflow, state),
            get_outflow(ne_outflow, state),
            get_inflow(ne_inflow, state) - get_outflow(ne_outflow, state)
           ) for state in ne_states]
            
# Create DataFrame from the collected results
migration_df = DataFrame(
    State = [r[1] for r in results],
    Inflows = [r[2] for r in results],
    Outflows = [r[3] for r in results],
    Net_Migration = [r[4] for r in results]
)


migration_df.State = ["Connecticut","Maine","Massachusetts","New Hampshire","Rhode Island","Vermont"]

include("src/format_with_commas.jl")
migration_df = format_with_commas(migration_df)
pretty_table(migration_df, 
    header = ["State", "Inflows", "Outflows", "Net Migration"],
    alignment = [:l, :r, :r, :r],
    backend = Val(:html))