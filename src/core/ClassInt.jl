# SPDX-License-Identifier: MIT

"""
ClassInt module - Pure Julia implementation of the R classInt package functionality

This module provides functions for creating class intervals for mapping or other graphical purposes,
similar to the R classInt package. It implements various classification methods including:

1. Fisher-Jenks natural breaks (jenks)
2. K-means clustering (kmeans)
3. Quantile breaks (quantile)
4. Equal interval breaks (equal)
5. Fixed

No external dependencies on R are required.
"""
module ClassInt

using Clustering
using StatsBase
using Statistics

export get_breaks, fixed_breaks, equal_breaks, kmeans_breaks, quantile_breasks, fisher_breaks

function fixed_breaks(v::Vector, breaks::Vector{Int})
    # Ensure the breaks are sorted and within bounds
    breaks = sort(breaks)
    if any(b < 1 || b > length(v) for b in breaks)
        throw(ArgumentError("Break indices must be within the range of the vector."))
    end
    # Remove missing values
    v_clean = collect(skipmissing(v))
    # Add start and end points to the break indices
    all_breaks = [0; breaks; length(v_clean)]
    
    # Split the vector into sub-vectors based on the breaks
    return [v_clean[all_breaks[i]+1:all_breaks[i+1]] for i in 1:length(all_breaks)-1]
end

"""
    get_breaks(x::Vector{<:Real}, n::Int=7; style::Symbol=:jenks) -> Vector{Float64}

Calculate breaks for binning data using the specified classification method.

# Arguments
- `x`: Vector of numeric values (will skip missing values)
- `n`: Number of classes (resulting in n+1 break points)
- `style`: Classification method (:jenks, :kmeans, :quantile, or :equal)

# Returns
- `Vector{Float64}`: Vector of break points (including min and max values)

# Example
```julia
values = [1, 5, 7, 9, 10, 15, 20, 30, 50, 100]
breaks = get_breaks(values, 5, style=:jenks)
# Output: [1.0, 7.0, 15.0, 30.0, 50.0, 100.0]
```
"""
function get_breaks(x::Vector{T}, n::Int=7; style::Symbol=:jenks) where T<:Union{Real, Missing}
    # Remove missing values
    x_clean = collect(skipmissing(x))
    
    if isempty(x_clean)
        error("Input vector contains no non-missing values")
    end
    
    if n <= 1
        error("Number of classes must be at least 2")
    end
    
    if length(x_clean) <= n
        @warn "Number of unique values ($(length(unique(x_clean)))) is less than or equal to the number of classes ($n)"
        return sort(unique(x_clean))
    end
    
    # Select the appropriate classification method
    if style == :jenks
        return natural_breaks(x_clean, n)
    elseif style == :kmeans
        return kmeans_breaks(x_clean, n)
    elseif style == :quantile
        return quantile_breaks(x_clean, n)
    elseif style == :equal
        return equal_interval_breaks(x_clean, n)
    else
        error("Unknown style: $style. Use :jenks, :kmeans, :quantile, or :equal")
    end
end

"""
    natural_breaks(x::Vector{<:Real}, k::Int) -> Vector{Float64}

Calculate Fisher-Jenks natural breaks optimization.
This is an implementation of the Jenks Natural Breaks algorithm.

# Arguments
- `x`: Vector of numeric values
- `k`: Number of classes (resulting in k+1 break points)

# Returns
- `Vector{Float64}`: Vector of break points (including min and max values)
"""
function natural_breaks(x::Vector{<:Real}, k::Int)
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
    for i in 2:n
        for j in 2:min(i, k)
            mat1[i+1, j] = Inf
            
            for l in 1:i
                s = sum((sorted_x[l+1:i] .- mean(sorted_x[l+1:i])).^2)
                if mat1[l+1, j-1] + s < mat1[i+1, j]
                    mat1[i+1, j] = mat1[l+1, j-1] + s
                    mat2[i+1, j] = l + 1
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

