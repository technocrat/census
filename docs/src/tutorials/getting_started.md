# Getting Started with Census.jl

This guide will help you get started with Census.jl for analyzing potential nation states.

## Installation

First, make sure you have Julia installed on your system. Then, you can install Census.jl using Julia's package manager:

```julia
using Pkg
Pkg.add("Census")
```

## Basic Usage

Here's a simple example of how to use Census.jl:

```julia
using Census

# Get state information
state_codes = valid_codes()
state_name = get_state_name("CA")

# Check if a code is valid
is_valid = is_valid_postal_code("CA")
```

## Data Processing

Census.jl provides tools for data manipulation:

```julia
using Census

# Add margins to your data
df_with_margins = add_margins(your_data)
df_with_row_margins = add_row_margins(your_data)
df_with_col_margins = add_col_margins(your_data)
```

## Working with Geographic Data

Census.jl provides powerful tools for geographic analysis:

```julia
using Census

# Get geographic population data
geo_pop = get_geo_pop("CA")

# Work with specific regions
western_geoids = get_western_geoids()
eastern_geoids = get_eastern_geoids()
```

## Visualization

Create visualizations of your data:

```julia
using Census
using CairoMakie

# Create age pyramids
create_multiple_age_pyramids(data, states)

# Create maps
map_poly(your_data)
```

## Next Steps

- Check out the Core Functions documentation for more details
- Learn about data processing capabilities
- Explore the visualization tools 