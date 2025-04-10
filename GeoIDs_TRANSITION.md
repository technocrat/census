# Transitioning to Centralized GeoIDs in the GeoIDs Module

This document outlines the process for transitioning from using geoid constants in the Census module to the centralized GeoIDs module.

## Why Centralize?

1. **Single Source of Truth**: All geoid sets now have one definitive source in the GeoIDs module
2. **Better Organization**: GeoIDs module is specifically designed for managing geographical identifiers
3. **Improved Maintainability**: Easier to update and maintain geoid sets in one location
4. **Versioning**: The GeoIDs module supports versioning of geoid sets through its database
5. **Consistent Naming**: All geoid constants follow the same naming convention

## Transition Guide

### Step 1: Update Your Scripts

Replace all references to `Census.GEOID_NAME` with `GeoIDs.GEOID_NAME`. For example:

```julia
# Old code
colorado_basin_geoids = Census.COLORADO_BASIN_GEOIDS

# New code
colorado_basin_geoids = GeoIDs.COLORADO_BASIN_GEOIDS
```

### Step 2: Run the Migration Script

The `migrate_geoids_to_module.jl` script has been created to transfer all existing geoid data from Census constants to GeoIDs constants. This ensures that all your current data is preserved during the transition.

```bash
julia --project=. scripts/migrate_geoids_to_module.jl
```

### Step 3: Test Your Scripts

After updating your script and running the migration, test your scripts to ensure they continue to work correctly.

## Available Geoid Sets

The following geoid sets are available in the GeoIDs module:

- `WESTERN_GEOIDS`
- `EASTERN_GEOIDS`
- `EAST_OF_UTAH_GEOIDS`
- `WEST_OF_CASCADES_GEOIDS`
- `EAST_OF_CASCADES_GEOIDS`
- `SOUTHERN_KANSAS_GEOIDS`
- `NORTHERN_KANSAS_GEOIDS`
- `COLORADO_BASIN_GEOIDS`
- `NE_MISSOURI_GEOIDS`
- `SOUTHERN_MISSOURI_GEOIDS`
- `NORTHERN_MISSOURI_GEOIDS`
- `MISSOURI_RIVER_BASIN_GEOIDS`
- `SLOPE_GEOIDS`
- `SOCAL_GEOIDS`
- `OHIO_BASIN_KY_GEOIDS`
- `OHIO_BASIN_TN_GEOIDS`
- `OHIO_BASIN_IL_GEOIDS`
- `OHIO_BASIN_VA_GEOIDS`
- `OHIO_BASIN_GA_GEOIDS`
- `OHIO_BASIN_AL_GEOIDS`
- `OHIO_BASIN_MS_GEOIDS`
- `OHIO_BASIN_NC_GEOIDS`
- `OHIO_BASIN_PA_GEOIDS`
- `OHIO_BASIN_NY_GEOIDS`
- `OHIO_BASIN_MD_GEOIDS`
- `HUDSON_BAY_DRAINAGE_GEOIDS`
- `MISS_RIVER_BASIN_SD`
- `MISS_BASIN_KY_GEOIDS`
- `MISS_BASIN_TN_GEOIDS`
- `MICHIGAN_PENINSULA_GEOIDS`
- `METRO_TO_GREAT_LAKES_GEOIDS`
- `GREAT_LAKES_PA_GEOIDS`
- `GREAT_LAKES_IN_GEOIDS`
- `GREAT_LAKES_OH_GEOIDS`

You can also use `GeoIDs.list_geoid_sets()` to get a list of all geoid sets available in the database.

## Utility Functions

The GeoIDs module provides several utility functions for working with geoid sets:

- `GeoIDs.create_geoid_set(name, geoids)`: Create a new geoid set
- `GeoIDs.has_geoid_set(name)`: Check if a geoid set exists
- `GeoIDs.get_geoid_set(name)`: Get all geoids in a set
- `GeoIDs.list_geoid_sets()`: List all available geoid sets
- `GeoIDs.set_nation_state_geoids(name, geoids)`: Store nation state geoids

## Dealing with Empty Sets

Some geoid sets may be empty after migration. This can happen if the set was defined but never populated in the Census module. In these cases, you have several options:

1. Initialize the set from your script
2. Use the database to populate the set
3. Create a new geoid set with the GeoIDs module functions

Example of initializing a set:

```julia
# If east_of_utah_geoids is empty
if isempty(GeoIDs.EAST_OF_UTAH_GEOIDS)
    # Initialize with your own data
    append!(GeoIDs.EAST_OF_UTAH_GEOIDS, ["49001", "49003", ...])
    
    # Or save to database for future use
    GeoIDs.create_geoid_set("east_of_utah", GeoIDs.EAST_OF_UTAH_GEOIDS)
end
```

## Reporting Issues

If you encounter any issues during the transition, please report them through the issue tracker on GitHub. 