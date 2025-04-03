# SPDX-License-Identifier: MIT

"""
    calculate_dependency_ratio(df::DataFrame)

Calculate the dependency ratio (ratio of persons aged 65+ to those aged 16-64) from a DataFrame
containing male and female age data.

# Arguments
- `df::DataFrame`: DataFrame containing age group data with columns :male and :female

# Returns
- Float64: The calculated dependency ratio rounded to 2 decimal places
"""
function calculate_dependency_ratio(df::DataFrame)
    # Initialize population sums
    young_pop   = 0.0
    old_pop     = 0.0
    working_pop = 0.0
    
    for row in eachrow(df)
        total = row.male + row.female  # Get total population for the age group
        
        # Check age group and add to appropriate category
        if occursin("Under 5", row.age_group) || 
           occursin("5 to 9", row.age_group)  || 
           occursin("10 to 14", row.age_group)
           young_pop += total
        elseif occursin("65", row.age_group) || 
               occursin("70", row.age_group) || 
               occursin("75", row.age_group) || 
               occursin("80", row.age_group) || 
               occursin("85", row.age_group)
           old_pop += total
        else
           working_pop += total
        end
    end
    
    # Calculate dependency ratio
    return round((young_pop + old_pop) / working_pop * 100, digits=2)
end

"""
    gini(v::Vector{Int})

Calculate the Gini coefficient for a vector of values, which measures income inequality.

# Arguments
- `v::Vector{Int}`: Vector of values (e.g., income data)

# Returns
- Float64: The Gini coefficient between 0 and 1, where:
  - 0 represents perfect equality
  - 1 represents perfect inequality
"""
function gini(v::Vector{Int})
    # Ensure the input vector is sorted
    sorted_v = sort(v)
    
    # Calculate the cumulative sum of the sorted vector
    S = cumsum(sorted_v)
    
    # Calculate the Gini coefficient using the formula
    n = length(v)
    numerator = 2 * sum(i * y for (i, y) in enumerate(sorted_v))
    denominator = n * sum(sorted_v)
    
    # Return the Gini coefficient
    return (numerator / denominator - (n + 1)) / n
end

"""
    collect_state_ages(state_vectors::Vector{Vector{String}}, state_names::Dict)

Collect age data for multiple groups of states and calculate dependency ratios.

# Arguments
- `state_vectors::Vector{Vector{String}}`: Vector of state abbreviation vectors
- `state_names::Dict`: Dictionary mapping state abbreviations to full names

# Returns
- Vector{DataFrame}: Vector of DataFrames containing state names and dependency ratios
"""
function collect_state_ages(state_vectors::Vector{Vector{String}}, state_names::Dict)
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

"""
    query_all_nation_ages(nations::Vector{Vector{String}})

Query age data for multiple nation groups and calculate percentage distributions.

# Arguments
- `nations::Vector{Vector{String}}`: Vector of state abbreviation vectors representing nations

# Returns
- Vector{DataFrame}: Vector of DataFrames containing age data with percentage distributions
"""
function query_all_nation_ages(nations::Vector{Vector{String}})
    # Create an array to hold all DataFrames
    nation_dfs = Vector{DataFrame}(undef, length(nations))
    
    # Process each nation group and store the resulting DataFrame
    for (i, nation) in enumerate(nations)
        nation_dfs[i] = query_nation_ages(nation)
        nation_dfs[i].male_pct   = nation_dfs[i].male ./ sum(nation_dfs[i].male) * -1
        nation_dfs[i].female_pct = nation_dfs[i].female ./ sum(nation_dfs[i].female)
    end
    
    return nation_dfs
end

"""
    get_state_gdp()

Retrieve and aggregate state GDP data from the database.

# Returns
- DataFrame: DataFrame containing state-level GDP totals
"""
function get_state_gdp()
    gdp_query = """
        SELECT gdp.county, gdp.state, gdp.gdp
        FROM gdp
    """
    df = q(gdp_query)
    return combine(groupby(df, :state), :gdp => sum => :gdp)
end

# Export all functions
export calculate_dependency_ratio,
       gini,
       collect_state_ages,
       query_all_nation_ages,
       get_state_gdp 