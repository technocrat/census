# SPDX-License-Identifier: MIT

"""
    get_breaks(DF::DataFrame, col_no::Int)

Calculate breaks for a given column in a DataFrame using various methods from the R `classInt` package.

# Arguments
- `DF::DataFrame`: The input DataFrame.
- `col_no::Int`: The column number for which to calculate breaks.

# Returns
- `Dict`: A dictionary with method names as keys and break values as values.

# Example
breaks =  [(k, v[:brks]) for (k, v) in pairs(@rget breaks)]

"""
function get_breaks(DF::DataFrame, col_no::Int)
    @rput DF
    @rput col_no
    #initialize()
    R"""
    library(classInt)
    x   = DF[,col_no]
    breaks  <- list(
        fisher      = classIntervals(x, n=6, style="fisher"),
        jenks       = classIntervals(x, n=6, style="jenks"),
        kmeans      = classIntervals(x, n=6, style="kmeans"),
        maximum     = classIntervals(x, style="maximum"),
        pretty      = classIntervals(x, n=6, style="pretty"),
        quantile    = classIntervals(x, n=6, style="quantile"),
        sd          = classIntervals(x, n=6, style="sd")
    )
    """
end


function initialize()
    include(joinpath(@__DIR__, "r_setup.jl"))
    if !SETUP_COMPLETE[]
        setup_r_environment()
    end
    return SETUP_COMPLETE[]
end
