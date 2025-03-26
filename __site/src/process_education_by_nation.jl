# SPDX-License-Identifier: MIT

# Create a mapping from state abbreviation to nation index
function create_state_to_nation_map(nations::Vector{Vector{String}})
    state_to_nation = Dict{String, Int}()
    for (i, states) in enumerate(nations)
        for state in states
            state_to_nation[state] = i
        end
    end
    return state_to_nation
end


# Process the education data by nations
function process_education_by_nation(educ::DataFrame, nations::Vector{Vector{String}})
    # Create the mappings
    state_to_nation = create_state_to_nation_map(nations)
    state_abbrev = create_state_abbrev_map()
    
    # Create a copy of the dataframe to avoid modifying the original
    edu_data = copy(educ)
    
    # Add nation column as integers first
    edu_data.Nation = [get(state_to_nation, get(state_abbrev, state, ""), 0) for state in edu_data.State]
    
    # Calculate raw totals for each nation
    nation_stats = DataFrame(Nation = Int[], College_pct = Float64[], Grad_pct = Float64[])
    
    for nation_idx in sort(unique(edu_data.Nation))
        # Skip any states that weren't mapped (if any)
        if nation_idx == 0
            continue
        end
        
        nation_data = filter(:Nation => x -> x == nation_idx, edu_data)
        
        # Calculate totals
        total_population = sum(nation_data.Population)
        total_ba = sum(nation_data.Pop_w_BA)
        total_grad = sum(nation_data.Pop_w_GRAD)
        
        # Calculate percentages
        college_pct = (total_ba + total_grad) / total_population * 100
        grad_pct = total_grad / total_population * 100
        
        # Add row to nation_stats
        push!(nation_stats, (Nation = nation_idx, College_pct = college_pct, Grad_pct = grad_pct))
    end
    
    # Add descriptive names for the nations
    nation_names = ["Concordia", "Cumberland", "Deseret", "New Dixie", "Factoria", 
                   "Heartlandia", "Metropolis", "Pacifica", "New Sonora", "The Lone Star Republic"]
    
    nation_stats.Nation_Name = [nation_names[n] for n in nation_stats.Nation]
    
    # Format the percentages
    nation_stats.Pop_w_College_pct = string.(round.(nation_stats.College_pct, digits=2), "%")
    nation_stats.Pop_w_GRAD_pct = string.(round.(nation_stats.Grad_pct, digits=2), "%")
    
    # Select and sort the final columns
    select!(nation_stats, [:Nation_Name, :Pop_w_College_pct, :Pop_w_GRAD_pct])
    rename!(nation_stats, :Nation_Name => :Nation)
    sort!(nation_stats, :Nation)
    
    return nation_stats
end