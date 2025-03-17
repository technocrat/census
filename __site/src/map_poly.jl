# SPDX-License-Identifier: MIT

# assumes parsed_geometries and joined data are in namespace, along
# with map_colors—see ne.jl
function map_poly(the_axis::GeoAxis, characteristic::String)
    column_sym = Symbol(characteristic * "_bins")
    poly!(
        the_axis,
        parsed_geometries,
        color=getproperty(joined_data, column_sym),
        colormap=map_colors,
        strokecolor=(:black, 0.5),
        strokewidth=1
    )
end
