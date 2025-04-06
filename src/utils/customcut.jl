# SPDX-License-Identifier: MIT

"""
    customcut(x::AbstractVector{<:Real}, breaks::AbstractVector{<:Real}) -> Vector{Int}

Partition values in `x` into bins defined by `breaks`, returning indices of which bin each value falls into.

Each value is assigned to the first bin where it is less than or equal to the break value.
Values greater than the last break point are assigned to the final bin.

# Arguments
- `x::AbstractVector{<:Real}`: Vector of values to bin
- `breaks::AbstractVector{<:Real}`: Vector of break points defining bin boundaries

# Returns
- `Vector{Int}`: Vector of bin indices for each value in x

# Example
```julia
x = [1.0, 2.0, 3.0, 4.0]
breaks = [1.5, 3.0]
customcut(x, breaks) # Returns [1, 1, 2, 3]
```

# Throws
- `ArgumentError`: If breaks is empty or not sorted in ascending order
"""
function customcut(x::AbstractVector{<:Real}, breaks::AbstractVector{<:Real})
    # Input validation
    if isempty(breaks)
        throw(ArgumentError("breaks vector must not be empty"))
    end
    if !issorted(breaks)
        throw(ArgumentError("breaks must be sorted in ascending order"))
    end
    
    bins = zeros(Int, length(x))
    for i in eachindex(x)
        bin_found = false
        for j in eachindex(breaks)
            if x[i] <= breaks[j]
                bins[i] = j
                bin_found = true
                break
            end
        end
        # If no bin found, assign to last bin
        if !bin_found
            bins[i] = length(breaks) + 1
        end
    end
    return bins
end

export customcut

