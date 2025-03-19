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

rejig       = copy(metropolis)
regig       = push!(rejig,"NY","PA","WV","CT")
df          = get_geo_pop(rejig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

take_from =["24003", "24001", "24023", "36003", "36009", "36011", 
            "36013", "36014", "36015", "36019", "36019", "36029", 
            "36031", "36031", "36033", "36037", "36037", "36037", 
            "36041", "36043", "36045", "36049", "36051", "36055", 
            "36063", "36065", "36067", "36069", "36073", "36075", 
            "36089", "36097", "36099", "36101", "36107", "36109", 
            "36117", "36121", "36123", "42003", "42005", "42007", 
            "42009", "42013", "42015", "42019", "42021", "42023",
            "42027", "42031", "42033", "42035", "42037", "42039", 
            "42047", "42049", "42051", "42053", "42057", "42059", 
            "42061", "42063", "42065", "42067", "42073", "42081", 
            "42083", "42085", "42087", "42093", "42097", "42099", 
            "42104", "42105", "42109", "42111", "42113", "42117", 
            "42119", "42121", "42123", "42125", "42129", "43031", 
            "43063", "51003", "51025", "51029", "51040", "51049", 
            "51064", "51065", "51068", "51069", "51079", "51081", 
            "51084", "51084", "51093", "51111", "51113", "51139", 
            "51147", "51171", "51175", "51181", "51183", "51540", 
            "51550", "51595", "51620", "51684", "51710", "51740", 
            "51800", "51810", "51840", "54001", "54001", "54027", 
            "54031", "54139", "54140", "51011", "51017", "51019", 
            "51021", "51035", "51037", "51045", "51071", "51077",
            "51083", "51091", "51105", "51117", "51121", "51125", 
            "51141", "51143", "51155", "51165", "51185", "51189", 
            "51191", "51197", "51599", "51660", "51820", "51169", 
            "51167", "51027", "51173", "51051", "51195", "51220", 
            "51520", "51640", "51750", "51063", "51067", "51023", 
            "51890", "51590", "51031", "51689", "51009", "51530", 
            "51678", "51163", "51780", "51680", "51790", "51035", 
            "51256", "51035", "51720", "51690", "51775", "51770",
            "51015", "51161", "51089", "51080", "51580", "51005"]

add_to      = ["09190","09120","54065","54003","54037"]

ny          = filter(:stusps => x -> x ∈ rejig,df)
breaks      = rcopy(get_breaks(ny,5))
ny.pop_bins = my_cut(ny.pop, breaks[:kmeans][:brks])

# df[in.(df.geoid, Ref(to_gl)), :pop_bins] .= 8
# Convert WKT strings to geometric objects
geometries = df.geom
df.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]
# Convert WKT strings to geometric objects
geometries = ny.geom
ny.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]

ny =  filter(:stusps => x -> x != "WV" && x ∉ add_to,ny)
ny =  filter(:stusps => x -> x != "CT" && x ∉ add_to,ny)
addns       = filter(:geoid  => x -> x ∈ add_to,df)
ny          = vcat(ny,addns)
ny          = filter(:geoid  => x -> x ∉ take_from,ny)
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
poly1 = map_poly(ny,ga1, "pop")
add_labels!(ny, ga1, :geoid, fontsize=6)
fig



