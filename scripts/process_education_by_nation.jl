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
		:None => sum,
		:High_School_Diploma => sum,
		:GED => sum,
		:Some_college => sum,
		:AA => sum,
		:BA => sum,
		:MS => sum,
		:PD => sum,
		:PHD => sum
	)
	
	# Calculate percentages for each education level by nation
	for col in [:None, :High_School_Diploma, :GED, :Some_college, :AA, :BA, :MS, :PD, :PHD]
		nation_stats[!, Symbol(string(col) * "_pct")] = 
			100 * nation_stats[!, Symbol(string(col) * "_sum")] ./ nation_stats.Population_sum
	end
	
	# Add descriptive names for the nations
	nation_names = ["New England", "Appalachia", "Mountain West", "Deep South", 
					"Midwest", "Great Plains", "Gulf Coast", "Mid-Atlantic", 
					"Pacific Northwest", "Southwest"]
	nation_stats.Nation_Name = nation_names[nation_stats.Nation]
	
	return nation_stats
end
