# SPDX-License-Identifier: MIT

"""
    add_labels!(df::DataFrame, the_axis::GeoAxis, label_column::Symbol; 
               fontsize=6, color=:black, offset=(0.0, 0.0)) -> Nothing

Add labels to a geographic plot at the centroid of each polygon.

# Arguments
- `df::DataFrame`: DataFrame containing geographic data with a parsed_geoms column
- `the_axis::GeoAxis`: The GeoAxis object to plot on
- `label_column::Symbol`: Column name in df containing the label text

# Keywords
- `fontsize::Int=6`: Font size for labels
- `color::Symbol=:black`: Color of labels
- `offset::Tuple{Float64,Float64}=(0.0, 0.0)`: (x,y) offset from centroid for label placement

# Returns
- `Nothing`

# Example
```julia
df = DataFrame(...)  # DataFrame with parsed_geoms and labels
ax = GeoAxis(...)   # Create plot axis
add_labels!(df, ax, :state_name, fontsize=8)
```
"""
function add_labels!(df::DataFrame, the_axis::GeoAxis, label_column::Symbol; 
                    fontsize=6, color=:black, offset=(0.0, 0.0))
    # Validate inputs
    if !hasproperty(df, :parsed_geoms)
        error("DataFrame must have a parsed_geoms column")
    end
    if !hasproperty(df, label_column)
        error("DataFrame must have column: $label_column")
    end
    
    # First plot the polygons
    map_poly(df, the_axis, "pop")
    
    # Then add labels
    for i in 1:nrow(df)
        try
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
        catch e
            @warn "Failed to add label for row $i: $(e)"
            continue
        end
    end
    return nothing
end

export add_labels!
