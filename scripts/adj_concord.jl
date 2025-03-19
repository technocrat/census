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

rejig       = copy(concord)
regig       = push!(rejig,"NY")
df          = get_geo_pop(rejig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

to_gl = ["09190", "09120", "23003", "23029", "36009", "36011", "36013", "36014", "36019", "36029", "36031", "36033", "36037", "36037", "36037", "36041", "36043", "36045", "36049", "36051", "36055", "36063", "36065", "36067", "36069", "36073", "36075", "36089", "36099", "36117", "36121"]
sort!(to_gl)

take_from   = ["09190","09120","23003","23029"]
add_to      = ["36031","36019"]

ne          = filter(:stusps => x -> x ∈ concord,df)
addns       = filter(:geoid  => x -> x ∈ add_to,df)
ne          = vcat(ne,addns)
ne          = filter(:geoid  => x -> x ∉ take_from,ne)
breaks      = rcopy(get_breaks(ne,5))
ne.pop_bins = my_cut(ne.pop, breaks[:kmeans][:brks])

# df[in.(df.geoid, Ref(to_gl)), :pop_bins] .= 8
# Convert WKT strings to geometric objects
geometries = df.geom
df.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]
# Convert WKT strings to geometric objects
geometries = ne.geom
ne.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]

map_colors = [
   colorant"#326313",  # FOREST_GREEN
   colorant"#74909a",  # SLATE_GREY
   colorant"#b6d1ba",  # SAGE_GREEN
   colorant"#d8bfd8",  # VIE_EN_ROSE
   colorant"#cfcfcf",  # LIGHT_GRAY
   colorant"#a0ced9",  # SKY_BLUE
   colorant"#486ab2"  # BRIGHT_BLUE
   # colorant"#fff626",  # KODAK_YELLOW
   # colorant"#ffffff"   # SNOW_WHITE
]

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Adjusted Concordia", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(ne,ga1, "pop")
add_labels!(ne, ga1, :geoid, fontsize=6)
fig



