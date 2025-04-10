#!/usr/bin/env julia

# SCRIPT - Benchmark get_breaks with different numbers of threads

using Census
using BenchmarkTools
using Statistics
using DataFrames

# Function to run benchmark with specified number of threads
function run_benchmark(threads::Int)
    old_threads = Threads.nthreads()
    
    # We can't change the number of threads at runtime in Julia
    # So we'll note this in the output
    if threads != old_threads
        println("NOTE: Current thread count is $old_threads, requested $threads")
        println("      To change thread count, restart Julia with --threads=$threads")
    end
    
    # Initialize census data
    println("Initializing census data...")
    us = init_census_data()
    println("Census data loaded: $(nrow(us)) rows")
    
    # Ensure pop is available
    if !hasproperty(us, :pop) || all(ismissing, us.pop)
        println("Error: Population data not available in census data")
        return nothing
    end
    
    # Remove missing values for benchmarking
    pop_vector = collect(skipmissing(us.pop))
    println("Population vector ready with $(length(pop_vector)) values")
    
    # Run benchmark for each style
    styles = [:jenks, :kmeans, :quantile, :equal]
    results = Dict{Symbol, BenchmarkTools.Trial}()
    
    for style in styles
        println("Benchmarking get_breaks with style=$style...")
        results[style] = @benchmark get_breaks($pop_vector, 7, style=$style)
    end
    
    return results
end

# Main function
function main()
    println("Census.jl get_breaks Benchmarking")
    println("=================================")
    println("Julia Version: $(VERSION)")
    println("Threads Available: $(Threads.nthreads())")
    println()
    
    # Run benchmark
    results = run_benchmark(Threads.nthreads())
    
    # Display results
    if results !== nothing
        println("\nBenchmark Results:")
        println("=================")
        
        for (style, trial) in results
            println("Style: $style")
            println("  Minimum time: $(minimum(trial).time / 1_000_000) ms")
            println("  Median time:  $(median(trial).time / 1_000_000) ms")
            println("  Mean time:    $(mean(trial).time / 1_000_000) ms")
            println("  Maximum time: $(maximum(trial).time / 1_000_000) ms")
            println("  Memory:       $(trial.memory / 1024) KB")
            println()
        end
    end
    
    # Run a small set of comparative tests with different numbers
    println("\nComparative Tests with Different Styles:")
    
    us = init_census_data()
    pop_vector = collect(skipmissing(us.pop))
    
    # Time each style
    for style in [:jenks, :kmeans, :quantile, :equal]
        t = @elapsed get_breaks(pop_vector, 7, style=style)
        println("Style: $style - Time: $(t*1000) ms")
    end
end

main() 