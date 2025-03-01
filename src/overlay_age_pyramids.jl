function overlay_age_pyramids(df_base::DataFrame,df_top::DataFrame,title::String)
    fig = Figure(size=(800, 600))
    ax  = Axis(fig[1, 1])
    
    y_positions = 1:nrow(df)
    male        = df_base.male_pct
    female      = df_base.female_pct
    # base colors low alphas to wash out
    barplot!(ax, y_positions, male, 
        direction=:x, 
        color=("gray", 0.25),  # Light blue color
        label="US")
    barplot!(ax, y_positions, female, 
        direction=:x, 
        color=("gray", 0.25))#,  # Light pink color
        #label="US Female")

    # Add reference lines for US values - with small vertical offset for bar height
    for (i, (m, f)) in enumerate(zip(male, female))
        # For male side (left)
        linesegments!(ax, [m, m], [i-0.4, i+0.6], color=(:black, 1), linestyle=:dot)
        # For female side (right)
        linesegments!(ax, [f, f], [i-0.4, i+0.6], color=(:black, 1), linestyle=:dot)
    end
    
    male   = df_top.male_pct .* -1
    female = df_top.female_pct    
    barplot!(ax, y_positions, male, 
        direction=:x, 
        color=("#b0c1e3", 0.9),  # Light blue color
        label="Male")
    barplot!(ax, y_positions, female, 
        direction=:x, 
        color=("#f8c8dc", 0.9),  # Light pink color
        label="Female")

    # Rest of your code...
    ax.yticks = (y_positions, df.age_group)
    ax.xlabel = "Percentage of Population"
    ax.ylabel = "Age Groups"
    ax.title  = "$title Age Pyramid"
    
    # Add a zero line
    vlines!(ax, 0, color=:black, linewidth=1)
    
    # Add legend
    axislegend(ax, position=:rt)
    
    # Reverse y-axis true to have youngest at bottom
    ax.yreversed = false
    
    return fig
end
