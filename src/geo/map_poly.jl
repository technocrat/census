# SPDX-License-Identifier: MIT
using CairoMakie
using GeoMakie
using ArchGDAL
using GeometryBasics: Point2f, Polygon
using DataFrames: DataFrame, nrow

"""
    parse_geoms(df::DataFrame) -> Vector{ArchGDAL.IGeometry}

Parse WKT geometry strings from DataFrame into ArchGDAL geometry objects.
"""
function parse_geoms(df::DataFrame)
    return [ArchGDAL.fromWKT(geom) for geom in df.geom if !ismissing(geom)]
end

"""
    map_poly_with_projection(df::DataFrame, title::String, dest::String, fig::Figure)

Create a choropleth map of polygons from a DataFrame with customizable styling and labels.

# Arguments
- `df::DataFrame`: DataFrame containing:
  - `geom`: WKT geometry strings
  - `parsed_geoms`: (optional) Pre-parsed geometries
  - `pop_bins`: Bin numbers for coloring (1-7)
  - `county`: County names for labels
- `title::String`: Title for the map
- `dest::String`: Destination CRS (Coordinate Reference System) for the projection
- `fig::Figure`: The Makie figure to plot on

# Returns
- `Figure`: The modified figure with the map added

# Features
- Automatic geometry parsing if not pre-parsed
- Custom color scheme with 7 bins:
  1. forestgreen
  2. darkseagreen
  3. lightskyblue3
  4. slategray
  5. royalblue
  6. blue2
  7. gold1
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
map_poly_with_projection(df, "Population by County", "EPSG:4326", fig)
```

# Notes
- Requires ArchGDAL for geometry operations
- Uses GeometryBasics for polygon creation
- Automatically handles multipolygon geometries
- Creates directories for save_path if they don't exist
- Preview functionality is macOS-specific
"""
function map_poly_with_projection(df::DataFrame, title::String, dest::String, fig::Figure)
    if !hasproperty(df, :parsed_geoms)
        df.parsed_geoms = parse_geoms(df)
    end

    custom_colors = [
        :forestgreen,  # Bin 1
        :darkseagreen, # Bin 2
        :lightskyblue3,# Bin 3
        :slategray,    # Bin 4
        :royalblue,    # Bin 5
        :blue2,        # Bin 6 (if needed)
        :gold1         # Bin 7 (if needed)
    ]

    # Create the GeoAxis
    ga1 = GeoAxis(
        fig[1, 1],
        dest=dest,
        title=title
    )   
    
    # Plot the polygons
    for i in 1:nrow(df)
        geom = df.parsed_geoms[i]
        multi_poly = geom
        n_polys = ArchGDAL.ngeom(multi_poly)
        
        # Get the bin number and ensure it's valid
        bin_num = df[i, :pop_bins]
        
        for p_idx in 0:(n_polys-1)
            poly = ArchGDAL.getgeom(multi_poly, p_idx)
            ext_ring = ArchGDAL.getgeom(poly, 0)
            ring_text = ArchGDAL.toWKT(ext_ring)
            
            coords_text = replace(ring_text, "LINEARRING (" => "")
            coords_text = replace(coords_text, ")" => "")
            
            point_list = Point2f[]
            for pair in split(coords_text, ",")
                parts = split(strip(pair))
                if length(parts) >= 2
                    x = parse(Float32, parts[1])
                    y = parse(Float32, parts[2])
                    push!(point_list, Point2f(x, y))
                end
            end
            
            if !isempty(point_list)
                poly_obj = Polygon(point_list)
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

    # Add labels manually
    for i in 1:nrow(df)
        geom = df.parsed_geoms[i]
        multi_poly = geom
        centroid = ArchGDAL.centroid(multi_poly)
        x = Float64(ArchGDAL.getx(centroid, 0))
        y = Float64(ArchGDAL.gety(centroid, 0))
        text!(
            ga1,
            x,
            y,
            0.0,
            text=string(df[i, :county]),
            fontsize=12,
            color=:white
        )
    end

    return fig
end

function map_poly(df::DataFrame, title::String, dest::String, fig::Figure)
    # Ensure we have parsed geometries
    if !hasproperty(df, :parsed_geoms)
        df.parsed_geoms = parse_geoms(df)
    end

    # Define custom colors inside the function
    custom_colors = [
        :forestgreen,  # Bin 1
        :darkseagreen, # Bin 2
        :lightskyblue3,# Bin 3
        :slategray,    # Bin 4
        :royalblue,    # Bin 5
        :blue2,        # Bin 6 (if needed)
        :gold1         # Bin 7 (if needed)
    ]

    # Create the Axis directly
    ga1 = Axis(
        fig[1, 1],
        title=title,
        aspect=1
    )   

    # Plot the polygons
    for i in 1:nrow(df)
        geom = df.parsed_geoms[i]
        multi_poly = geom
        n_polys = ArchGDAL.ngeom(multi_poly)
        
        # Get the bin number and ensure it's valid
        bin_num = df[i, :pop_bins]
        
        for p_idx in 0:(n_polys-1)
            poly = ArchGDAL.getgeom(multi_poly, p_idx)
            ext_ring = ArchGDAL.getgeom(poly, 0)
            ring_text = ArchGDAL.toWKT(ext_ring)
            
            coords_text = replace(ring_text, "LINEARRING (" => "")
            coords_text = replace(coords_text, ")" => "")
            
            point_list = Point2f[]
            for pair in split(coords_text, ",")
                parts = split(strip(pair))
                if length(parts) >= 2
                    x = parse(Float32, parts[1])
                    y = parse(Float32, parts[2])
                    push!(point_list, Point2f(x, y))
                end
            end
            
            if !isempty(point_list)
                poly_obj = Polygon(point_list)
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

    return ga1
end