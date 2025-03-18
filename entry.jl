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
#include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))

df = get_geo_pop(push!(concord, "NY"))
rename!(df, [:geoid, :stusps, :county, :geom, :pop])

# Convert WKT strings to geometric objects
geometries = df.geom
df.parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]
function update_pop_bins!(df::DataFrame, to_gl::Vector)
    # Loop through each row in the DataFrame
    for i in 1:nrow(df)
        # Check if the geoid is in the to_gl list
        if df[i, :geoid] in to_gl
            # Update the pop_bins value to 7
            df[i, :pop_bins] = 7
        end
    end
    return df
end
to_gl = [36089, 36043, 36041, 36045, 36049, 36075, 36014, 36117, 36055, 36073, 36063, 36029, 36013, 36011, 36037, 36121, 36051, 36069, 36099, 36037]
sort!(to_gl)
to_gl = string.(to_gl)
# Example usage:
# to_gl = ["36001", "36005", "36047", "36061", "36081", "36085"] # Example geoid list
# update_pop_bins!(df, to_gl)
function update_pop_bins!(df::DataFrame, to_gl::Vector)
    # Loop through each row in the DataFrame
    for i in 1:nrow(df)
        # Check if the geoid is in the to_gl list
        if df[i, :geoid] in to_gl
            # Update the pop_bins value to 7
            df[i, :pop_bins] = 7
        end
    end
    return df
end
update_pop_bins!(df, to_gl)

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "New England and New York Counties", fontsize=20)
breaks = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
fig


function update_pop_bins!(df::DataFrame, to_gl::Vector)
    # Loop through each row in the DataFrame
    for i in 1:nrow(df)
        # Check if the geoid is in the to_gl list
        if df[i, :geoid] in to_gl
            # Update the pop_bins value to 7
            df[i, :pop_bins] = 7
        end
    end
    return df
end

# Example usage:
# to_gl = ["36001", "36005", "36047", "36061", "36081", "36085"] # Example geoid list
update_pop_bins!(df, to_gl)
