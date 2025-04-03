# SPDX-License-Identifier: MIT

"""
    ga(dest::String, row::Int, col::Int, title::String, fig::Figure, df::DataFrame) -> GeoAxis

Create a GeoAxis for geographic visualization with automatic bounding box calculation.

# Arguments
- `dest::String`: Destination CRS (Coordinate Reference System) string (e.g., "EPSG:4326")
- `row::Int`: Row position in the figure grid
- `col::Int`: Column position in the figure grid
- `title::String`: Title for the axis
- `fig::Figure`: Parent Makie figure
- `df::DataFrame`: DataFrame containing a 'geom' column with MULTIPOLYGON WKT strings

# Returns
- `GeoAxis`: A configured GeoAxis object with:
  - Specified CRS projection
  - Data aspect ratio preserved
  - Automatic bounding box from geometries
  - Rounded limits to nearest 5 degrees

# Coordinate Processing
1. Extracts first coordinate pair from each MULTIPOLYGON
2. Finds min/max coordinates across all geometries
3. Rounds limits to nearest 5 degrees for clean boundaries
4. Sets axis limits to encompass all geometries

# Example
```julia
using CairoMakie, GeoMakie
fig = Figure()
df = DataFrame(geom = ["MULTIPOLYGON(((-120 45,...)))", ...])
axis = ga("EPSG:4326", 1, 1, "My Map", fig, df)
```

# Notes
- Uses regex to extract coordinates from WKT strings
- Assumes MULTIPOLYGON geometry type in WKT format
- Sets DataAspect() to preserve geographic proportions
- Useful for creating base maps in map_poly() and similar functions
"""
function ga(dest::String, row::Int, col::Int, title::String, fig::Figure, df::DataFrame)
    # Create the GeoAxis
    ga1 = GeoAxis(fig[row, col],
        dest=dest,
        title=title,
        aspect=DataAspect()
    )
    
    # Get all coordinates from all geometries using regex
    coords = map(x -> match(r"MULTIPOLYGON\(\(\(([-\d.]+)\s+([-\d.]+)", x).captures, df.geom)
    
    # Find min/max coordinates
    x_coords = map(x -> parse(Float64, x[1]), coords)
    y_coords = map(x -> parse(Float64, x[2]), coords)
    
    xmin, xmax = extrema(x_coords)
    ymin, ymax = extrema(y_coords)
    
    # Round to nearest 5 degrees
    xmin = floor(xmin / 5) * 5
    ymin = floor(ymin / 5) * 5
    xmax = ceil(xmax / 5) * 5
    ymax = ceil(ymax / 5) * 5
    
    # Set the limits
    GeoMakie.xlims!(ga1, xmin, xmax)
    GeoMakie.ylims!(ga1, ymin, ymax)
    
    return ga1
end
