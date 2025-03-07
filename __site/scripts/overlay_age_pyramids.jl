function overlay_age_pyramids(df_base::DataFrame, top_dfs::Vector{DataFrame}, titles::Vector{String})
    # Check if we have matching numbers of dataframes and titles
    if length(top_dfs) != length(titles)
        error("Number of dataframes ($(length(top_dfs))) must match number of titles ($(length(titles)))")
    end
    
    figures = []
    
    # Calculate US percentages once (for efficiency)
    base_male_pct = df_base.male_pct
    base_female_pct = df_base.female_pct
    
    # Loop through each dataframe and title
    for (i, (df_top, title)) in enumerate(zip(top_dfs, titles))
        fig = Figure(size=(800, 600))
        ax = Axis(fig[1, 1])
        
        y_positions = 1:nrow(df_base)
        
        # Plot base population
        barplot!(ax, y_positions, base_male_pct, 
            direction=:x, 
            color=("gray", 0.25),
            label="US")
        barplot!(ax, y_positions, base_female_pct, 
            direction=:x, 
            color=("gray", 0.25))

        # Add reference lines
        for (i, (m, f)) in enumerate(zip(base_male_pct, base_female_pct))
            linesegments!(ax, [m, m], [i-0.4, i+0.6], color=(:black, 1), linestyle=:dot)
            linesegments!(ax, [f, f], [i-0.4, i+0.6], color=(:black, 1), linestyle=:dot)
        end
        
        # Calculate and plot top population percentages
        top_male_pct = df_top.male_pct 
        top_female_pct = df_top.female_pct
        
        barplot!(ax, y_positions, top_male_pct, 
            direction=:x, 
            color=("#b0c1e3", 0.9),
            label="Male")
        barplot!(ax, y_positions, top_female_pct, 
            direction=:x, 
            color=("#f8c8dc", 0.9),
            label="Female")

        # Setup formatting
        ax.yticks = (y_positions, df_base.age_group)
        ax.xlabel = "Percentage of Population"
        ax.ylabel = "Age Groups"
        ax.title = "$title Age Pyramid Compared to US"
        
        vlines!(ax, 0, color=:black, linewidth=1)
        axislegend(ax, position=:rt)
        ax.yreversed = false
        
        # Save the figure
        filename = "../img/$title Age Pyramid.png"
        save(filename, fig)
        
        # Add to collection if needed
        push!(figures, fig)
    end
    
    return figures
end