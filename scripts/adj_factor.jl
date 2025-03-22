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
df.parsed_geoms = parse_geoms(df)

ohio_basin_in  = setdiff(get_geo_pop(["IN"]).geoid,gl_in)
ohio_basin_ky  = setdiff(get_geo_pop(["KY"]).geoid,miss_basin_ky)
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

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], title, fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)
