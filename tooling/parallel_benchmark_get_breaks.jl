#!/usr/bin/env julia

# SCRIPT - Parallel benchmark for get_breaks with multiple thread counts
# Usage: julia --threads=48 parallel_benchmark_get_breaks.jl

using Census
using BenchmarkTools
using Statistics
using DataFrames
using Base.Threads: @threads, nthreads, threadid
using Printf: @sprintf

# Parallel implementation of natural_breaks
function parallel_natural_breaks(x::Vector{<:Real}, k::Int, num_threads::Int)
    # Sort the data
    sorted_x = sort(Float64.(x))
    n = length(sorted_x)
    
    # Initialize matrices for dynamic programming
    mat1 = zeros(n+1, k+1)
    mat2 = zeros(Int, n+1, k+1)
    
    # Initialize first class
    for i in 1:n
        mat1[i+1, 1] = sum((sorted_x[1:i] .- mean(sorted_x[1:i])).^2)
        mat2[i+1, 1] = 1
    end
    
    # Initialize one element per class
    for j in 2:k
        mat1[j, j] = 0
        mat2[j, j] = j
    end
    
    # Dynamic programming to find optimal breaks
    # This is the part we can parallelize
    for i in 2:n
        for j in 2:min(i, k)
            mat1[i+1, j] = Inf
            
            # Parallelize this inner loop
            if num_threads > 1
                results = zeros(i)
                indices = zeros(Int, i)
                
                @threads for l in 1:i
                    if l < i  # Skip the last element as it's handled separately
                        s = sum((sorted_x[l+1:i] .- mean(sorted_x[l+1:i])).^2)
                        results[l] = mat1[l+1, j-1] + s
                        indices[l] = l + 1
                    end
                end
                
                # Find the minimum manually
                min_val = Inf
                min_idx = 0
                for l in 1:i-1
                    if results[l] < min_val
                        min_val = results[l]
                        min_idx = indices[l]
                    end
                end
                
                mat1[i+1, j] = min_val
                mat2[i+1, j] = min_idx
            else
                # Original sequential algorithm
                for l in 1:i
                    s = sum((sorted_x[l+1:i] .- mean(sorted_x[l+1:i])).^2)
                    if mat1[l+1, j-1] + s < mat1[i+1, j]
                        mat1[i+1, j] = mat1[l+1, j-1] + s
                        mat2[i+1, j] = l + 1
                    end
                end
            end
        end
    end
    
    # Backtrack to find the breaks
    kclass = zeros(Int, k+1)
    kclass[k+1] = n
    
    for j in k:-1:1
        kclass[j] = mat2[kclass[j+1], j]
    end
    
    # Convert to actual values
    result = [sorted_x[1]]
    for i in 2:k
        if kclass[i] <= n && kclass[i] > 1
            result = vcat(result, sorted_x[kclass[i]])
        end
    end
    if result[end] != sorted_x[end]
        result = vcat(result, sorted_x[end])
    end
    
    return result
end

# Function to run benchmarks with different thread counts
function run_parallel_benchmarks(data::Vector{<:Real})
    println("Running parallel benchmarks...")
    
    # Thread counts to test
    max_threads = min(Threads.nthreads(), 48)
    thread_counts = [1]
    
    # Add power-of-2 thread counts
    t = 2
    while t <= max_threads
        push!(thread_counts, t)
        t *= 2
    end
    
    # Add max_threads if not already included
    if max_threads ∉ thread_counts
        push!(thread_counts, max_threads)
    end
    
    # Sort thread counts
    sort!(thread_counts)
    
    results = Dict()
    
    for num_threads in thread_counts
        println("Testing with $num_threads threads...")
        
        # Run jenks with specified number of threads
        time_result = @elapsed begin
            result = parallel_natural_breaks(data, 7, num_threads)
        end
        
        println("  Time: $(time_result * 1000) ms")
        results[num_threads] = time_result
    end
    
    return results
end

# Function to test original implementation
function benchmark_original(data::Vector{<:Real})
    println("Benchmarking original implementation...")
    
    styles = [:jenks, :kmeans, :quantile, :equal]
    results = Dict()
    
    for style in styles
        time_result = @elapsed begin
            result = get_breaks(data, 7, style=style)
        end
        
        println("  Style $style: $(time_result * 1000) ms")
        results[style] = time_result
    end
    
    return results
end

# Main function
function main()
    println("Census.jl Parallel get_breaks Benchmarking")
    println("=========================================")
    println("Julia Version: $(VERSION)")
    println("Threads Available: $(Threads.nthreads())")
    println()
    
    # Initialize census data
    println("Initializing census data...")
    us = init_census_data()
    println("Census data loaded: $(nrow(us)) rows")
    
    # Ensure pop is available
    if !hasproperty(us, :pop) || all(ismissing, us.pop)
        println("Error: Population data not available in census data")
        return
    end
    
    # Remove missing values for benchmarking
    pop_vector = collect(skipmissing(us.pop))
    println("Population vector ready with $(length(pop_vector)) values")
    
    # Benchmark original implementation
    println("\nBenchmarking original implementation:")
    orig_results = benchmark_original(pop_vector)
    
    # Run parallel benchmarks
    println("\nRunning parallel benchmarks for Jenks natural breaks:")
    parallel_results = run_parallel_benchmarks(pop_vector)
    
    # Display summary table
    println("\nSummary Results:")
    println("==============")
    println("Original Implementation:")
    for (style, time) in orig_results
        println("  $style: $(time * 1000) ms")
    end
    
    println("\nParallel Implementation (Jenks only):")
    println("Threads | Time (ms) | Speedup vs. Sequential")
    println("--------|----------|----------------------")
    base_time = parallel_results[1]
    for threads in sort(collect(keys(parallel_results)))
        time = parallel_results[threads]
        speedup = base_time / time
        println("  $(@sprintf("%2d", threads))     | $(@sprintf("%8.2f", time * 1000)) | $(@sprintf("%6.2f", speedup))x")
    end
end

main() 