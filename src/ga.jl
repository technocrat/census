# SPDX-License-Identifier: MIT

"""
    ga(dest::String, row::Int, col::Int, title::String, fig::Figure, df::DataFrame) -> GeoAxis

Creates a GeoAxis with the specified destination CRS and title, using the bounding box of all geometries.
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
