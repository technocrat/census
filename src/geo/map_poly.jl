# SPDX-License-Identifier: MIT
using CairoMakie
using GeoMakie
using ArchGDAL
using GeometryBasics: Point2f, Polygon
using DataFrames: DataFrame, nrow
using Proj

"""
    parse_geoms(df::DataFrame) -> Vector{ArchGDAL.IGeometry}

Parse WKT geometry strings from DataFrame into ArchGDAL geometry objects.
"""
function parse_geoms(df::DataFrame)
    return [ArchGDAL.fromWKT(geom) for geom in df.geom if !ismissing(geom)]
end

"""
    map_poly(df::DataFrame, title::String, dest::String, fig::Figure)

Create a choropleth map of polygons from a DataFrame with customizable styling and labels.
Properly transforms geometries from WGS84 to the target projection.

# Arguments
- `df::DataFrame`: DataFrame containing:
  - `geom`: WKT geometry strings
  - `parsed_geoms`: (optional) Pre-parsed geometries
  - `pop_bins`: Bin numbers for coloring (1-7)
  - `county`: County names for labels
- `title::String`: Title for the map
- `dest::String`: PROJ.4 string for the target projection
- `fig::Figure`: The Makie figure to plot on

# Returns
- `GeoAxis`: The axis containing the plotted map

# Features
- Automatic geometry parsing if not pre-parsed
- Custom color scheme with 7 bins
- County labels at polygon centroids
- Black polygon borders with 0.5 opacity
- White label text with 12pt font size

# Example
```julia
using CairoMakie
fig = Figure()
df = DataFrame(
    geom = ["POLYGON ((...))", ...],
    pop_bins = [1, 2, 3, ...],
    county = ["County A", "County B", ...]
)
map_poly(df, "Population by County", dest, fig)
```

# Notes
- Requires ArchGDAL for geometry operations
- Uses GeometryBasics for polygon creation
- Automatically handles multipolygon geometries
"""
function map_poly(df::DataFrame, title::String, dest::String, fig::Figure)
    # Ensure we have parsed geometries
    if !hasproperty(df, :parsed_geoms)
        df.parsed_geoms = parse_geoms(df)
    end

    custom_colors = [
        :forestgreen,  # Bin 1
        :darkseagreen, # Bin 2
        :lightskyblue3,# Bin 3
        :slategray,    # Bin 4
        :royalblue,    # Bin 5
        :blue2,        # Bin 6
        :gold1         # Bin 7
    ]

    # Create the GeoAxis with proper projection setup
    ga1 = GeoAxis(
        fig[1, 1],
        title=title,
        dest=dest,
        aspect=DataAspect()
    )

    # Plot the polygons
    for i in 1:nrow(df)
        geom = df.parsed_geoms[i]
        if ismissing(geom)
            continue
        end
        
        multi_poly = geom
        n_polys = ArchGDAL.ngeom(multi_poly)
        
        # Get the bin number and ensure it's valid
        # Prefer bin_values when available (should be integers)
        bin_num = if hasproperty(df, :bin_values)
            df[i, :bin_values]
        else
            # Fall back to pop_bins
            df[i, :pop_bins]
        end
        
        # Ensure bin_num is an integer
        if bin_num isa AbstractString
            # Try to convert string to integer if possible
            try
                bin_num = parse(Int, bin_num)
            catch
                # If conversion fails, default to bin 1
                bin_num = 1
            end
        end
        
        for p_idx in 0:(n_polys-1)
            poly = ArchGDAL.getgeom(multi_poly, p_idx)
            ext_ring = ArchGDAL.getgeom(poly, 0)
            
            point_list = Point2f[]
            for i in 0:(ArchGDAL.ngeom(ext_ring)-1)
                x = Float64(ArchGDAL.getx(ext_ring, i))
                y = Float64(ArchGDAL.gety(ext_ring, i))
                push!(point_list, Point2f(x, y))
            end
            
            if !isempty(point_list)
                poly_obj = GeometryBasics.Polygon(point_list)
                # Ensure bin_num is within valid range
                color_idx = min(max(1, bin_num), length(custom_colors))
                poly!(
                    ga1,
                    poly_obj,
                    color=custom_colors[color_idx],
                    strokecolor=(:black, 0.5),
                    strokewidth=1
                )
            end
        end
    end

    # Add labels
    for i in 1:nrow(df)
        if !ismissing(df.parsed_geoms[i])
            centroid = ArchGDAL.centroid(df.parsed_geoms[i])
            x = Float64(ArchGDAL.getx(centroid, 0))
            y = Float64(ArchGDAL.gety(centroid, 0))
            text!(
                ga1,
                x,
                y,
                text=string(df[i, :county]),
                fontsize=12,
                color=:white
            )
        end
    end

    return ga1
end

# Export the function
export map_poly