# SPDX-License-Identifier: MIT

using DataFrames
using RCall
using .RSetup: setup_r_environment, SETUP_COMPLETE

"""
    get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7) -> RObject

Get breaks for population bins using R's classInt package.

# Arguments
- `x`: Vector of values (can contain missing values)
- `n`: Number of breaks to calculate (default: 7)

# Returns
- RObject containing breaks calculated using various methods (kmeans, quantile, jenks)

# Example
```julia
breaks = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
```
"""
function get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7)
    if !SETUP_COMPLETE[]
        setup_r_environment()
    end
    
    # Convert to R, handling missing values
    @rput x
    @rput n
    
    R"""
    library(classInt)
    x <- x[!is.na(x)]
    
    # Calculate breaks using different methods
    breaks <- list(
        kmeans = classIntervals(x, n = n, style = "kmeans"),
        quantile = classIntervals(x, n = n, style = "quantile"),
        jenks = classIntervals(x, n = n, style = "jenks")
    )
    breaks
    """
end

export get_breaks