"""
    kmeans_breaks(x::Vector{<:Real}, k::Int) -> Vector{Float64}

Calculate breaks using k-means clustering.

# Arguments
- `x`: Vector of numeric values
- `k`: Number of classes (resulting in k+1 break points)

# Returns
- `Vector{Float64}`: Vector of break points (including min and max values)
"""
function kmeans_breaks(x::Vector{<:Real}, k::Int)
    # Reshape data for clustering
    data = reshape(Float64.(x), 1, :)
    
    # Run k-means clustering
    result = kmeans(data, k)
    
    # Get cluster centers and sort them
    centers = vec(result.centers)
    sort!(centers)
    
    # Calculate min and max for complete breaks
    min_val = minimum(x)
    max_val = maximum(x)
    
    # Return complete breaks including min and max
    return unique([min_val; centers; max_val])
end

"""
    quantile_breaks(x::Vector{<:Real}, k::Int) -> Vector{Float64}

Calculate breaks using quantiles.

# Arguments
- `x`: Vector of numeric values
- `k`: Number of classes (resulting in k+1 break points)

# Returns
- `Vector{Float64}`: Vector of break points (including min and max values)
"""
function quantile_breaks(x::Vector{<:Real}, k::Int)
    # Calculate quantiles
    probs = range(0, 1, length=k+1)
    breaks = quantile(x, probs)
    
    # Ensure first and last breaks match min and max exactly
    breaks[1] = minimum(x)
    breaks[end] = maximum(x)
    
    return unique(breaks)
end

"""
    equal_interval_breaks(x::Vector{<:Real}, k::Int) -> Vector{Float64}

Calculate breaks using equal intervals.

# Arguments
- `x`: Vector of numeric values
- `k`: Number of classes (resulting in k+1 break points)

# Returns
- `Vector{Float64}`: Vector of break points (including min and max values)
"""
function equal_interval_breaks(x::Vector{<:Real}, k::Int)
    min_val = minimum(x)
    max_val = maximum(x)
    
    # Create equally spaced breaks
    interval = (max_val - min_val) / k
    breaks = [min_val + i * interval for i in 0:k]
    
    return breaks
end

"""
    get_breaks_dict(x::Vector{<:Real}, n::Int=7) -> Dict

Calculate breaks using multiple methods and return as a dictionary.
This mimics the format returned by the R classInt package.

# Arguments
- `x`: Vector of numeric values
- `n`: Number of classes

# Returns
- `Dict`: Dictionary with keys for different methods and values as their break points

# Example
```julia
values = [1, 5, 7, 9, 10, 15, 20, 30, 50, 100]
breaks_dict = get_breaks_dict(values, 5)
# Use a specific method's breaks
kmeans_breaks = breaks_dict[:kmeans]
```
"""
function get_breaks_dict(x::Vector{T}, n::Int=7) where T<:Union{Real, Missing}
    # Remove missing values
    x_clean = collect(skipmissing(x))
    
    # Return a dictionary of different break methods, similar to R's classInt
    return Dict(
        :jenks => natural_breaks(x_clean, n),
        :kmeans => kmeans_breaks(x_clean, n),
        :quantile => quantile_breaks(x_clean, n)
    )
end

