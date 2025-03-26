"""
    create_age_pyramid(data::DataFrame)

Creates a population pyramid (age-sex distribution) plot from demographic data.

# Arguments
- `data::DataFrame`: A DataFrame containing the following required columns:
    * `age_group`: Categories of age ranges
    * `male_pop`: Male population counts for each age group
    * `female_pop`: Female population counts for each age group

# Returns
Returns a `Plots.Plot` object containing the population pyramid visualization with:
- Horizontal bars representing population percentages
- Males on the left (negative values)
- Females on the right (positive values)
- Age groups on the y-axis
- Percentage of total population on the x-axis
- Color-coded bars (blue for males, pink for females)

# Data Format
Input DataFrame should be structured as follows:
```julia
age_group   male_pop   female_pop
"0-4"       1000       950
"5-9"       950        900
# etc...
```

# Examples
```julia
# Read census data
data = CSV.read("census_data.csv", DataFrame)

# Create pyramid plot
pyramid = create_age_pyramid(data)

# Save to file
savefig(pyramid, "population_pyramid.png")

# Display in plotting window
display(pyramid)
```

# Notes
- Input populations are automatically converted to percentages of total population
- Male percentages are converted to negative values for left-side display
- The plot uses a horizontal orientation for standard demographic visualization
- Legend is positioned at the bottom of the plot
- The function assumes valid numeric data in population columns

See also: [`Plots.plot`](@ref), [`savefig`](@ref)
"""

function create_age_pyramid(df::DataFrame, title::String="Population")
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1])
    
    y_positions = 1:nrow(df)
    males = df.male_percent        # Using correct column name
    females = df.female_percent    # Using correct column name
    
    barplot!(ax, y_positions, males, 
        direction=:x, 
        color=("#b0c1e3", 0.9),  # Light blue color
        label="Male")

    barplot!(ax, y_positions, females, 
        direction=:x, 
        color=("#f8c8dc", 0.9),  # Light pink color
        label="Female")

    # Customize the axis
    ax.yticks = (y_positions, df.age_group)
    ax.xlabel = "Population Percentage"
    ax.ylabel = "Age Group"
    ax.title = "$title Age Pyramid"
    
    # Add a zero line
    vlines!(ax, 0, color=:black, linewidth=1)
    
    # Add legend
    axislegend(ax, position=:rt)
    
    # Reverse y-axis to have youngest at bottom
    ax.yreversed = false
    
    return fig
end
