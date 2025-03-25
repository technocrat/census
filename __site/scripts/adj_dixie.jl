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

df             = get_geo_pop(["AL","MS","GA","NC","SC","FL","LA"])
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
breaks         = rcopy(get_breaks(df,5))
df.pop_bins    = my_cut(df.pop, breaks[:kmeans][:brks])
# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)
ms_east_la     = ["22125","22091","22058","22117","22033","22063",
                  "22103","22093","22095","22029","22051","22075",
                  "22087","22037","22105","22051","22071","22089",
                  "22093"]
south_fl       = ["12075","12083","12107","12035","12127","12117",
                  "12053","12119","12069","12095","12009","12101",
                  "12103","12057","12105","12097","12009","12081",
                  "12115","12097","12061","12049","12093","12061",
                  "12027","12111","12015","12043","12085","12071",
                  "12027","12071","12051","12099","12021","12011",
                  "12087","12086","12055","12017"]
                  

exclude_al     = ohio_basin_al
exclude_ms     = ohio_basin_ms
exclude_ga     = ohio_basin_ga
exclude_nc     = ohio_basin_nc
exclude_la     = setdiff(get_geo_pop(["LA"]).geoid,ms_east_la)
exclude_tn     = ohio_basin_tn
exclude_ky     = ohio_basin_ky
exclude_va     = ohio_basin_va
exclude_fl     = south_fl
# fl = filter(:stusps => ==("FL"),df)
# fl = filter(:geoid => x -> x ∉ exclude_fl,fl)
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
df = filter(:geoid => x -> x ∉ exclude_la,df)
df = filter(:geoid => x -> x ∉ exclude_fl,df)

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], title, fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)
