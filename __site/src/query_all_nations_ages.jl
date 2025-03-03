function query_all_nations_ages(nations::Vector{Vector{String}})
    # Create an array to hold all DataFrames
    nation_dfs = Vector{DataFrame}(undef, length(nations))
    
    # Process each nation group and store the resulting DataFrame
    for (i, nation) in enumerate(nations)
        nation_dfs[i] = query_nation_ages(nation)
        nation_dfs[i].male_pct   = nation_dfs[i].male ./ sum(nation_dfs[i].male) *- 1
        nation_dfs[i].female_pct = nation_dfs[i].female ./ sum(nation_dfs[i].female)
        
    end
    
    return nation_dfs
end