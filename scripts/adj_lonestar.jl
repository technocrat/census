# SPDX-License-Identifier: MIT

tx          = get_geo_pop(["TX"])
ar          = get_geo_pop(["AR"])
la          = get_geo_pop(["LA"])
ok          = get_geo_pop(["OK"])
ks          = get_geo_pop(["KS"])

ms_basin_ar = ["05001", "05003", "05017", "05021", "05031",
    "05035", "05037", "05041", "05055", "05067",
    "05069", "05075", "05077", "05079", "05093",
    "05095", "05107", "05111", "05117", "05121",
    "05123", "05147"]

ms_basin_la = ["22035", "22065", "22107", "22029", "22077",
    "22125", "22037", "22033", "22121", "22047", "22005",
    "22093", "22095", "22089", "22051", "22071", "22087",
    "22075", "22125", "22091", "22058", "22117", "22033", "22063",
    "22103", "22093", "22095", "22029", "22051", "22075",
    "22087", "22037", "22105", "22051", "22071", "22089",
    "22093"]

ar_basin_mo   = ["29011","29145","29119","29109","29009",
                 "29077","29043","29209","29113","29067",
                 "29227","29997","29153","29091","29149",
                 "29181","29213","29017","29123","29187",
                 "29097"]
ar_basin_la   = ["22023","22019","22011","22115","22069",
                 "22085","22031"]
ar_basin_tx   = ["48","48","48","48","48",
                 "48","48","48","48","48",
                 "48","48","48","48","48",
                 "48","48","48","48","48",
                 "48","48"]
rio_basin_tx  = ["48141","48229","48109","48243","48377",
                 "48301","48389","48371","48043","48443",
                 "48465","48105","48103","48475"]
rio_basin_nm  = ["35039","35056","35049","35028","35043",
                 "35001","35053","35013","35051","35061"]
rio_basin_co  = ["08023","08021","08105","08003","08109"]
western_geoids  = get_western_geoids().geoid
eastern_geoids  = get_eastern_geoids().geoid


         
tx = subset(tx, :geoid => ByRow(x -> x ∉ rio_basin_tx && x ∈ eastern_geoids))

ok = subset(ok, :geoid => ByRow(x -> x ∈ eastern_geoids))

la = subset(la, :geoid => ByRow(x -> x ∉ ms_basin_la))

ks_south = get_southern_kansas_geoids()

ks = subset(ks, :geoid => ByRow(x -> x ∈ ks_south.geoid))
ks = subset(ks, :geoid => ByRow(x -> x != "20195" && 
                                x != "20051" &&
                                x ∉ western_geoids))


df          = vcat(tx,ok,ar,la,ks)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(RSetup.get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)
                                
                                
dest = "+proj=aea +lat_0=40 +lon_0=-94 +lat_1=35 +lat_2=45 +datum=NAD83 +units=m +no_defs"

# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "The Lonestar Republic", dest, fig)
# Display the figure

display(fig)







