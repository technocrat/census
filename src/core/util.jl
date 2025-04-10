# SPDX-License-Identifier: MIT

"""
Utility functions for working with census data
"""

"""
    customcut(x::Vector, breaks::Vector) -> Vector{String}

Create custom bin labels for a vector of values using specified breaks.

# Arguments
- `x`: Vector of values to bin
- `breaks`: Vector of break points to use for binning

# Returns
- Vector of formatted strings representing bins (e.g., "0 - 100", "> 500")

# Example
```julia
values = [10, 150, 300, 700]
breaks = [0, 100, 500, 1000]
bins = customcut(values, breaks) # ["0 - 100", "100 - 500", "500 - 1000", "> 1000"]
```
"""
function customcut(x::Vector, breaks::Vector)
    n = length(breaks)
    result = similar(x, String)
    
    for i in eachindex(x)
        value = x[i]
        if ismissing(value)
            result[i] = "Missing"
            continue
        end
        
        for j in 1:(n-1)
            if j == 1 && value <= breaks[j]
                result[i] = "≤ $(breaks[j])"
                break
            elseif j == n-1 && value > breaks[j]
                result[i] = "> $(breaks[j])"
                break
            elseif value > breaks[j] && value <= breaks[j+1]
                result[i] = "$(breaks[j]) - $(breaks[j+1])"
                break
            end
        end
    end
    
    return result
end

"""
    list_geoid_sets() -> Vector{String}

List all available geoid set constants defined in the Census module.

# Returns
- `Vector{String}`: Names of all geoid set constants 

# Example
```julia
sets = list_geoid_sets()
# Use a specific set
geoids = Census.FLORIDA_GEOIDS
```
"""
function list_geoid_sets()
    # Get all module variables
    all_names = names(Census, all=true)
    
    # Filter for variables ending with _GEOIDS and that are exported
    geoid_sets = String[]
    for name in all_names
        name_str = String(name)
        if endswith(name_str, "_GEOIDS")
            push!(geoid_sets, name_str)
        end
    end
    
    return sort(geoid_sets)
end 