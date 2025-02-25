"""
# Usage example:
state_dfs = Dict(
    state => state_query(state) 
    for state in ["MA", "CT", "RI", "VT", "NH", "ME"]
)
"""
function create_multiple_age_pyramids(state_dfs::Dict{String, DataFrame})
    fig = Figure(size=(1600, 1200))
    
    # Create a 2x3 grid for 6 states
    row = 1
    col = 1
    
    for (state, df) in state_dfs
        # Create axis in the correct grid position
        ax = Axis(fig[row, col])
        
        y_positions = 1:nrow(df)
        males = df.male ./ sum(df.male) .* -100  # Convert to percentage
        females = df.female ./ sum(df.female) .* 100
        
        barplot!(ax, y_positions, males, 
            direction=:x, 
            color=("#b0c1e3", 0.9),
            label="Male")

        barplot!(ax, y_positions, females, 
            direction=:x, 
            color=("#f8c8dc", 0.9),
            label="Female")

        # Customize the axis
        ax.yticks = (y_positions, df.age_group)
        ax.xlabel = "Population %"
        ax.title = "$state Age Pyramid"
        
        # Only show y-axis labels on leftmost plots
        if col != 1
            hideydecorations!(ax, ticks=false, grid=false)
        end
        
        vlines!(ax, 0, color=:black, linewidth=1)
        axislegend(ax, position=:rt)
        ax.yreversed = false
        
        # Handle grid position
        col += 1
        if col > 3
            col = 1
            row += 1
        end
    end
    
    return fig
end

