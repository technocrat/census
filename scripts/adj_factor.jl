julia
# SPDX-License-Identifier: MIT
using Census
using DrWatson
@quickactivate "Census"  

# Defidf paths directly
const SCRIPT_DIR   = projectdir("scripts")
const OBJ_DIR      = projectdir("obj")
const PARTIALS_DIR = projectdir("_layout/partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))
setup_r_environment()

df          = get_geo_pop(["AL","MS","GA","MD","WV","PA","OH",
                           "IL","IN","KY","TN","NC","VA"])
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
breaks         = rcopy(get_breaks(df,5))
df.pop_bins    = my_cut(df.pop, breaks[:kmeans][:brks])
# Convert WKT strings to geometric objects
geometries = df.geom
df.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries
                        if !ismissing(geom)]
ohio_basin_al = ["01077","01083","01089","01033","01059","01079",
                 "01103","01071","01049","01195"]
ohio_basin_ms = ["28141"]
ohio_basin_il = ["17019","17183","17041","17045","17029","17023",
                 "17079","17033","17159","17101","17047","17165",
                 "17193","17059","17069","17151","17049","17025",
                 "17191","17185","17065","17035"]
gl_in 		  = ["18127","18091","18141","18039","18151","18111",
                 "18073","18149","18099","18085","18113","18033",
                 "18089","18087"]
ohio_basin_in = setdiff(get_geo_pop(["IN"]).geoid,gl_in)
gl_oh 		  = ["39055","39085","39035","39103","39093","39043",
                 "39077","39033","39147","39143","39123","39095",
                 "39173","39063","39007","39003","39137","39065",
                 "39051","39171","39069","39161","39039","39125",
                 "39175","39173","37199"]
ohio_basin_oh = setdiff(get_geo_pop(["OH"]).geoid,gl_oh)
ohio_basin_pa = ["42039","42085","42073","42007","42125","42059",
                 "42123","42083","42121","42053","42047","42033",
                 "42021","42411","42065","42129","42051","42031",
                 "42005","42003","42019","42063","42111"]
ohio_basin_md = ["24023"]
ohio_basin_nc = ["37039","37043","37075","37113","37087","37099",
                 "37115","37021","37011","37009","37005","37173",
                 "37189","37121","37199","37089","37089"]
ohio_basin_va = ["51105","51169","51195","51120","51051","51027",
                 "51167","51191","51070","51021","51071","51155",
                 "51035","51195","51197","51173","51077","51185",
                 "51750","51640","51520","51720"]
ohio_basin_ga = ["13295","13111","13291","13241","13083","13111"]
miss_basin_ky = ["21039","21105","21083","21039","21105","21075",
                 "23007","21145","21007"]
ohio_basin_ky = setdiff(get_geo_pop(["KY"]).geoid,miss_basin_ky)
miss_basin_tn = ["47095","47131","47069","47079","47045","47053",
                 "47017","47097","47033","47113","47077","47023",
                 "47157","47047","47069","47109","47023","46069",
                 "47183","47075","47166","47167"]
ohio_basin_tn  = setdiff(get_geo_pop(["TN"]).geoid,miss_basin_tn)
exclude_al     = setdiff(get_geo_pop(["AL"]).geoid,ohio_basin_al)
exclude_ms     = setdiff(get_geo_pop(["MS"]).geoid,ohio_basin_ms)
exclude_ga     = setdiff(get_geo_pop(["GA"]).geoid,ohio_basin_ga)
exclude_nc     = setdiff(get_geo_pop(["NC"]).geoid,ohio_basin_nc)
exclude_md     = setdiff(get_geo_pop(["MD"]).geoid,ohio_basin_md)
exclude_pa     = setdiff(get_geo_pop(["PA"]).geoid,ohio_basin_pa)
exclude_oh     = setdiff(get_geo_pop(["OH"]).geoid,ohio_basin_oh)
exclude_il     = setdiff(get_geo_pop(["IL"]).geoid,ohio_basin_il)
exclude_in     = setdiff(get_geo_pop(["IN"]).geoid,ohio_basin_in)
exclude_ky     = setdiff(get_geo_pop(["KY"]).geoid,ohio_basin_ky)
exclude_tn     = setdiff(get_geo_pop(["TN"]).geoid,ohio_basin_tn)
exclude_va     = setdiff(get_geo_pop(["VA"]).geoid,ohio_basin_va)

# removals      = [gl_in,gl_oh,gl_pa,miss_basin_ky,miss_basin_tn,exclude_al]

# df[in.(df.geoid, Ref(to_gl)), :pop_bins] .= 8

df = filter(:geoid => x -> x ∉ exclude_al,df)
df = filter(:geoid => x -> x ∉ exclude_ms,df)
df = filter(:geoid => x -> x ∉ exclude_ga,df)
df = filter(:geoid => x -> x ∉ exclude_nc,df)
df = filter(:geoid => x -> x ∉ exclude_oh,df)
df = filter(:geoid => x -> x ∉ exclude_il,df)
df = filter(:geoid => x -> x ∉ exclude_in,df)
df = filter(:geoid => x -> x ∉ exclude_ky,df)
df = filter(:geoid => x -> x ∉ exclude_tn,df)
df = filter(:geoid => x -> x ∉ exclude_va,df)
df = filter(:geoid => x -> x ∉ exclude_pa,df)
df = filter(:geoid => x -> x ∉ exclude_md,df)

#df = filter(:stusps => x -> x != "PA",df)
# df = filter(:stusps => x -> x != "PA",df)
# df = filter(:stusps => x -> x != "NY",df)

map_colors = [gl_in,gl_oh,gl_
   colorant"#326313",  # FOREST_GREEN
   colorant"#74909a",  # SLATE_GREY
   colorant"#b6d1ba",  # SAGE_GREEN
   colorant"#d8bfd8",  # VIE_EN_ROSE
   colorant"#cfcfcf",  # LIGHT_GRAY
   colorant"#a0ced9",  # SKY_BLUE
   colorant"#486ab2"  # BRIGHT_BLUE]
   # colorant"#fff626",  # KODAK_YELLOW
   # colorant"#ffffff"   # SNOW_WHITE


fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Adjusted Factoria", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)

