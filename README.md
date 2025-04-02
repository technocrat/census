# Census.jl

A Julia package for working with the U.S. Census Bureau's APIs, with a focus on the American Community Survey (ACS) data.

## Features

- Easy access to ACS data through a simple interface
- Support for multiple geography levels (state, county, tract, block group, ZCTA)
- Built-in geometry support using Census TIGER/Line shapefiles
- Variable table caching for improved performance
- Margin of error calculations at different confidence levels
- Support for data transformation (wide/tidy formats)
- Thematic mapping capabilities with Alaska and Hawaii shifting

## Installation

```julia
using Pkg
Pkg.add("Census")
```

## Quick Start

First, you'll need a Census API key. You can get one for free at [https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html).

```julia
using Census

# Set your API key
ENV["CENSUS_API_KEY"] = "your-api-key-here"

# Get median household income for all counties in California
df = get_acs(
    geography = "county",
    variables = ["B19013_001"],
    state = "CA",
    year = 2022,
    survey = "acs5"
)

# Get all variables from a specific table with geometry
df = get_acs(
    geography = "tract",
    table = "B19013",
    state = "NY",
    year = 2022,
    geometry = true,
    survey = "acs5"
)
```

## Main Functions

### `get_acs`

The primary function for fetching ACS data:

```julia
get_acs(;
    geography::String,           # Geographic level ("state", "county", "tract", "block group", "zcta")
    variables::Vector{String},   # Census variable codes
    table::String,              # ACS table (alternative to variables)
    year::Int,                  # Survey year (2005-2023)
    state::String,              # State postal code or FIPS code
    county::String,             # County name or FIPS code (requires state)
    zcta::String,              # ZIP Code Tabulation Area
    geometry::Bool,             # Whether to return geometry data
    shift_geo::Bool,           # Shift AK/HI for thematic mapping
    keep_geo_vars::Bool,       # Keep geographic identifier variables
    summary_var::String,       # Additional summary variable
    output::String,            # Output format ("tidy" or "wide")
    survey::String,            # Survey type ("acs1", "acs3", "acs5")
    moe_level::Int,           # Confidence level for margin of error (90, 95, 99)
    api_key::String           # Census API key (defaults to ENV["CENSUS_API_KEY"])
) -> DataFrame
```

### `load_variables`

Load Census variable metadata:

```julia
# Load and cache variables for 2022 ACS 5-year
vars_df = load_variables(2022, "acs5", cache=true)
```

## Examples

### Basic Usage

```julia
# Get population estimates for all states
df = get_acs(
    geography = "state",
    variables = ["B01003_001"],
    year = 2022,
    survey = "acs5"
)

# Get multiple variables for a specific county
df = get_acs(
    geography = "tract",
    variables = ["B01003_001", "B19013_001", "B25077_001"],
    state = "NY",
    county = "061",  # New York County (Manhattan)
    year = 2022,
    survey = "acs5"
)
```

### Working with Geometry

```julia
# Get median household income with geometry for mapping
df = get_acs(
    geography = "county",
    variables = ["B19013_001"],
    year = 2022,
    geometry = true,
    shift_geo = true,  # Shift AK/HI for thematic mapping
    survey = "acs5"
)

# Plot using GeoMakie
using GeoMakie
fig = Figure()
ax = GeoAxis(fig[1, 1])
poly!(ax, df.geometry, color = df.estimate)
```

### Variable Tables

```julia
# Get all variables from the median household income table
df = get_acs(
    geography = "state",
    table = "B19013",
    year = 2022,
    survey = "acs5"
)

# Search for variables
vars_df = load_variables(2022, "acs5", cache=true)
filter(row -> occursin("income", lowercase(row.label)), vars_df)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This package is inspired by the R package [tidycensus](https://walker-data.com/tidycensus/) and builds upon the work of many other open-source projects in the Julia ecosystem.
