# SPDX-License-Identifier: MIT
using Census

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))

ny = get_geo_pop(["NY"])
pa = get_geo_pop(["PA"])
oh = get_geo_pop(["OH"])
ind = get_geo_pop(["IN"])
mi = get_geo_pop(["MI"])
il = get_geo_pop(["IL"])
df = vcat(ny,pa,oh,ind,mi,il)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
RSetup.setup_r_environment()
breaks = RCall.rcopy(get_breaks(df,5))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)
peninsula = ["26053", "26131", "26061", "26083", "26013", "26071", "26103",
        "26003", "26109", "26041", "26053", "26956", "26976", "26033",
        "26043", "26053", "26095", "26097", "20033", "26043", "26053",
        "26153", "26069", "26001", "26007"]
metro_to_gl = ["23003", "23029", "36009",
        "36011", "36013", "36014", "36019", "36029",
        "36031", "36033", "36037", "36037", "36037",
        "36041", "36043", "36045", "36049", "36051",
        "36055", "36063", "36065", "36067", "36069",
        "36073", "36075", "36089", "36099", "36117",
        "36121"]
gl_pa = ["42049"]
gl_in = ["18127", "18091", "18141", "18039", "18151", "18111",
        "18073", "18149", "18099", "18085", "18113", "18033",
        "18089", "18087"]
gl_oh = ["39055", "39085", "39035", "39103", "39093", "39043",
        "39077", "39033", "39147", "39143", "39123", "39095",
        "39173", "39063", "39007", "39003", "39137", "39065",
        "39051", "39171", "39069", "39161", "39039", "39125",
        "39175", "39173", "37199"]
ohio_basin_il = ["17019", "17183", "17041", "17045", "17029", "17023",
        "17079", "17033", "17159", "17101", "17047", "17165",
        "17193", "17059", "17069", "17151", "17049", "17025",
        "17191", "17185", "17065", "17035", "17075"]
ny = filter(:geoid => x -> x ∈ metro_to_gl,df)
pa = filter(:geoid => x -> x ∈ gl_pa,df)
oh = filter(:stusps => x -> x == "OH",df)
oh = filter(:geoid => x -> x ∈ gl_oh,oh)
ind = filter(:stusps => x -> x == "IN",df)
ind = filter(:geoid => x -> x ∈ gl_in,ind)
mi = filter(:stusps => x -> x == "MI",df)
mi = filter(:geoid => x -> x ∉ peninsula,mi)
il = filter(:geoid => x -> x ∈ ohio_basin_il,df)

df = vcat(ny,pa,oh,ind,mi,il)
exclude_from_erie = q("WITH Iroquois_lat AS (
        SELECT ST_X(ST_Centroid(geom)) as lat 
        FROM census.counties 
        WHERE name = 'Iroquois'
        ) AND stusps = 'IL'
        SELECT geoid
        FROM census.counties c, Iroquois_lat i
        WHERE ST_X(ST_Centroid(c.geom)) < i.lat
        ORDER BY geoid;").geoid
df = filter(:geoid => x -> x ∉ exclude_from_erie,df)
DataFrames.rename!(df, [:geoid, :stusps, :county, :geom, :pop])
RSetup.setup_r_environment()
breaks      = rcopy(RSetup.get_breaks(df,5))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
dest = +proj=aea +lat_0=43.1 +lon_0=-79.0 +lat_1=41 +lat_2=45 +datum=NAD83 +units=m +no_defs
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Erie", dest, fig)
# Display the figure

display(fig)




