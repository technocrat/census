# deprecated; move to holding/display_map.jl
fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], title, fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
fig