# SPDX-License-Identifier: MIT
# SCRIPT
using Pkg
# Activate the package using a relative path from the script location
Pkg.activate(dirname(dirname(@__FILE__)))
using Census
using DataFrames
using DataFramesMeta

# Get command line argument for nation symbol
if length(ARGS) < 1
    error("Please provide a nation symbol as a command line argument")
end

nation_symbol = Symbol(ARGS[1])

# Initialize census data
global us = init_census_data()
@info "Loaded $(nrow(us)) counties"

# Create state DataFrames
state_dfs = create_state_dfs(us, nation_symbol)
@info "Created state DataFrames for nation $nation_symbol"

# Apply subset rules to filter counties
df = apply_subset_rules(state_dfs, nation_symbol)
@info "Applied subset rules, resulting in $(nrow(df)) counties"

# Display first few rows of the DataFrame for inspection
@info "First few rows of filtered DataFrame:"
println(first(df, 5))

# Pause for inspection with better prompt
println("\nPress Enter to continue with mapping and database updates, or Ctrl+C to abort...")
try
    # Use print instead of println to keep cursor on same line
    print("> ")
    readline()
catch e
    if e isa InterruptException
        println("\nAborted by user")
        exit(0)
    else
        rethrow(e)
    end
end

# Set map title and projection based on nation
map_title = "$(titlecase(string(nation_symbol))) Counties"
dest = "EPSG:4326"  # Default projection

# Create map
fig = Figure(size=(1200, 800))
ax = GeoAxis(fig[1,1], dest=dest, title=map_title)
poly!(ax, df.geom, color=:lightblue)
save_plot_to_img_dir(fig, map_title)

# Update database with nation state name
set_nation_state_geoids(string(nation_symbol), df.geoid)
@info "Updated database with nation state $nation_symbol"

function get_db_connection()
    try
        @info "Connecting to database"
        return LibPQ.Connection("dbname=tiger")
    catch e
        @error "Error connecting to database: $e"
        return nothing
    end
end

"""
    create_state_dfs(us::DataFrame, nation_symbol::Symbol) -> Dict{Symbol, DataFrame}

Create a dictionary of DataFrames for each state in a nation, keyed by state postal code symbols.

# Arguments
- `us::DataFrame`: The full US census DataFrame from init_census_data()
- `nation_symbol::Symbol`: The symbol representing the nation (e.g., :cumberland)

# Returns
- `Dict{Symbol, DataFrame}`: Dictionary with state postal codes as keys and filtered DataFrames as values

# Example
```julia
state_dfs = create_state_dfs(us, :cumberland)
```
"""
function create_state_dfs(us::DataFrame, nation_symbol::Symbol)
    if !haskey(Census.STATE_SETS, nation_symbol)
        @error "Nation $nation_symbol not found in Census.STATE_SETS"
        exit(1)
    end

    states = Census.STATE_SETS[nation_symbol]

    # Create dictionary to store state DataFrames
    state_dfs = Dict{Symbol, DataFrame}()

    # Filter us DataFrame for each state
    for state in states
        state_sym = Symbol(state)
        state_df = subset(us, :stusps => ByRow(==(state)))
        if nrow(state_df) > 0
            state_dfs[state_sym] = state_df
            @info "Added $(nrow(state_df)) counties for state $state"
        else
            @warn "No counties found for state $state"
        end
    end

    return state_dfs
end

function reset_nation(nation_name::String)
    conn = get_db_connection()
    if conn === nothing
        @error "Failed to connect to database"
        return
    end

    try
        # First, get a count of counties with this nation value
        @info "Checking current assignments for nation: $nation_name"
        count_query = "SELECT COUNT(*) FROM census.counties WHERE nation = '$nation_name'"
        count_result = LibPQ.execute(conn, count_query)
        count_df = DataFrame(count_result)
        initial_count = count_df[1, 1]
        
        if initial_count > 0
            @info "Found $initial_count counties with nation = '$nation_name'"
            
            # Start a transaction
            LibPQ.execute(conn, "BEGIN;")
            
            # Reset nation values for this nation only
            @info "Resetting nation values for '$nation_name'"
            reset_query = "UPDATE census.counties SET nation = NULL WHERE nation = '$nation_name'"
            LibPQ.execute(conn, reset_query)
            
            # Verify the reset
            verify_query = "SELECT COUNT(*) FROM census.counties WHERE nation = '$nation_name'"
            verify_result = LibPQ.execute(conn, verify_query)
            verify_df = DataFrame(verify_result)
            remaining_count = verify_df[1, 1]
            
            if remaining_count == 0
                @info "Successfully reset all assignments for nation '$nation_name'"
            else
                @warn "Some assignments remain: $remaining_count"
            end
            
            # Commit the transaction
            LibPQ.execute(conn, "COMMIT;")
            @info "Changes committed to database"
        else
            @info "No counties found with nation = '$nation_name', nothing to reset"
        end
    catch e
        @error "Error resetting nation values: $e"
        # Try to rollback if there was an error
        try
            LibPQ.execute(conn, "ROLLBACK;")
            @info "Transaction rolled back"
        catch rollback_error
            @error "Error rolling back transaction: $rollback_error"
        end
    finally
        LibPQ.close(conn)
    end
end

# Reset any existing records for this nation
reset_nation(titlecase(string(nation_symbol)))

# Now process the nation using a modified version of nation_template.jl
@info "Starting nation processing for $nation_symbol"

# Define the global nation variable that will be used by all included scripts
global nation = nation_symbol
@info "Set global nation = $nation"


# Load forepart.jl for dependencies and state DataFrames creation
@info "Including forepart.jl"
include(joinpath(@__DIR__, "forepart.jl"))

# Check that nation hasn't been changed
@info "Nation variable after forepart.jl: $nation"

# Main script execution
@info "Running map generation and database update"

# Check if required variables are defined before continuing
if !(@isdefined state_dfs)
    @error "state_dfs variable not defined after including forepart.jl"
    exit(1)
end 