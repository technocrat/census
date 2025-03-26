# SPDX-License-Identifier: MIT
# Create a heatmap visualization
function plot_education_heatmap(df)
    # Get education percentage columns and nations
    edu_cols = [:None_pct, :High_School_Diploma_pct, :GED_pct, :Some_college_pct, 
               :AA_pct, :BA_pct, :MS_pct, :PD_pct, :PHD_pct]
    
    # Create cleaner labels
    edu_labels = ["None", "High School", "GED", "Some College", 
                 "Associate", "Bachelor's", "Master's", "Professional", "PhD"]
    
    # Extract the data as a matrix
    nations = df.Nation
    data_matrix = Matrix(df[:, edu_cols])
    
    # Create the heatmap
    Plots.heatmap(edu_labels, nations, data_matrix',
            title="Educational Attainment by Nation (%)",
            xlabel="Education Level",
            ylabel="Nation",
            c=:viridis,
            aspect_ratio=:auto,
            size=(800, 600),
            right_margin=15mm)
end

# Create a Cleveland dot plot - good for comparing specific values
function plot_cleveland_dots(df)
    # Get education percentage columns
    edu_cols = [:None_pct, :High_School_Diploma_pct, :GED_pct, :Some_college_pct, 
               :AA_pct, :BA_pct, :MS_pct, :PD_pct, :PHD_pct]
    
    # Create cleaner labels
    edu_labels = ["None", "High School", "GED", "Some College", 
                 "Associate", "Bachelor's", "Master's", "Professional", "PhD"]
    
    # Extract the data
    nations = df.Nation
    
    # Plot each education level
    p = Plots.plot(layout=(3,3), size=(1000, 800), margin=5mm)
    
    for (i, col) in enumerate(edu_cols)
        # Sort data for this education level
        sorted_idx = sortperm(df[:, col])
        sorted_nations = nations[sorted_idx]
        sorted_values = df[sorted_idx, col]
        
        # Plot the dots
        subplot = Plots.plot!(p, sorted_values, 1:length(sorted_nations), 
                        seriestype=:scatter,
                        xlabel="Percentage",
                        yticks=(1:length(sorted_nations), sorted_nations),
                        title=edu_labels[i],
                        legend=false,
                        grid=true,
                        subplot=i)
        
        # Add a line connecting the dots
        Plots.plot!(p, sorted_values, 1:length(sorted_nations), 
              seriestype=:line,
              subplot=i,
              alpha=0.5)
    end
    
    Plots.plot!(p, plot_title="Educational Attainment by Nation (%)")
    return p
end

# Generate a small increment style table (similar to sparklines)
function table_vis(df)
    edu_cols = [:None_pct, :High_School_Diploma_pct, :GED_pct, :Some_college_pct, 
               :AA_pct, :BA_pct, :MS_pct, :PD_pct, :PHD_pct]
    
    # For each column, create a normalized version (0-1 scale)
    vis_df = DataFrame(Nation = df.Nation)
    
    for col in edu_cols
        min_val = minimum(df[:, col])
        max_val = maximum(df[:, col])
        range_val = max_val - min_val
        
        # Create a normalized column
        norm_col = Symbol(string(col, "_norm"))
        vis_df[!, norm_col] = (df[:, col] .- min_val) ./ range_val
        
        # Create the original value column
        vis_df[!, col] = df[:, col]
    end
    
    # Sort by a specific column of interest (e.g., BA_pct)
    sort!(vis_df, :BA_pct, rev=true)
    
    return vis_df
end

# Choose one of these visualizations to execute
# plot_education_heatmap(nation_stats)
# plot_cleveland_dots(nation_stats)
# table_vis(nation_stats)

# Get education data for all nations
df = process_education_by_nation()

# Create figure
fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Education Attainment by Nation", fontsize=20)

# Plot data
ga1 = ga(1, 1, "Bachelor's Degree or Higher")
poly1 = map_poly(df, ga1, "bachelors_or_higher")
add_labels!(df, ga1, :geoid, fontsize=6)

display(fig)
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