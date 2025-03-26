# SPDX-License-Identifier: MIT

# takes a vector of vectors of state name two-letter abbreviations and
# returns a vector of dataframes containing age data
"""
    collect_state_age_dataframes(nations::Vector{Vector{String}}) -> Dict{String, DataFrame}

Collect age demographic data for all states across provided nations and return as DataFrames.

# Arguments
- `nations::Vector{Vector{String}}`: A vector of vectors, where each inner vector contains
  state codes belonging to a particular nation.

# Returns
- `Dict{String, DataFrame}`: A dictionary mapping state codes to DataFrames containing
  age demographic data for that state.

# Notes
- Skips states that have already been processed to avoid duplicates
- Includes a small delay (0.5s) between queries to avoid overwhelming the database
- Errors for individual states are logged but don't stop the entire collection process

# Examples
```julia
nations = [["US-NY", "US-CA", "US-TX"], ["CA-ON", "CA-BC"]]
state_data = collect_state_age_dataframes(nations)
"""
function collect_state_age_dataframes(nations::Vector{Vector{String}})
    # Initialize an empty dictionary to store the results
    state_age_dfs = Dict{String, DataFrame}()
    
    # Keep track of states we've already processed to avoid duplicates
    processed_states = Set{String}()
    
    # Process each nation
    for nation in nations
        for state_code in nation
            # Skip if we've already processed this state
            if state_code in processed_states
                continue
            end
            
            # Add to processed set
            push!(processed_states, state_code)
            
            try
                # Query the database for this state
                println("Querying data for state: $(state_code)")
                df = query_state_ages(state_code)
                
                # Store in our dictionary
                state_age_dfs[state_code] = df
                
                # Optional: add a small delay to avoid overwhelming the database
                sleep(0.5)
            catch e
                # Log any errors but continue with other states
                println("Error processing state $(state_code): $(e)")
            end
        end
    end
    
    # Print summary
    println("Collected age data for $(length(state_age_dfs)) states")
    
    return state_age_dfs
end