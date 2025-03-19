function add_labels!(df::DataFrame, the_axis::GeoAxis, label_column::Symbol; 
                    fontsize=10, color=:black, offset=(0.0, 0.0))
    # For each feature in the DataFrame
    for i in 1:nrow(df)
        multi_poly = df.parsed_geometries[i]
        
        # Calculate centroid for placing text
        # We'll convert to WKB, then back via ArchGDAL's centroid function
        centroid = ArchGDAL.centroid(multi_poly)
        
        # Extract x, y coordinates of the centroid
        x = ArchGDAL.getx(centroid, 0)
        y = ArchGDAL.gety(centroid, 0)
        
        # Get the label text from the specified column
        label_text = string(df[i, label_column])
        
        # Add the text at the centroid position with specified offset
        text!(
            the_axis,
            [x + offset[1]], [y + offset[2]],
            text=label_text,
            fontsize=fontsize,
            color=color,
            align=(:center, :center)
        )
    end
end