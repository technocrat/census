# SPDX-License-Identifier: MIT

"""
   customcut(x::Vector{Float64}, breaks::Vector{Float64}) -> Vector{Int}

Partition values in `x` into bins defined by `breaks`, returning indices of which bin each value falls into.

Each value is assigned to the first bin where it is less than or equal to the break value.
Values greater than the last break point are assigned to the final bin.

Example:
```julia
x = [1.0, 2.0, 3.0, 4.0]
breaks = [1.5, 3.0]
customcut(x, breaks) # Returns [1, 1, 2, 3]
"""
function my_cut(x, breaks)
    n = length(breaks)
    bins = zeros(Int, length(x))
    for i in 1:length(x)
        for j in 1:n
            if x[i] <= breaks[j]
                bins[i] = j
                break
            end
        end
    end
    bins
end

