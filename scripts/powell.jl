# SPDX-License-Identifier: MIT

using Census


dest = get_crs("powell")
map_title = "Powell"

us              = get_geo_pop(Census.postals)

az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∈ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))

mt = subset(us, :stusps => ByRow(==("MT")))
mt_keep = ["30011","30025"]
mt = subset(mt, :geoid => ByRow(x -> x ∈ east_of_utah_geoids || x ∈ mt_keep))

co = subset(us, :stusps => ByRow(x -> x == "CO"))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∈ east_of_utah_geoids))

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ western_geoids))
ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ western_geoids))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ western_geoids))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ western_geoids))

ok = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ western_geoids))

tx = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ western_geoids))

ut = subset(us, :stusps => ByRow(==("UT")))
keep_ut = ["48047","49037","49019"]
ut = subset(ut, :geoid => ByRow(x -> x ∈ keep_ut))

df = vcat(mt,nm,wy,az,co,az,nd,sd,ne,ks,tx,ok,ut)

# Plot the map using the new convenience function
plot_map(df, map_title, dest)





