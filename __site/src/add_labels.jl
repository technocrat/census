# SPDX-License-Identifier: MIT
function add_labels!(df::DataFrame, the_axis::GeoAxis, label_column::Symbol; 
                    fontsize=6, color=:black, offset=(0.0, 0.0))
    # First plot the polygons
    map_poly(df, the_axis, "pop")
    
    # Then add labels
    for i in 1:nrow(df)
        # Convert string to geometry if needed
        geom = df.geom[i] isa String ? ArchGDAL.fromWKT(df.geom[i]) : df.geom[i]
        multi_poly = geom
        
        # Calculate centroid for placing text
        # We'll convert to WKB, then back via ArchGDAL's centroid function
        centroid = ArchGDAL.centroid(multi_poly)
        
        # Extract x, y coordinates of the centroid
        x = Float64(ArchGDAL.getx(centroid, 0))  # Convert to Float64
        y = Float64(ArchGDAL.gety(centroid, 0))  # Convert to Float64
        
        # Get the label text from the specified column
        label_text = string(df[i, label_column])
        
        # Add the text at the centroid position with specified offset
        # Use separate coordinates instead of Point3f
        text!(
            the_axis,
            x + offset[1],  # Use Float64 coordinates
            y + offset[2],  # Use Float64 coordinates
            0.0,           # z coordinate
            text=label_text;
            fontsize=fontsize,
            color=:white
        )
    end
end
