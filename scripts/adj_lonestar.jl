# SPDX-License-Identifier: MIT

rejig       = copy(lonestar)
regig       = push!(rejig,"NY")
df          = get_geo_pop(rejig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)

addns       = filter(:geoid  => x -> x ∈ add_to_lonestar,df)
df          = vcat(df,addns)
df          = filter(:geoid  => x -> x ∉ take_from_lonestar,df)
exclude_ny  = setdiff(get_geo_pop(["NY"]).geoid,add_to_lonestar)
df          = filter(:geoid  => x -> x ∉ exclude_ny,df)

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Adjusted Lone Star", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



# Use it to filter Kansas





