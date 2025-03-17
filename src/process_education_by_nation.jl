# SPDX-License-Identifier: MIT

# Process the education data by nations
function process_education_by_nation(educ, nations)
    # Create the mappings
    state_to_nation = create_state_to_nation_map(nations)
    state_abbrev = create_state_abbrev_map()
    
    # Create a copy of the dataframe to avoid modifying the original
    edu_data               = copy(educ)
    edu_data.Pop_w_College = edu_data.Pop_w_BA .+ edu_data.Pop_w_GRAD
    # Add nation column
    edu_data.Nation        = map(state -> state_to_nation[state_abbrev[state]], edu_data.State)
    
    # Group by nation and calculate statistics
    nation_stats = combine(groupby(edu_data, :Nation), 
        :Population    => sum,
        :Pop_w_HS      => sum,
        :Pop_w_BA      => sum,
        :Pop_w_GRAD    => sum,
        :Pop_w_College => sum
    )
    
    # Calculate percentages for each education level by nation
    for col in [:Pop_w_HS, :Pop_w_BA, :Pop_w_GRAD, :Pop_w_College]
        nation_stats[!, Symbol(string(col) * "_pct")] = 
            100 * nation_stats[!, Symbol(string(col) * "_sum")] ./ nation_stats.Population_sum
    end
    
    # Add descriptive names for the nations
    nation_names = ["Concordia", "Cumberland", "Deseret", "New Dixie", "Factoria", "Heartlandia", "The Lone Star Republic", "Metropolis", "Pacifica", "New Sonora"]
    nation_stats.Nation_Name = nation_names[nation_stats.Nation]
    nation_stats.Nation = nation_stats.Nation_Name
    select!(nation_stats, [:Nation,:Pop_w_College_pct,:Pop_w_GRAD_pct])
    nation_stats.Pop_w_College_pct = round.(nation_stats.Pop_w_College_pct,digits = 2)
    nation_stats.Pop_w_GRAD_pct = round.(nation_stats.Pop_w_GRAD_pct,digits = 2)
    nation_stats.Pop_w_GRAD_pct = string.(nation_stats.Pop_w_GRAD_pct)
    nation_stats.Pop_w_GRAD_pct = nation_stats.Pop_w_GRAD_pct .* "%"
    nation_stats.Pop_w_College_pct = string.(nation_stats.Pop_w_College_pct)
    nation_stats.Pop_w_College_pct = nation_stats.Pop_w_College_pct .* "%"
    sort!(nation_stats,:Nation)
    return nation_stats
end




