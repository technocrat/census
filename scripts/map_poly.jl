# SPDX-License-Identifier: MIT
# Standalone map_poly function for when Census.jl isn't properly loaded

using CairoMakie
using GeoMakie
using DataFrames
using WellKnownGeometry  # Add explicit import for WellKnownGeometry

"""
    map_poly(df::DataFrame, title::String, crs::String, fig::Figure=Figure(size=(3200, 2400), fontsize=24))

Create a map visualization of polygon geometries in the dataframe.

# Arguments
- `df::DataFrame`: DataFrame with geometries in the 'geom' column and values in the 'pop' column
- `title::String`: Title for the map
- `crs::String`: Coordinate Reference System string for projection
- `fig::Figure`: Optional Makie figure to draw on (creates one if not provided)

# Returns
- `Figure`: The Makie figure with the map

# Example
```julia
df = get_state_counties(counties, "CA")  # Get California counties
fig = map_poly(df, "California Counties", "+proj=aea +lat_1=24 +lat_2=31.5 +lat_0=24 +lon_0=-83 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
```
"""
function map_poly(df::DataFrame, title::String, crs::String, fig::Figure=Figure(size=(3200, 2400), fontsize=24))
    @info "Creating map for '$title' with $(nrow(df)) geometries"
    
    # Create axis with projection
    ax = GeoAxis(
        fig[1, 1]; 
        title=title,
        dest=crs,
        source="+proj=longlat +datum=WGS84",
    )
    
    # Process geometries
    geometries = []
    valid_rows = []
    
    for (i, row) in enumerate(eachrow(df))
        # Skip rows with missing geometries
        if ismissing(row.geom)
            continue
        end
        
        # Convert WKT to GeoJSON-like structure
        try
            # Parse the WKT geometry
            geom = GeoMakie.geo2basic(WellKnownGeometry.convert_wkt(String(row.geom)))
            push!(geometries, geom)
            push!(valid_rows, i)
        catch e
            @warn "Failed to parse geometry at row $i" exception=e
        end
    end
    
    if isempty(geometries)
        @error "No valid geometries found in the dataframe"
        text!(ax, "No valid geometries", position=(0.5, 0.5), align=(:center, :center), fontsize=30)
        return fig
    end
    
    # Extract population values for valid rows
    values = df.pop[valid_rows]
    
    # Handle missing values
    values = coalesce.(values, 0)
    
    # Create color map
    colormap = :viridis
    
    # Plot polygons
    polys = poly!(ax, geometries; color=values, colormap=colormap)
    
    # Add colorbar
    Colorbar(fig[1, 2], polys, label="Population")
    
    # Add data source attribution
    text!(ax, "Data: US Census Bureau", position=(0.01, 0.01), align=(:left, :bottom), fontsize=12)
    
    return fig
end 