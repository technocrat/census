# Process the education data by nations
function process_education_by_nation(educ, nations)
	# Create the mappings
	state_to_nation = create_state_to_nation_map(nations)
	state_abbrev = create_state_abbrev_map()
	
	# Create a copy of the dataframe to avoid modifying the original
	edu_data = copy(educ)
	
	# Add nation column
	edu_data.Nation = map(state -> state_to_nation[state_abbrev[state]], edu_data.State)
	
	# Group by nation and calculate statistics
	nation_stats = combine(groupby(edu_data, :Nation), 
		:Population => sum,
		:Pop_w_BA => sum,
		:Pop_w_GRAD => sum
	)
	
	# Calculate percentages for college and graduate education
	nation_stats.College_pct = 100 * (nation_stats.Pop_w_BA_sum .+ nation_stats.Pop_w_GRAD_sum) ./ nation_stats.Population_sum
	nation_stats.Grad_pct = 100 * nation_stats.Pop_w_GRAD_sum ./ nation_stats.Population_sum
	
	# Add descriptive names for the nations
	nation_names = ["Concordia", "Cumberland", "Deseret", "New Dixie", "Factoria", 
				   "Heartlandia", "The Lone Star Republic", "Metropolis", "Pacifica", "New Sonora"]
	nation_stats.Nation_Name = nation_names[nation_stats.Nation]
	
	# Format the output
	nation_stats.Pop_w_College_pct = string.(round.(nation_stats.College_pct, digits=2), "%")
	nation_stats.Pop_w_GRAD_pct = string.(round.(nation_stats.Grad_pct, digits=2), "%")
	
	# Select and rename final columns
	select!(nation_stats, [:Nation_Name, :Pop_w_College_pct, :Pop_w_GRAD_pct])
	rename!(nation_stats, :Nation_Name => :Nation)
	sort!(nation_stats, :Nation)
	
	return nation_stats
end
