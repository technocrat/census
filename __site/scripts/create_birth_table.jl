# SPDX-License-Identifier: MIT

function create_birth_table()
    births = CSV.read("../data/births.csv",DataFrame)
    state_age_dfs 	   = collect_state_age_dataframes(nations)
    
    # Assuming state_age_dfs is your dictionary of dataframes
    # And postals is your vector of state abbreviations
    
    # Create a dictionary to store the results
    childbearing_pop = Dict{String, Float64}()
    
    # Iterate over the postal codes and apply the function
    for state in postals
        childbearing_pop[state] = get_childbearing_population(state_age_dfs[state])
    end
    
    # First, create a mapping from full state names to postal codes
    name_to_postal = Dict(fullname => code for (code, fullname) in state_names)
    
    # Create an array to hold the birth rates
    birth_rates = Float64[]
    
    # For each state in the births dataframe
    for row in eachrow(births)
        state_name = row.State
        
        # Handle the misspelling of "Iowa" as "lowa" if needed
        if state_name == "lowa"
            state_name = "Iowa"
        end
        
        # Get the postal code
        postal = name_to_postal[state_name]
        
        # Get the childbearing population
        population = childbearing_pop[postal]
        
        # Calculate births per thousand mothers
        birth_rate = row.Births / population
        
        # Add to the array
        push!(birth_rates, birth_rate)
    end
    
    # Now add the column to the dataframe
    births[!, :Rate] = birth_rates
    births[!, :TFR]  = births.Rate .* 30 ./ 1000
    return births
end