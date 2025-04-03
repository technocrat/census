# SPDX-License-Identifier: MIT

"""
# Visualization Module

This module provides a comprehensive set of visualization functions for demographic and geographic data analysis.
It includes functions for creating population pyramids, Cleveland dot plots, birth rate tables, and various map visualizations.
"""

using DataFrames
using Plots
using CairoMakie
using GeoMakie
using Polynomials
using CSV
using Dates
using Measures

# Constants for visualization
const DEFAULT_PLOT_SIZE = (1000, 600)
const DEFAULT_MARGIN = 25mm  # Use mm directly as a unit, not as a function
const MALE_COLOR = ("#b0c1e3", 0.9)    # Light blue
const FEMALE_COLOR = ("#f8c8dc", 0.9)  # Light pink
const TREND_COLOR = :red
const THRESHOLD_COLOR = :green
const REFERENCE_COLOR = :gray

"""
    cleveland_dot_plot(df::DataFrame, value_col::Symbol, label_col::Symbol; 
                      xlabel::String="", title::String="Cleveland Dot Plot")

Create a Cleveland dot plot with polynomial trend line and reference features.

# Arguments
- `df::DataFrame`: Input DataFrame containing the data
- `value_col::Symbol`: Column name for the values to be plotted on x-axis
- `label_col::Symbol`: Column name for the labels to be shown on y-axis
- `xlabel::String`: Label for x-axis (default: "")
- `title::String`: Title for the plot (default: "Cleveland Dot Plot")

# Features
- Sorts data by value in descending order
- Adds a 3rd-degree polynomial trend line
- Shows 80% threshold line
- Includes reference lines to y-axis
- Formats x-axis labels in thousands (K)

# Returns
- A Plots.Plot object
"""
function cleveland_dot_plot(df::DataFrame, 
                          value_col::Symbol, 
                          label_col::Symbol,
                          xlabel::String="",
                          title::String="Cleveland Dot Plot")
    # Drop any rows with missing values and sort
    df_clean  = DataFrames.dropmissing(df, [value_col, label_col])
    df_sorted = DataFrames.sort(df_clean, value_col, rev=true)
    
    # Calculate 80% threshold using non-missing values
    value_threshold = sum(skipmissing(df_clean[:, value_col])) * 0.8
    
    # Create positions array for curve fitting
    positions = 1:DataFrames.nrow(df_sorted)
    values    = collect(df_sorted[:, value_col])
    
    # Fit polynomial curve
    poly_fit  = Polynomials.fit(positions, Float64.(values), 3)
    
    # Create interpolated points for smoother curve
    x_smooth  = range(1, DataFrames.nrow(df_sorted), length=100)
    y_smooth  = poly_fit.(x_smooth)
    
    # Fixed x-axis limits
    x_min = 0
    x_max = 1_600_000
    
    p = Plots.plot(
        values,
        positions,
        seriestype = :scatter,
        marker     = (:circle, 8),
        color      = :blue,
        legend     = false,
        xlabel     = xlabel,
        title      = title,
        yticks     = (1:DataFrames.nrow(df_sorted), df_sorted[:, label_col]),
        yflip      = true,
        grid       = (:x, :gray, 0.2),
        size       = (1000, max(400, 20 * DataFrames.nrow(df_sorted))),
        margin     = DEFAULT_MARGIN,
        xlims      = (x_min, x_max),
        xticks     = 0:200_000:1_600_000,
        formatter  = :plain,
        xformatter = x -> string(round(Int, x/1000), "K")
    )
    
    # Add the fitted curve
    Plots.plot!(y_smooth, x_smooth, 
        color     = TREND_COLOR, 
        linewidth = 2, 
        alpha     = 0.6,
        label     = "Trend"
    )
    
    # Add vertical line at 80% threshold
    Plots.vline!([value_threshold], 
        color     = THRESHOLD_COLOR, 
        linewidth = 2, 
        linestyle = :dash,
        label     = "80% of Total"
    )
    
    # Add reference lines connecting to y-axis
    for i in 1:DataFrames.nrow(df_sorted)
        Plots.plot!(
            [0, values[i]], 
            [i, i], 
            color     = REFERENCE_COLOR, 
            alpha     = 0.3,
            linewidth = 0.5
        )
    end
    
    return p
end

