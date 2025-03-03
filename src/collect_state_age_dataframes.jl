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