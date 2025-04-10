#!/usr/bin/env julia

# Basic ClassInt.jl usage example
using ClassInt
using CairoMakie
using DataFrames
using Random

# Set random seed for reproducibility
Random.seed!(123)

println("ClassInt.jl Basic Usage Example")
println("===============================")

# Create some sample data with a bimodal distribution
n = 100
values = vcat(
    randn(n÷2) .* 5 .+ 20,    # First mode centered at 20
    randn(n÷2) .* 10 .+ 60     # Second mode centered at 60
)
println("Generated $(length(values)) sample values")

# Calculate breaks using different methods
println("\nCalculating breaks with different methods:")
jenks_breaks = get_breaks(values, 5, style=:jenks)
kmeans_breaks = get_breaks(values, 5, style=:kmeans)
quantile_breaks = get_breaks(values, 5, style=:quantile)
equal_breaks = get_breaks(values, 5, style=:equal)

println("Jenks breaks:     ", round.(jenks_breaks, digits=2))
println("K-means breaks:   ", round.(kmeans_breaks, digits=2))
println("Quantile breaks:  ", round.(quantile_breaks, digits=2))
println("Equal breaks:     ", round.(equal_breaks, digits=2))

# Calculate all breaks at once with get_breaks_dict
println("\nUsing get_breaks_dict:")
breaks_dict = get_breaks_dict(values, 5)
for (method, breaks) in breaks_dict
    println("$method breaks: ", round.(breaks, digits=2))
end

# Visualize the data and breaks
println("\nVisualizing the data and breaks...")

# Sort the data for better visualization
sorted_values = sort(values)

# Create a figure to show all methods
fig = Figure(resolution=(1000, 800), fontsize=12)

# Histogram with data distribution
ax1 = Axis(fig[1, 1:2], 
          title="Data Distribution", 
          xlabel="Value", 
          ylabel="Count")
hist!(ax1, values, bins=20, color=:lightblue, strokewidth=1, strokecolor=:white)

# Plot the sorted data with different breaks
methods = [:jenks, :kmeans, :quantile, :equal]
break_sets = [jenks_breaks, kmeans_breaks, quantile_breaks, equal_breaks]
titles = ["Jenks Natural Breaks", "K-means Breaks", "Quantile Breaks", "Equal Interval Breaks"]
colors = [:firebrick, :royalblue, :darkgreen, :purple]

for (i, (method, breaks, title, color)) in enumerate(zip(methods, break_sets, titles, colors))
    # Plot the sorted data points
    row = i ÷ 2 + 2
    col = i % 2 + 1
    
    ax = Axis(fig[row, col], 
              title=title, 
              xlabel="Index", 
              ylabel="Value")
    
    # Plot the data
    scatter!(ax, 1:length(sorted_values), sorted_values, 
             markersize=4, color=:black, alpha=0.5)
    
    # Add break lines
    for b in breaks
        hlines!(ax, b, color=color, linewidth=2)
    end
    
    # Add annotations for break values
    for (j, b) in enumerate(breaks)
        text!(ax, length(sorted_values) * 0.05, b + 2, 
              text="$(round(b, digits=1))", 
              fontsize=10, align=(:left, :bottom), color=color)
    end
    
    # Adjust y-axis limits
    min_val, max_val = extrema(values)
    padding = (max_val - min_val) * 0.1
    ylims!(ax, min_val - padding, max_val + padding)
end

# Save the visualization
save_path = "classint_comparison.png"
save(save_path, fig)
println("Visualization saved to $save_path")

println("\nExample completed successfully!") 