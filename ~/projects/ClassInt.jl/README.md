# ClassInt.jl

[![Build Status](https://github.com/yourusername/ClassInt.jl/workflows/CI/badge.svg)](https://github.com/yourusername/ClassInt.jl/actions)
[![Coverage](https://codecov.io/gh/yourusername/ClassInt.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/ClassInt.jl)

A pure Julia implementation of the R [classInt](https://cran.r-project.org/web/packages/classInt/index.html) package functionality for creating class intervals for mapping or other graphical purposes.

## Features

- Pure Julia implementation with no external R dependencies
- Multiple classification methods:
  - Fisher-Jenks natural breaks optimization (jenks)
  - K-means clustering (kmeans)
  - Quantile breaks (quantile)
  - Equal interval breaks (equal)
- Comprehensive API with detailed documentation
- Handles missing values automatically

## Installation

```julia
using Pkg
Pkg.add("ClassInt")
```

Or, for the development version:

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/ClassInt.jl")
```

## Basic Usage

```julia
using ClassInt

# Create some sample data
values = [1, 5, 7, 9, 10, 15, 20, 30, 50, 100]

# Calculate breaks using different methods
jenks_breaks = get_breaks(values, 5, style=:jenks)
kmeans_breaks = get_breaks(values, 5, style=:kmeans)
quantile_breaks = get_breaks(values, 5, style=:quantile)
equal_breaks = get_breaks(values, 5, style=:equal)

# Get all methods at once (similar to R's classInt format)
all_breaks = get_breaks_dict(values, 5)
```

## Use with Mapping and Visualization

ClassInt.jl is particularly useful for creating classes for choropleth maps and other visualizations:

```julia
using ClassInt
using CairoMakie
using DataFrames

# Assuming 'df' is a DataFrame with a 'value' column
breaks = get_breaks(df.value, 5, style=:jenks)

# Create a figure
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1])

# Plot data with breaks
# (Implementation depends on your specific visualization needs)

fig
```

## Direct Functions

You can also use the individual classification functions directly:

```julia
jenks_breaks = natural_breaks(values, 5)
kmeans_breaks = kmeans_breaks(values, 5)
quantile_breaks = quantile_breaks(values, 5)
equal_breaks = equal_interval_breaks(values, 5)
```

## Comparison with R's classInt

This package aims to provide equivalent functionality to R's classInt package. The main functions are:

| R Function | ClassInt.jl Function |
|------------|----------------------|
| `classIntervals(x, n, style = "jenks")` | `get_breaks(x, n, style = :jenks)` |
| `classIntervals(x, n, style = "kmeans")` | `get_breaks(x, n, style = :kmeans)` |
| `classIntervals(x, n, style = "quantile")` | `get_breaks(x, n, style = :quantile)` |
| `classIntervals(x, n, style = "equal")` | `get_breaks(x, n, style = :equal)` |

## License

This package is licensed under the MIT License - see the LICENSE file for details. 