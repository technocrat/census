# SPDX-License-Identifier: MIT
function add_labels!(df::DataFrame, the_axis::GeoAxis, label_column::Symbol; 
                    fontsize=6, color=:black, offset=(0.0, 0.0))
    # First plot the polygons
    map_poly(df, the_axis, "pop")
    
    # Then add labels
    for i in 1:nrow(df)
        # Get the centroid from parsed_geoms
        centroid = ArchGDAL.centroid(df.parsed_geoms[i])
        
        # Extract x, y coordinates of the centroid
        x = Float64(ArchGDAL.getx(centroid, 0))
        y = Float64(ArchGDAL.gety(centroid, 0))
        
        # Get the label text from the specified column
        label_text = string(df[i, label_column])
        
        # Add the text at the centroid position with specified offset
        text!(
            the_axis,
            [Point2f(x + offset[1], y + offset[2])],  # Use Point2f for 2D coordinates
            text=[label_text],
            fontsize=fontsize,
            color=color
        )
    end
end
