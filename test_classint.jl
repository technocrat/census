#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Test script to demonstrate ClassInt functionality as a replacement for RCall

using Census
using DataFrames, DataFramesMeta

println("Loading census data...")
us = init_census_data()
println("Loaded $(nrow(us)) counties")

# Generate class breaks using various methods
println("\nGenerating breaks with ClassInt...")
pop_values = collect(skipmissing(us.pop))
breaks_kmeans = get_breaks(pop_values, 5, style=:kmeans)
breaks_jenks = get_breaks(pop_values, 5, style=:jenks)
breaks_quantile = get_breaks(pop_values, 5, style=:quantile)
breaks_equal = get_breaks(pop_values, 5, style=:equal)

println("\nBreaks using kmeans clustering:")
println(breaks_kmeans)

println("\nBreaks using Jenks natural breaks:")
println(breaks_jenks)

println("\nBreaks using quantiles:")
println(breaks_quantile)

println("\nBreaks using equal intervals:")
println(breaks_equal)

# Get all break methods at once as a dictionary
println("\nGetting all break methods at once:")
breaks_dict = get_breaks_dict(pop_values, 5)
println("Available methods: $(keys(breaks_dict))")

# Apply breaks to create bins
println("\nCreating population bins...")
us.pop_bins = customcut(us.pop, breaks_kmeans)

# Show summary of results
println("\nPopulation bin distribution:")
bin_counts = combine(groupby(us, :pop_bins), nrow => :count)
sort!(bin_counts, :pop_bins)
println(bin_counts)

println("\nTest completed successfully!") 