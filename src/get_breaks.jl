# SPDX-License-Identifier: MIT

using DataFrames
using RCall
using .RSetup: setup_r_environment, SETUP_COMPLETE

"""
    get_breaks(DF::DataFrame, col_no::Int) -> Dict

Calculate breaks for a given column in a DataFrame using various classification methods from the R `classInt` package.

# Arguments
- `DF::DataFrame`: The input DataFrame containing numeric data to be classified
- `col_no::Int`: The column number (1-based index) for which to calculate breaks

# Returns
- `Dict`: A dictionary containing break points for different classification methods:
  - `fisher`: Fisher's Natural Breaks optimization
  - `jenks`: Jenks Natural Breaks optimization
  - `kmeans`: K-means clustering
  - `maximum`: Maximum breaks
  - `pretty`: Pretty breaks at nice numbers
  - `quantile`: Quantile breaks
  - `sd`: Standard deviation breaks

# Style Options (from R classIntervals documentation)
- `"fixed"`: Uses predefined break points specified in the `fixedBreaks` argument. The length of `fixedBreaks` should be n+1.

- `"sd"`: Creates breaks based on standard deviations from the mean. Uses `pretty` on the centered and scaled variables. May return a different number of classes than requested. Useful for normally distributed data.

- `"equal"`: Divides the range of the variable into n equal-width intervals. Simple but may not represent data structure well.

- `"pretty"`: Chooses breaks that are "pretty" numbers (multiples of 2, 5, 10) that are easy to read. May not give exactly n classes but produces nice round numbers.

- `"quantile"`: Creates breaks at the quantiles of the data distribution, ensuring equal numbers of observations in each class. Good for skewed distributions.

- `"kmeans"`: Uses k-means clustering to find natural groupings in the data. Can be made reproducible with `set.seed()`. Good for finding natural clusters.

- `"hclust"`: Uses hierarchical clustering to generate breaks. Returns the clustering object which can be used to find alternative breaks. Good for finding hierarchical structure.

- `"bclust"`: Uses bagged clustering, a more robust version of clustering that uses bootstrap resampling. Good for noisy data.

- `"fisher"`: Implements Fisher's Natural Breaks optimization algorithm. Minimizes within-class variance while maximizing between-class variance. This is the preferred method over "jenks" as it uses the original Fortran code and is faster.

- `"jenks"`: Implements Jenks' Natural Breaks classification (similar to Fisher). Note that this method uses right-closed intervals unlike other methods. Good for choropleth maps but slower than Fisher's method.

- `"dpih"`: Uses direct plug-in methodology to select histogram bin width. Automatically determines the number of classes based on data distribution.

- `"headtails"`: Designed for heavy-tailed distributions. Iteratively partitions data around the mean until the head part is no longer heavy-tailed. The number of classes is determined automatically.

- `"maximum"`: Finds the k-1 largest differences in the data and uses these as break points. Good for finding major discontinuities in the data.

- `"box"`: Creates 6 classes based on box-and-whisker plot principles. Uses quartiles and outlier thresholds. Good for showing outliers and data spread.

# Special Considerations
- For large datasets (>3000 observations), "fisher" and "jenks" methods automatically use sampling to improve performance
- Some methods ("kmeans", "bclust") may need multiple tries with jittered data if there are many duplicate values
- The "headtails" method has a threshold parameter (`thr`) that can be adjusted for different levels of heavy-tailedness

# Examples
```julia
df = DataFrame(values = [1, 2, 3, 5, 8, 13, 21, 34, 55])
breaks = get_breaks(df, 1)
# Access breaks for a specific method:
fisher_breaks = breaks["fisher"][:brks]
```

# Notes
- Requires the R package `classInt` to be installed
- Each method produces 6 classes by default (except 'maximum')
- The function uses RCall to interface with R

Source: R `classIntervals` help documentation
"""
function get_breaks(DF::DataFrame, col_no::Int)
    if !SETUP_COMPLETE[]
        setup_r_environment()
    end
    
    @rput DF
    @rput col_no
    
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

export get_breaks

"""
    initialize() -> Bool

Initialize the R environment for the Census package.

# Returns
- `Bool`: `true` if the R environment is successfully initialized, `false` otherwise

# Notes
- Loads R setup from `r_setup.jl`
- Sets up required R packages if not already installed
- Uses a global `SETUP_COMPLETE` flag to track initialization status
- Should be called before using any R-dependent functions
"""
function initialize()
    include(joinpath(@__DIR__, "r_setup.jl"))
    if !SETUP_COMPLETE[]
        setup_r_environment()
    end
    return SETUP_COMPLETE[]
end
