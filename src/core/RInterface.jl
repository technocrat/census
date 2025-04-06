# SPDX-License-Identifier: MIT

"""
RInterface module - Handles R interactions without REPL integration
"""
module RInterface

using RCall: reval, rcopy, rparse, RObject

"""
    get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7) -> Dict

Get breaks for population bins using R's classInt package.
"""
function get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7)
    # Remove missing values
    x = collect(skipmissing(x))
    
    # Use reval and rcopy directly instead of R"..." macro
    reval(rparse("""
        if (!require("classInt")) {
            install.packages("classInt", repos="https://cloud.r-project.org")
        }
        library(classInt)
        x <- $(x)
        breaks <- list(
            kmeans = classIntervals(x, n = $(n), style = "kmeans"),
            quantile = classIntervals(x, n = $(n), style = "quantile"),
            jenks = classIntervals(x, n = $(n), style = "jenks")
        )
        breaks
    """))
end

export get_breaks

end # module RInterface 