"""
    create_age_pyramid(df::DataFrame, title::String="Population")

Creates a population pyramid (age-sex distribution) plot from demographic data.

# Arguments
- `df::DataFrame`: A DataFrame containing age_group, male_percent, and female_percent columns
- `title::String`: Title for the plot (default: "Population")

# Returns
Returns a `Figure` object containing the population pyramid visualization with:
- Horizontal bars representing population percentages
- Males on the left (negative values)
- Females on the right (positive values)
- Age groups on the y-axis
- Percentage of total population on the x-axis
- Color-coded bars (blue for males, pink for females)
"""
function create_age_pyramid(df::DataFrame, title::String="Population")
    fig = CairoMakie.Figure(size=DEFAULT_PLOT_SIZE)
    ax = CairoMakie.Axis(fig[1, 1])
    
    y_positions = 1:DataFrames.nrow(df)
    males = df.male_percent
    females = df.female_percent
    
    CairoMakie.barplot!(ax, y_positions, males, 
        direction=:x, 
        color=MALE_COLOR,
        label="Male")

    CairoMakie.barplot!(ax, y_positions, females, 
        direction=:x, 
        color=FEMALE_COLOR,
        label="Female")

    # Customize the axis
    ax.yticks = (y_positions, df.age_group)
    ax.xlabel = "Population Percentage"
    ax.ylabel = "Age Group"
    ax.title = "$title Age Pyramid"
    
    # Add a zero line
    CairoMakie.vlines!(ax, 0, color=:black, linewidth=1)
    
    # Add legend
    CairoMakie.axislegend(ax, position=:rt)
    
    # Reverse y-axis to have youngest at bottom
    ax.yreversed = false
    
    return fig
end

"""
    create_birth_table()

Creates a table of birth rates and total fertility rates (TFR) for each state.

# Returns
Returns a DataFrame containing:
- State names
- Number of births
- Birth rates (per thousand childbearing-age women)
- Total fertility rates (TFR)

# Notes
- Uses data from "../data/births.csv"
- Calculates childbearing population for each state
- Handles state name variations (e.g., "lowa" → "Iowa")
"""
function create_birth_table()
    births = CSV.read("../data/births.csv", DataFrame)
    state_age_dfs = collect_state_age_dataframes(nations)
    
    # Create a dictionary to store the results
    childbearing_pop = Dict{String, Float64}()
    
    # Iterate over the postal codes and apply the function
    for state in postals
        childbearing_pop[state] = get_childbearing_population(state_age_dfs[state])
    end
    
    # Create a mapping from full state names to postal codes
    name_to_postal = Dict(fullname => code for (code, fullname) in state_names)
    
    # Create an array to hold the birth rates
    birth_rates = Float64[]
    
    # For each state in the births dataframe
    for row in eachrow(births)
        state_name = row.State
        
        # Handle the misspelling of "Iowa" as "lowa" if needed
        if state_name == "lowa"
            state_name = "Iowa"
        end
        
        # Get the postal code
        postal = name_to_postal[state_name]
        
        # Get the childbearing population
        population = childbearing_pop[postal]
        
        # Calculate births per thousand mothers
        birth_rate = row.Births / population
        
        # Add to the array
        push!(birth_rates, birth_rate)
    end
    
    # Now add the columns to the dataframe
    births[!, :Rate] = birth_rates
    births[!, :TFR]  = births.Rate .* 30 ./ 1000
    
    return births
end

"""
    save_plot(plot, title::String; format::String="png", directory::String="img") -> String

Save a plot to a specified directory with a given title and format.

# Arguments
- `plot`: A Plots.Plot or Makie.Figure object to save
- `title::String`: Title to use in the filename
- `format::String="png"`: Output format (default: "png")
- `directory::String="img"`: Target directory (default: "img")

# Returns
- `String`: Absolute path to the saved file

# Example
```julia
using CairoMakie
fig = Figure()
# ... create plot ...
save_plot(fig, "My Plot")  # Saves to img/My_Plot_TIMESTAMP.png
```

# Notes
- Creates the target directory if it doesn't exist
- Sanitizes title for use in filename
- Adds timestamp to filename to prevent overwrites
- Supports both Plots.jl and Makie plots
- Uses absolute paths for reliable file operations
"""
function save_plot(plot, title::String; format::String="png", directory::String="img")
    # Convert to absolute path if relative
    if !isabspath(directory)
        directory = abspath(directory)
    end
    
    # Create directory if it doesn't exist
    mkpath(directory)
    
    # Create timestamp
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    
    # Sanitize title for filename
    safe_title = replace(title, r"[^a-zA-Z0-9]" => "_")
    
    # Create filename with absolute path
    filename = joinpath(directory, "$(safe_title)_$(timestamp).$(format)")
    
    # Save the plot
    if plot isa Plots.Plot
        Plots.savefig(plot, filename)
    elseif plot isa Figure
        save(filename, plot, px_per_unit=2)  # Increased resolution
    else
        error("Unsupported plot type: $(typeof(plot))")
    end
    
    @info "Plot saved to: $filename"
    return filename
end

"""
    format_number(n::Number; precision::Int=0)

Formats a number with commas and optional decimal precision.

# Arguments
- `n::Number`: The number to format
- `precision::Int`: Number of decimal places (default: 0)

# Returns
- Formatted string with commas and specified precision
"""
function format_number(n::Number; precision::Int=0)
    return format(n, commas=true, precision=precision)
end 