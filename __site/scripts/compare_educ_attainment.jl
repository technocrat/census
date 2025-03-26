# SPDX-License-Identifier: MIT
using Census

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