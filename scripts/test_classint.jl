#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Import Census module (exports all necessary functions)
using Census
using DataFrames, DataFramesMeta
using CairoMakie

println("Testing ClassInt implementation")
println("================================")

# Create a test array
test_values = [1, 3, 5, 7, 9, 11, 13, 22, 35, 51, 65, 80, 90, 100]
println("Test values: ", test_values)

# Test different classification methods
println("\nCalculating breaks:")
println("-------------------")
jenks_breaks = get_breaks(test_values, 5, style=:jenks)
kmeans_breaks = get_breaks(test_values, 5, style=:kmeans)
quantile_breaks = get_breaks(test_values, 5, style=:quantile)
equal_breaks = get_breaks(test_values, 5, style=:equal)

println("Jenks breaks:     ", jenks_breaks)
println("K-means breaks:   ", kmeans_breaks)
println("Quantile breaks:  ", quantile_breaks)
println("Equal breaks:     ", equal_breaks)

# Test the dictionary method (similar to R's classInt output)
println("\nTesting get_breaks_dict:")
println("------------------------")
breaks_dict = get_breaks_dict(test_values, 5)
for (method, breaks) in breaks_dict
    println("$method breaks: $breaks")
end

# Initialize census data and test with real data
println("\nTesting with real census data:")
println("-----------------------------")
us = init_census_data()
println("Loaded $(nrow(us)) counties")

# Process population data
println("Calculating breaks for population data")
pop_values = us.pop
real_breaks = get_breaks(pop_values, 7, style=:jenks)
println("Population breaks (jenks): ", real_breaks)

# Create a simple visualization of the breaks
println("\nCreating visualization:")
println("----------------------")

# Create some simulated data
n = 1000
x = sort(rand(n) .* 100)

# Get breaks for visualization
vis_breaks = get_breaks(x, 5, style=:jenks)

# Visualize
fig = Figure(size=(900, 600))

# Plot the data distribution
ax1 = Axis(fig[1, 1], 
           title="Data Distribution with Jenks Breaks", 
           xlabel="Value", 
           ylabel="Index")
scatter!(ax1, x, 1:n, markersize=3, color=:black, alpha=0.5)

# Add break lines
for b in vis_breaks
    vlines!(ax1, b, color=:red, linewidth=2)
end

# Display break values
annotations = ["Break: $(round(b, digits=2))" for b in vis_breaks]
for (i, b) in enumerate(vis_breaks)
    text!(ax1, b + 1, n/2 + i*30, text=annotations[i], 
          fontsize=12, align=(:left, :center))
end

# Create a histogram with the breaks
ax2 = Axis(fig[2, 1], 
           title="Histogram with Jenks Breaks", 
           xlabel="Value", 
           ylabel="Count")
hist!(ax2, x, bins=50)

# Add break lines to histogram
for b in vis_breaks
    vlines!(ax2, b, color=:red, linewidth=2)
end

# Save the figure
save("classint_test_visualization.png", fig)
println("Visualization saved to classint_test_visualization.png")

println("\nClassInt test completed successfully!") 