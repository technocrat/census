# SPDX-License-Identifier: MIT
using Census
using DrWatson
@quickactivate "Census"  

# Define paths directly
const SCRIPT_DIR   = projectdir("scripts")
const OBJ_DIR      = projectdir("obj")
const PARTIALS_DIR = projectdir("_layout/partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
#include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))

# Convert WKT strings to geometric objects
geometries = ne.geom
parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "New England and New York Counties", fontsize=20)

ga1 = ga(1, 1, "Population")
poly1 = map_poly(ga1, "pop")