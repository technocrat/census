# SPDX-License-Identifier: MIT

# assumes parsed_geometries is in namespace, along
# with map_colors—see CRUCIAL/debris.ne.jl
function map_poly(df::DataFrame,the_axis::GeoAxis, characteristic::String)
    column_sym = Symbol(characteristic * "_bins")
    poly!(
        the_axis,
        parsed_geometries,
        color=getproperty(df, column_sym),
        colormap=map_colors,
        strokecolor=(:black, 0.5),
        strokewidth=1
    )
end
