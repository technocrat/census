# SPDX-License-Identifier: MIT

# assumes parsed_geometries is in namespace, along
# with map_colors—see CRUCIAL/debris.ne.jl

function map_poly(df::DataFrame, the_axis::GeoAxis, characteristic::String)
    column_sym = Symbol(characteristic * "_bins")
    
    # Calculate the color range from the data
    min_val = minimum(df[!, column_sym])
    max_val = maximum(df[!, column_sym])
    
    # For each feature, manually extract properly typed points
    for i in 1:nrow(df)
        multi_poly = df.parsed_geometries[i]
        n_polys = ArchGDAL.ngeom(multi_poly)
        
        for p_idx in 0:(n_polys-1)
            # Get each polygon
            poly = ArchGDAL.getgeom(multi_poly, p_idx)
            
            # For this polygon, extract its exterior ring
            ext_ring = ArchGDAL.getgeom(poly, 0)
            
            # Get WKT representation and parse
            ring_text = ArchGDAL.toWKT(ext_ring)
            
            # Clean up the WKT text
            coords_text = replace(ring_text, "LINEARRING (" => "")
            coords_text = replace(coords_text, ")" => "")
            
            # Parse points
            point_list = Point2f[]  # Empty vector of Point2f
            for pair in split(coords_text, ",")
                parts = split(strip(pair))
                if length(parts) >= 2
                    x = parse(Float32, parts[1])
                    y = parse(Float32, parts[2])
                    push!(point_list, Point2f(x, y))
                end
            end
            
            # Only plot if we have points
            if !isempty(point_list)
                # Create a properly typed polygon
                poly_obj = GeometryBasics.Polygon(point_list)
                
                # Plot this single polygon with explicit colorrange
                poly!(
                    the_axis,
                    poly_obj,  # Single GeometryBasics polygon
                    color=df[i, column_sym],
                    colormap=map_colors,
                    colorrange=(min_val, max_val),  # Add explicit colorrange
                    strokecolor=(:black, 0.5),
                    strokewidth=1
                )
            end
        end
    end
end