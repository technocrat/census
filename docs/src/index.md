# Census.jl Documentation

Welcome to the documentation for Census.jl, a Julia package for working with the U.S. Census Bureau's APIs.

## Overview

Census.jl provides a simple and efficient interface to access American Community Survey (ACS) data through the Census Bureau's API. The package is designed to be user-friendly while offering powerful features for data analysis and visualization.

## Features

- Easy access to ACS data through a simple interface
- Support for multiple geography levels:
  - State
  - County
  - Census Tract
  - Block Group
  - ZIP Code Tabulation Area (ZCTA)
- Built-in geometry support using Census TIGER/Line shapefiles
- Variable table caching for improved performance
- Margin of error calculations at different confidence levels (90%, 95%, 99%)
- Support for data transformation (wide/tidy formats)
- Thematic mapping capabilities with Alaska and Hawaii shifting

## Installation

To install Census.jl, use Julia's package manager:

```julia
using Pkg
Pkg.add("Census")
```

## Getting Started

First, you'll need a Census API key. You can get one for free at [https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html).

Once you have your API key, you can set it as an environment variable:

```julia
ENV["CENSUS_API_KEY"] = "your-api-key-here"
```

Here's a simple example to get started:

```julia
using Census

# Get median household income for all counties in California
df = get_acs(
    geography = "county",
    variables = ["B19013_001"],
    state = "CA",
    year = 2022,
    survey = "acs5"
)
```

## Basic Usage

### Fetching ACS Data

The main function for accessing ACS data is `get_acs`:

```julia
get_acs(;
    geography::String,           # Geographic level
    variables::Vector{String},   # Census variable codes
    table::String,              # ACS table (alternative to variables)
    year::Int,                  # Survey year (2005-2023)
    state::String,              # State postal code or FIPS code
    county::String,             # County name or FIPS code
    zcta::String,              # ZIP Code Tabulation Area
    geometry::Bool,             # Whether to return geometry data
    shift_geo::Bool,           # Shift AK/HI for thematic mapping
    keep_geo_vars::Bool,       # Keep geographic identifier variables
    summary_var::String,       # Additional summary variable
    output::String,            # Output format ("tidy" or "wide")
    survey::String,            # Survey type ("acs1", "acs3", "acs5")
    moe_level::Int,           # Confidence level for margin of error
    api_key::String           # Census API key
)
```

### Working with Variables

To explore available variables:

```julia
# Load and cache variables for 2022 ACS 5-year
vars_df = load_variables(2022, "acs5", cache=true)

# Search for income-related variables
income_vars = filter(row -> occursin("income", lowercase(row.label)), vars_df)
```

### Geographic Levels

The package supports various geographic levels:

```julia
# State level data
states_df = get_acs(
    geography = "state",
    variables = ["B01003_001"],
    year = 2022,
    survey = "acs5"
)

# County level data
counties_df = get_acs(
    geography = "county",
    variables = ["B01003_001"],
    state = "CA",
    year = 2022,
    survey = "acs5"
)

# Tract level data
tracts_df = get_acs(
    geography = "tract",
    variables = ["B01003_001"],
    state = "NY",
    county = "061",
    year = 2022,
    survey = "acs5"
)
```

### Working with Tables

Instead of specifying individual variables, you can request all variables from a table:

```julia
# Get all variables from the median household income table
income_df = get_acs(
    geography = "state",
    table = "B19013",
    year = 2022,
    survey = "acs5"
)
```

### Geometry and Mapping

The package supports fetching geometry data for mapping:

```julia
using Census
using GeoMakie

# Get median household income with geometry
df = get_acs(
    geography = "county",
    variables = ["B19013_001"],
    year = 2022,
    geometry = true,
    shift_geo = true,  # Shift AK/HI for thematic mapping
    survey = "acs5"
)

# Create a choropleth map
fig = Figure()
ax = GeoAxis(fig[1, 1])
poly!(ax, df.geometry, color = df.estimate)
```

## Advanced Features

### Margin of Error Calculations

The package supports different confidence levels for margin of error calculations:

```julia
# Get data with 95% confidence level
df = get_acs(
    geography = "county",
    variables = ["B19013_001"],
    state = "CA",
    year = 2022,
    survey = "acs5",
    moe_level = 95
)
```

### Data Formats

Data can be returned in either "tidy" (long) or "wide" format:

```julia
# Get data in wide format
df_wide = get_acs(
    geography = "state",
    variables = ["B01003_001", "B19013_001"],
    year = 2022,
    survey = "acs5",
    output = "wide"
)
```

### Summary Variables

You can include a summary variable to calculate proportions:

```julia
df = get_acs(
    geography = "county",
    variables = ["B01003_001"],
    summary_var = "B01003_001",  # Total population as denominator
    state = "CA",
    year = 2022,
    survey = "acs5"
)
```

## API Reference

### Main Functions

```@docs
get_acs
load_variables
```

### Types

```@docs
CensusQuery
```

### Helper Functions

```@docs
build_census_query
fetch_census_data
get_moe_factor
fetch_tiger_geometry
shift_geometry
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This package is inspired by the R package [tidycensus](https://walker-data.com/tidycensus/) and builds upon the work of many other open-source projects in the Julia ecosystem. 