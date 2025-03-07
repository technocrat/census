# this has to be done manually for a strange reason
# include("libr.jl")
# include("table_plot.jl")
# before calling
# include("src/midwest.jl")
#include("cons.jl")
#include("func.jl")

geo_query = """
    SELECT us.geoid, us.stusps, us.name, ST_AsText(us.geom) as json_geom, vd.value as total_population
    FROM census.counties us
    LEFT JOIN census.variable_data vd
        ON us.geoid = vd.geoid
        AND vd.variable_name = 'total_population'
"""
target = "'OH', 'MI', 'IN', 'IL', 'WI'"
gdp_query = """
    SELECT gdp.county, gdp.state, gdp.gdp
    FROM gdp
    WHERE gdp .state IN ('Ohio','Michigan','Indiana','Illinois', 'Wisconsin')
"""


mw_pop                = DataFrame(q(geo_query))
rename!(mw_pop, [:geoid, :stusps, :county, :geom, :pop])
mw_gdp                = DataFrame(q(gdp_query))
mw_gdp.gdp            = Float64.(mw_gdp.gdp)
state_to_abbreviation = Dict(Mw .=> MW)
mw_gdp.stusps         = [state_to_abbreviation[state] for state in mw_gdp.state]
joined_data           = leftjoin(mw_pop, mw_gdp, on=[:county, :stusps])
# Lagrange, Indiana inserted manually; although it is in psql table
# comes out as missing
# from https://apps.bea.gov/itable/?ReqID=99&step=1#eyJhcHBpZCI6OTksInN0ZXBzIjpbMSwyOSwyNSwyNiwyNyw0MF0sImRhdGEiOltbIlRhYmxlSWQiLCI1MzMiXSxbIk1ham9yQXJlYUtleSIsIjQiXSxbIkxpbmUiLCIxIl0sWyJTdGF0ZSIsIjE4MDAwIl0sWyJVbml0X29mX01lYXN1cmUiLCJMZXZlbHMiXSxbIk1hcENvbG9yIiwiQkVBU3RhbmRhcmQiXSxbIm5SYW5nZSIsIjUiXSxbIlllYXIiLCIyMDIzIl0sWyJZZWFyQmVnaW4iLCItMSJdLFsiWWVhckVuZCIsIi0xIl1dfQ==
# 193105000
joined_data[437,:state] = "Indiana"
joined_data[437,:gdp] = 193105000

joined_data.den = joined_data.gdp ./ joined_data.pop

pa_vector = string.([42059,42125,42129,42003,42007,42073,42085,42034,42019])

geo_query = """
    SELECT ne.geoid, ne.stusps, ne.name, ST_AsText(ne.geom) as json_geom, vd.value as total_population
    FROM census.counties ne
    LEFT JOIN census.variable_data vd
        ON ne.geoid = vd.geoid
        AND vd.variable_name = 'total_population'
    WHERE ne.stusps IN ('PA')
"""

pa_pop = DataFrame(q(geo_query))
pa     = string.([42059,42039, 42049, 42125,42129,42003,42007,42073,42085,42034])
pa_pop = filter(:geoid => x -> x in pa, pa_pop)
rename!(pa_pop, :name => "county")
gdp_query = """
    SELECT gdp.county, gdp.state, gdp.gdp
    FROM gdp
    WHERE gdp         .state IN ('Pennsylvania')
"""

pa_gdp      = DataFrame(q(gdp_query))
pa_gdp.gdp  = Float64.(pa_gdp.gdp)
pa_counties = pa_pop.county
pa_gdp      = filter(:county => x -> x in pa_counties, pa_gdp)

state_to_abbreviation = Dict("Pennsylvania" .=> "PA")
pa_gdp.stusps         = [state_to_abbreviation[state] for state in pa_gdp.state]
pa_joined_data        = leftjoin(pa_pop, pa_gdp, on=[:county,:stusps])
pa_joined_data.den    = pa_joined_data.gdp ./ pa_joined_data.total_population
rename!(pa_joined_data, [:geoid,:stusps,:county,:geom,:pop,:state,:gdp,:den])

