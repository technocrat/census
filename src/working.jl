using CSV, DataFrames, GMT, Printf, DataFramesMeta

# fips_tab = CSV.read("data/fips_tab.csv", DataFrame)
# # Add metadata
# metadata!(fips_tab, "source", "https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html?t", style=:note)
# metadata!(fips_tab, "date_accessed", "2024-12-19", style=:note)

const CONUS_BOX = [-125, -66.5, 24, 50]
const AK_BOX    = [-180, -130, 51, 72]
const HI_BOX    = [-161, -154, 18, 23]

shapefile = "data/cb_2023_us_county_500k.shp"
shapes    = gmtread(shapefile)

#function prepare_map_with_insets(shapes)
    # Filter for continental US (excluding AK, HI, PR and territories)
    # Continental US rough bounding box
    conus = shapes[(shapes.lon .>= CONUS_BOX[1]) .&
                   (shapes.lon .<= CONUS_BOX[2]) .&
                   (shapes.lat .>= CONUS_BOX[3]) .&
                   (shapes.lat .<= CONUS_BOX[4])]

    # Filter Alaska

    alaska = shapes[(shapes.lon .>= AK_BOX[1]) .&
                   (shapes.lon .<= AK_BOX[2]) .&
                   (shapes.lat .>= AK_BOX[3]) .&
                   (shapes.lat .<= AK_BOX[4])]

    # Filter Hawaii
    HI_BOX =
    hawaii = shapes[(shapes.lon .>= HI_BOX[1]) .&
                   (shapes.lon .<= HI_BOX[2]) .&
                   (shapes.lat .>= HI_BOX[3]) .&
                   (shapes.lat .<= HI_BOX[4])]

    # Set up the main plot for continental US
    fig = GMT.plot(conus,
                   region = CONUS_BOX,
                   proj = "ALConEq/center/-95/35",
                   frame=:g)
    # Add Alaska inset (scaled down and shifted)
    ak_scale = 0.35  # Adjust scale factor as needed
    ak_shift = [-120, 25]  # Adjust position as needed
    GMT.plot!(alaska,
              proj   = "ALConEq/center/-150/60",
              scale  = ak_scale,
              offset = ak_shift)
    # Add Hawaii inset
    hi_scale = 0.5  # Adjust scale factor as needed
    hi_shift = [-120, 20]  # Adjust position as needed
    GMT.plot!(hawaii,
              proj   = "ALConEq/center/-157.5/20.5",
              scale  = hi_scale,
              offset = hi_shift)
#    return fig
#end

# prepare_map_with_insets(geoms)

# Add metadata
metadata!(fips_tab, "source", "https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html?t", style=:note)
metadata!(fips_tab, "date_accessed", "2024-12-19", style=:note)

using GMT, DataFrames

function filter_and_join_counties(shapes::Vector{<:GMTdataset}, data_df::DataFrame)
    # Create empty vectors to store filtered counties
    continental_counties = GMTdataset[]
    alaska_counties = GMTdataset[]
    hawaii_counties = GMTdataset[]

    # Define state codes to filter
    continental_states = setdiff(1:56, [2, 15, 72]) # Exclude AK(2), HI(15), PR(72)

    for county in shapes
        state_fp = parse(Int, county.STATEFP)

        if state_fp == 2  # Alaska
            push!(alaska_counties, county)
        elseif state_fp == 15  # Hawaii
            push!(hawaii_counties, county)
        elseif state_fp in continental_states
            push!(continental_counties, county)
        end
    end

    # Function to extract color values for a set of counties
    function get_county_colors(counties, data_df)
        colors = Float64[]
        for county in counties
            # Find matching row in dataframe
            state_fp = county.STATEFP
            county_fp = county.COUNTYFP
            value = data_df[(data_df.STATEFP .== state_fp) .&
                           (data_df.COUNTYFP .== county_fp), :value]
            push!(colors, isempty(value) ? NaN : first(value))
        end
        return colors
    end

    # Get colors for each set of counties
    conus_colors = get_county_colors(continental_counties, data_df)
    ak_colors = get_county_colors(alaska_counties, data_df)
    hi_colors = get_county_colors(hawaii_counties, data_df)

    return (
        continental = (shapes=continental_counties, colors=conus_colors),
        alaska = (shapes=alaska_counties, colors=ak_colors),
        hawaii = (hawaii_counties, colors=hi_colors)
    )
end

# Usage example:
# Assuming your dataframe has columns STATEFP, COUNTYFP, and value
function plot_choropleth(shapes, data_df)
    filtered = filter_and_join_counties(shapes, data_df)

    # Plot continental US
    fig = plot(filtered.continental.shapes,
              region=[-125, -66.5, 24, 50],
              proj="ALConEq/center/-95/35",
              frame=:g,
              color=filtered.continental.colors,
              cmap=:viridis)  # or your preferred colormap

    # Add Alaska inset
    plot!(filtered.alaska.shapes,
          proj="ALConEq/center/-150/60",
          scale=0.35,
          offset=[-120, 25],
          color=filtered.alaska.colors)

    # Add Hawaii inset
    plot!(filtered.hawaii.shapes,
          proj="ALConEq/center/-157.5/20.5",
          scale=0.5,
          offset=[-120, 20],
          color=filtered.hawaii.colors)

    return fig
end


using GMT, DataFrames

function filter_and_join_counties(counties::Vector{<:GMTdataset}, data_df::DataFrame)
    # Create empty vectors to store filtered counties
    continental_counties = GMTdataset[]
    alaska_counties = GMTdataset[]
    hawaii_counties = GMTdataset[]

    # Define state codes to filter
    continental_states = setdiff(1:56, [2, 15, 72]) # Exclude AK(2), HI(15), PR(72)

    for county in counties
        state_fp = parse(Int, county.attrib["STATEFP"])

        if state_fp == 2  # Alaska
            push!(alaska_counties, county)
        elseif state_fp == 15  # Hawaii
            push!(hawaii_counties, county)
        elseif state_fp in continental_states
            push!(continental_counties, county)
        end
    end

    # Function to extract color values for a set of counties
    function get_county_colors(counties, data_df)
        colors = Float64[]
        for county in counties
            # Find matching row in dataframe
            state_fp = county.attrib["STATEFP"]
            county_fp = county.attrib["COUNTYFP"]
            value = data_df[(data_df.STATEFP .== state_fp) .&
                           (data_df.COUNTYFP .== county_fp), :value]
            push!(colors, isempty(value) ? NaN : first(value))
        end
        return colors
    end

    return (
        continental = (shapes=continental_counties, colors=get_county_colors(continental_counties, data_df)),
        alaska = (shapes=alaska_counties, colors=get_county_colors(alaska_counties, data_df)),
        hawaii = (shapes=hawaii_counties, colors=get_county_colors(hawaii_counties, data_df))
    )
end
