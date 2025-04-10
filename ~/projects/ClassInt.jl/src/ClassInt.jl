# SPDX-License-Identifier: MIT

"""
ClassInt.jl

A pure Julia implementation of the R classInt package functionality for creating class intervals 
for mapping or other graphical purposes. This package provides various classification methods 
including Fisher-Jenks natural breaks, K-means clustering, quantile breaks, and equal interval breaks.

## Features

- Pure Julia implementation with no external R dependencies
- Multiple classification methods:
  - Fisher-Jenks natural breaks optimization (jenks)
  - K-means clustering (kmeans)
  - Quantile breaks (quantile)
  - Equal interval breaks (equal)
- Comprehensive API with detailed documentation
- Handles missing values automatically
- Provides both individual method functions and a combined dictionary format
"""
module ClassInt

using Clustering
using StatsBase
using Statistics

export get_breaks, natural_breaks, kmeans_breaks, quantile_breaks, equal_interval_breaks, get_breaks_dict

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
        :quantile => quantile_breaks(x_clean, n),
        :equal => equal_interval_breaks(x_clean, n)
    )
end

end # module ClassInt 