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

# df[in.(df.geoid, Ref(to_gl)), :pop_bins] .= 8
# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)

addns       = filter(:geoid  => x -> x ∈ add_to_concordia,df)
df          = vcat(df,addns)
df          = filter(:geoid  => x -> x ∉ take_from_concordia,df)
exclude_ny  = setdiff(get_geo_pop(["NY"]).geoid,add_to_concordia)
df          = filter(:geoid  => x -> x ∉ exclude_ny,df)
#df          = filter(:stusps => x -> x ∉ concord,df)
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
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



