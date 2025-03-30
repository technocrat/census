# SPDX-License-Identifier: MIT

"""
    map_poly(df::DataFrame, title::String, dest::String, fig::Figure; save_path::Union{String,Nothing}=nothing, preview::Bool=false)

Plot a map of polygons from a DataFrame with optional saving and preview functionality.

# Arguments
- `df::DataFrame`: DataFrame containing the geometries and data to plot
- `title::String`: Title for the map
- `dest::String`: Destination CRS for the projection
- `fig::Figure`: The figure to plot on
- `save_path::Union{String,Nothing}=nothing`: Optional path to save the figure
- `preview::Bool=false`: Whether to open the saved figure in Preview.app

# Returns
- The created figure
"""
function map_poly(df::DataFrame, title::String, dest::String, fig::Figure; 
                 save_path::Union{String,Nothing}=nothing, preview::Bool=false)
    # Ensure we have parsed geometries
    if !hasproperty(df, :parsed_geoms)
        df.parsed_geoms = parse_geoms(df.geom)
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

    # Create the GeoAxis in the second row
    ga1 = ga(dest, 1, 1, title, fig, df)   
    
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

    # Save the figure if a path is provided
    if !isnothing(save_path)
        # Ensure the directory exists
        mkpath(dirname(save_path))
        save(save_path, fig)
        
        # Open with Preview if requested
        if preview
            run(`open -a Preview $save_path`)
        end
    end

    return fig
end