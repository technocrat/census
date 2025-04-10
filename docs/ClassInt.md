# ClassInt Module

## Overview

The `ClassInt` module is a pure Julia implementation of the R `classInt` package functionality. It provides methods for computing class intervals for thematic maps or other graphics purposes. The implementation completely eliminates the need for R dependencies for classification operations.

## Features

- Pure Julia implementation with no external R dependencies
- Multiple classification methods:
  - Fisher-Jenks natural breaks optimization
  - K-means clustering
  - Quantile breaks
  - Equal interval breaks
- Comprehensive API with detailed documentation
- Handles missing values automatically
- Provides both individual method functions and a combined dictionary format

## Installation

The ClassInt module is included in the Census.jl package. No additional installation is required.

## Usage

### Basic Usage

```julia
using Census  # ClassInt is re-exported from Census

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

### With Census Data

```julia
using Census
using DataFrames
using DataFramesMeta

# Load census data
us = init_census_data()

# Calculate breaks for population data
pop_breaks = get_breaks(us.pop, 7, style=:jenks)

# Use the breaks for a custom cut
# (Note: customcut needs to be implemented or can use cut from CategoricalArrays)
# population_bins = customcut(us.pop, pop_breaks)
```

## API Reference

### Functions

#### `get_breaks`

```julia
get_breaks(x::Vector{T}, n::Int=7; style::Symbol=:jenks) where T<:Union{Real, Missing}
```

Calculate breaks for binning data using the specified classification method.

**Arguments:**
- `x`: Vector of numeric values (will skip missing values)
- `n`: Number of classes (resulting in n+1 break points)
- `style`: Classification method (:jenks, :kmeans, :quantile, or :equal)

**Returns:**
- Vector of break points (including min and max values)

#### `get_breaks_dict`

```julia
get_breaks_dict(x::Vector{T}, n::Int=7) where T<:Union{Real, Missing}
```

Calculate breaks using multiple methods and return as a dictionary.
This mimics the format returned by the R classInt package.

**Arguments:**
- `x`: Vector of numeric values
- `n`: Number of classes

**Returns:**
- Dictionary with keys for different methods and values as their break points

#### Individual Method Functions

```julia
natural_breaks(x::Vector{<:Real}, k::Int)
kmeans_breaks(x::Vector{<:Real}, k::Int)
quantile_breaks(x::Vector{<:Real}, k::Int)
equal_interval_breaks(x::Vector{<:Real}, k::Int)
```

Each function implements a specific classification method.

## Implementation Details

### Fisher-Jenks Natural Breaks

The Fisher-Jenks natural breaks optimization algorithm (often called Jenks natural breaks) is implemented using a dynamic programming approach. The algorithm seeks to minimize within-class variance and maximize between-class variance.

### K-means Clustering

The k-means classification leverages the Clustering.jl package, applying k-means clustering to the data values and using the cluster centers as break points.

### Quantile Breaks

Quantile breaks divide the data into equal-sized groups. This uses the `quantile` function from StatsBase.

### Equal Interval Breaks

Equal interval breaks divide the data range into equal intervals, resulting in consistent step sizes between breaks. 