joined_data          = vcat(joined_data, pa_joined_data)
include("r_setup.jl")
setup_r_environment()
kpop                 = get_breaks(joined_data, 5)[3][2]
kgdp                 = get_breaks(joined_data, 7)[3][2]
kden                 = get_breaks(joined_data, 8)[3][2]
joined_data.pop_bins = my_cut(joined_data.pop, kpop)
joined_data.gdp_bins = my_cut(joined_data.gdp, kgdp)
joined_data.den_bins = my_cut(joined_data.den, kden)

multipolygon_wkt         = joined_data[:, :geom]
parsed_geom              = parse_multipolygon.(multipolygon_wkt)
joined_data.parsed_geoms = parse_multipolygon.(multipolygon_wkt)

categories = unique(joined_data.den_bins)

if length(categories) > length(map_colors)
    error("Not enough colors in map_colors for all categories in den_bins")
end

category_to_color = Dict(category => map_colors[i] for (i, category) in enumerate(categories))

kpop_vector = RCall.rcopy(kpop)
kgdp_vector = RCall.rcopy(kgdp)
kden_vector = RCall.rcopy(kden)

# Create value ranges from cut points
kpop_ranges = ["$(round(Int, kpop_vector[i])) - $(round(Int, kpop_vector[i+1]))" for i in 1:length(kpop_vector)-1]
push!(kpop_ranges, "≥ $(round(Int, kpop_vector[end]))") # Add the last range
kgdp_ranges = ["$(round(Int, kgdp_vector[i])) - $(round(Int, kgdp_vector[i+1]))" for i in 1:length(kgdp_vector)-1]
push!(kgdp_ranges, "≥ $(round(Int, kgdp_vector[end]))") # Add the last range
kden_ranges = ["$(round(Int, kden_vector[i])) - $(round(Int, kden_vector[i+1]))" for i in 1:length(kden_vector)-1]
push!(kden_ranges, "≥ $(round(Int, kden_vector[end]))") # Add the last range

pop_format = pad_vector(insert_commas.(kpop_ranges)[1:6])
gdp_format = pad_vector(insert_commas.(kgdp_ranges)[1:6])
den_format = pad_vector(insert_commas.(kden_ranges)[1:6])

palette = map_colors[1:6]
df = DataFrame(
    col1=palette,
    col2=pop_format,
    col3=palette,
    col4=gdp_format,
    col5=palette,
    col6=den_format
)

#final_fig = Figure(size=(1280, 600))
#
#ax1 = ga(final_fig[1,1], "Population")
#for row in eachrow(joined_data)
#   plot_geometry!(ax1, row[:parsed_geoms], category_to_color[row[:pop_bins]])
#end
#xlims!(ax1, -95, -70)
#ylims!(ax1, 35, 50)
#
#ax2 = ga(final_fig[1,2], "Gross Domestic Product")
#for row in eachrow(joined_data)
#   plot_geometry!(ax2, row[:parsed_geoms], category_to_color[row[:gdp_bins]])
#end
#xlims!(ax2, -95, -70)
#ylims!(ax2, 35, 50)
#
#ax3 = ga(final_fig[1,3], "GDP per capita")
#for row in eachrow(joined_data)
#   plot_geometry!(ax3, row[:parsed_geoms], category_to_color[row[:den_bins]])
#end
#xlims!(ax3, -95, -70)
#ylims!(ax3, 35, 50)
#
#table_ax = Axis(final_fig[2,1:3])
#
#nrows, ncols = size(df)
#xlims!(table_ax, 8.0*0.5, ncols*8.0 + 8.0*0.5)
#ylims!(table_ax, -0.5, nrows+0.5)
#table_ax.aspect = DataAspect()
#hidedecorations!(table_ax)
#hidespines!(table_ax)
#
#for row in 1:nrows
#   for col in 1:ncols
#       x = col * 8.0
#       if isodd(col)  # Columns 1, 3, 5 contain colors
#           GeoMakie.scatter!(table_ax, [x], [row],
#               marker=:rect,
#               color=[df[row, col]],  # The color value is already an RGB
#               markersize=20)
#       else  # Columns 2, 4, 6 contain strings
#           text!(table_ax, df[row, col],  # Use the string directly
#               position=(x, row),
#               align=(:center, :center),
#               fontsize=18,
#               font="Courier")
#       end
#   end
#end