"""
    fisher_clustering(x, k)

Clusters a sequence of values into subsequences using Fisher's method of exact optimization,
which maximizes the between-cluster sum of squares.

# Arguments
- `x::Vector{<:Real}`: Vector of observations to be clustered.
- `k::Integer`: Number of clusters requested.

# Returns
A tuple containing:
- `cluster_info`: Array of cluster information (min, max, mean, std) with dimensions (k, 4)
- `work`: Matrix of within-cluster sums of squares
- `iwork`: Matrix of optimal splitting points
"""
function fisher_clustering(x::Vector{<:Real}, k::Integer)
    m = length(x)
    
    # Initialize work matrices
    work = fill(floatmax(Float64), m, k)
    iwork = fill(1, m, k)
    
    # Compute work and iwork iteratively
    for i in 1:m
        ss = 0.0
        s = 0.0
        local variance_val = 0.0  # Declare this outside inner loop but within outer loop
        
        for ii in 1:i
            iii = i - ii + 1
            ss += x[iii]^2
            s += x[iii]
            sn = ii
            variance_val = ss - s^2/sn  # Update it here
            
            ik = iii - 1
            if ik != 0
                for j in 2:k
                    if work[i, j] >= variance_val + work[ik, j-1]
                        iwork[i, j] = iii
                        work[i, j] = variance_val + work[ik, j-1]
                    end
                end
            end
        end
        
        # This uses the final value of variance_val from the inner loop
        work[i, 1] = variance_val
        iwork[i, 1] = 1
    end
    
    # Extract results
    cluster_info = zeros(Float64, k, 4)  # Each row: [min, max, mean, std]
    
    j = 1
    jj = k - j + 1
    il = m + 1
    
    for l in 1:jj
        ll = jj - l + 1
        a_min = floatmax(Float64)
        a_max = -floatmax(Float64)
        s = 0.0
        ss = 0.0
        
        iu = il - 1
        il = iwork[iu, ll]
        
        for ii in il:iu
            a_min = min(a_min, x[ii])
            a_max = max(a_max, x[ii])
            s += x[ii]
            ss += x[ii]^2
        end
        
        sn = iu - il + 1
        mean_val = s / sn
        var_val = ss/sn - mean_val^2
        std_val = sqrt(abs(var_val))
        
        cluster_info[l, 1] = a_min
        cluster_info[l, 2] = a_max
        cluster_info[l, 3] = mean_val
        cluster_info[l, 4] = std_val
    end
    
    return cluster_info, work, iwork
end

"""
    get_cluster_assignments(x, k, work, iwork)

Extract cluster assignments from the results of fisher_clustering.

# Arguments
- `x::Vector{<:Real}`: Original data vector.
- `k::Integer`: Number of clusters.
- `work`: Work matrix from fisher_clustering.
- `iwork`: Integer work matrix from fisher_clustering.

# Returns
- Vector of cluster assignments (integers from 1 to k) for each element in x.
"""
function get_cluster_assignments(x::Vector{<:Real}, k::Integer, work, iwork)
    m = length(x)
    assignments = zeros(Int, m)
    
    # Backtrack to find cluster boundaries
    boundaries = zeros(Int, k+1)
    boundaries[k+1] = m + 1
    
    j = k
    idx = m
    
    while j >= 1
        boundaries[j] = iwork[idx, j]
        idx = boundaries[j] - 1
        j -= 1
    end
    
    # Assign clusters based on boundaries
    for i in 1:k
        for j in boundaries[i]:(boundaries[i+1]-1)
            assignments[j] = i
        end
    end
    
    return assignments
end

# Example usage
function example()
    # Generate sample data
    x = sort([10.0, 12.0, 15.0, 18.0, 20.0, 22.0, 25.0, 28.0, 30.0, 35.0, 40.0, 45.0])
    k = 3
    
    # Run Fisher's clustering
    cluster_info, work, iwork = fisher_clustering(x, k)
    
    println("Fisher's clustering with k = $k:")
    for i in 1:k
        println("Cluster $i: min = $(cluster_info[i,1]), max = $(cluster_info[i,2]), " *
                "mean = $(round(cluster_info[i,3], digits=2)), std = $(round(cluster_info[i,4], digits=2))")
    end
    
    # Get cluster assignments
    assignments = get_cluster_assignments(x, k, work, iwork)
    println("\nData points with cluster assignments:")
    for (i, val) in enumerate(x)
        println("x[$i] = $val, cluster = $(assignments[i])")
    end
    
    return cluster_info, work, iwork, assignments
end

# Uncomment to run the example
example()

# Export the dictionary version to match R's format
export get_breaks_dict

end # module ClassInt 