# SPDX-License-Identifier: MIT
using Census

dest = get_crs("desert")
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)
us = get_geo_pop(Census.postals)

az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))
nm = subset(nm, :geoid => ByRow(x -> x ∉ western_geoids))

mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ east_of_utah_geoids.geoid))

id = subset(us, :stusps => ByRow(==("ID")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∉ east_of_utah_geoids.geoid))


nv = subset(us, :stusps => ByRow(==("NV")))
nv = subset(nv, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

ut = subset(us, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ east_of_cascade_geoids))

ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∈ east_of_sierras_geoids))

wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∈ east_of_cascade_geoids))

df = vcat(az, id, nv, or, wa, ut, ca)
breaks      = RCall.rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

df.parsed_geoms = parse_geoms(df)
map_poly(df, "Adjusted Deseret", dest, fig)
# Display the figure

display(fig)
