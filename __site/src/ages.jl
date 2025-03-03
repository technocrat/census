include("setup.jl")

dependency_dfs 	   = collect_state_ages(nations,state_names)
state_age_dfs 	   = collect_state_age_dataframes(nations)

output_dependency_ratio_tables(dependency_dfs,Titles)

base_df 		   = get_us_ages()
base_df.male_pct   = base_df.male ./ sum(base_df.male) .* -1
base_df.female_pct = base_df.female ./ sum(base_df.female) 
top_dfs 		   = query_all_nation_ages(nations)

output_dependency_ratio_tables(dependency_dfs,Titles)
overlay_age_pyramids(base_df,top_df,Titles)
create_nation_age_pyramids(state_age_dfs, nations, Titles)
create_birth_table()
collect_and_output_birth_tables(births, nations, state_names, Titles, "../_layout/partials/")
births.TFR = births.Rate .* 30 ./ 1000
