function collect_state_ages(state_vectors, state_names)
    # Create a dictionary mapping state abbreviations to their DataFrames
    # Flatten all vectors and process each state once
    all_states = vcat(state_vectors...)
    state_dfs = Dict(
        state => query_state_ages(state) 
        for state in all_states
    )
    
    # Create a results DataFrame for each vector of states
    results = []
    
    for region_states in state_vectors
        region_df = DataFrame(
            state_name = [state_names[abbrev] for abbrev in region_states],
            dependency_ratio = [calculate_dependency_ratio(state_dfs[abbrev]) for abbrev in region_states]
        )
        push!(results, region_df)
    end
    
    return results
end

# Example usage:
# concord = ["CT", "MA", "ME", "NH", "RI", "VT"]
# nations = [concord, cumber, desert, dixie, factoria, heartland, lonestar, metropolis, pacific, sonora]
# state_names = Dict("CT" => "Connecticut", "MA" => "Massachusetts", ...)
# result_dfs = process_states(nations, state_names)