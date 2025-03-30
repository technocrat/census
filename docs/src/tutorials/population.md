# Population Analysis

This tutorial covers how to analyze population characteristics using Census.jl.

## Age Distribution Analysis

Census.jl provides tools for analyzing age distributions across different regions:

```julia
using Census

# Get US age distribution
us_ages = get_us_ages()

# Get childbearing population data
childbearing_pop = get_childbearing_population("CA")

# Create age pyramids for multiple states
states = ["CA", "NY", "TX"]
age_data = collect_state_age_dataframes(states)
create_multiple_age_pyramids(age_data, states)
```

## Population Growth Analysis

Analyze population growth trends:

```julia
using Census

# Create growth tables
growth_table = make_growth_table(data)

# Analyze nation state population
nation_pop = make_nation_state_pop_df("Pacific")
```

## Geographic Population Analysis

Analyze population distribution across geographic regions:

```julia
using Census

# Get population data for specific geographic areas
western_pop = get_geo_pop(get_western_geoids())
eastern_pop = get_geo_pop(get_eastern_geoids())
colorado_basin_pop = get_geo_pop(get_colorado_basin_geoids())
```

## Visualization and Mapping

Create visualizations of population data:

```julia
using Census
using CairoMakie

# Create population maps
map_poly(population_data)

# Add labels and legends
add_labels(map)
make_legend(map)
```

## Advanced Analysis

Perform more complex population analysis:

```julia
using Census

# Query detailed age statistics
state_ages = query_state_ages(state)
nation_ages = query_nation_ages(nation)

# Process and analyze data
processed_data = process(raw_data)
analysis_results = analysis(processed_data)
``` 