# SPDX-License-Identifier: MIT

"""
    plot_map(df::DataFrame, map_title::String, dest::String; 
             fig_size=(2400, 1600), font_size=22)

Create and display a choropleth map from a DataFrame containing geographic data.

# Arguments
- `df::DataFrame`: DataFrame containing geographic data with columns [:geoid, :stusps, :county, :geom, :pop]
- `map_title::String`: Title for the map
- `dest::String`: Destination projection string
- `fig_size::Tuple{Int,Int}=(2400, 1600)`: Figure size in pixels
- `font_size::Int=22`: Font size for the figure

# Returns
- `Figure`: The created and displayed figure

# Example
```julia
df = get_geo_pop(["CA"])
plot_map(df, "California", "+proj=aea +lat_1=35 +lat_2=45 +lat_0=40 +lon_0=-120 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
```
"""
function plot_map(df::DataFrame, map_title::String, dest::String; 
                 fig_size=(2400, 1600), font_size=22)
    # Create figure
    fig = Figure(size=fig_size, fontsize=font_size)
    
    # Prepare data
    rename!(df, [:geoid, :stusps, :county, :geom, :pop])
    setup_r_environment()
    breaks = rcopy(get_breaks(df, 5))
    df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
    df.parsed_geoms = parse_geoms(df)
    
    # Plot map
    map_poly(df, map_title, dest, fig)
    
    # Create filename from map_title and current date/time
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    safe_title = replace(map_title, " " => "_")
    filename = joinpath(dirname(@__DIR__), "img", "$(safe_title)_$(timestamp).png")
    
    # Ensure img directory exists
    mkpath(dirname(filename))
    
    # Save the figure
    save(filename, fig)
    
    # Display the figure
    display(fig)
    
    return fig
end 