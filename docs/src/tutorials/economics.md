# Economic Analysis

This tutorial covers how to analyze economic characteristics of potential nation states using Census.jl.

## GDP Analysis

Analyze GDP data for potential nation states:

```julia
using Census

# Get GDP data for a nation state
nation_gdp = make_nation_state_gdp_df("Pacific")

# Process and analyze economic data
processed_data = process(gdp_data)
analysis_results = analysis(processed_data)
```

## Regional Economic Analysis

Analyze economic patterns across different regions:

```julia
using Census

# Get economic data for specific regions
western_econ = get_geo_pop(get_western_geoids())
eastern_econ = get_geo_pop(get_eastern_geoids())
colorado_basin_econ = get_geo_pop(get_colorado_basin_geoids())
```

## Economic Visualization

Create visualizations of economic data:

```julia
using Census
using CairoMakie

# Create economic maps
map_poly(economic_data)

# Add labels and create legends
add_labels(map)
make_legend(map)
```

## Advanced Economic Analysis

Perform more complex economic analysis:

```julia
using Census

# Process economic indicators
indicators = process(economic_data)

# Create economic growth tables
growth_table = make_growth_table(indicators)

# Add row totals for economic summaries
totals = add_row_totals(economic_data)
```

## Integration with Geographic Data

Combine economic and geographic analysis:

```julia
using Census

# Get economic data for specific geographic areas
slope_econ = get_geo_pop(get_slope_geoids())
southern_kansas_econ = get_geo_pop(get_southern_kansas_geoids())

# Create visualizations of regional economic patterns
map_poly(regional_economic_data)
``` 