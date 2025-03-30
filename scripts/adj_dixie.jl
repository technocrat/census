# SPDX-License-Identifier: MIT
# needs holes filled
south_fl      = ["12075","12083","12107","12035","12127","12117",
                 "12053","12119","12069","12095","12009","12101",
                 "12103","12057","12105","12097","12009","12081",
                 "12115","12097","12061","12049","12093","12061",
                 "12027","12111","12015","12043","12085","12071",
                 "12027","12071","12051","12099","12021","12011",
                 "12087","12086","12055","12017"]
ohio_basin_al = ["01077","01083","01089","01033",
                 "01059","01079","01103","01071","01049","01195"]
ohio_basin_ms = ["28141"]
ohio_basin_nc = ["37039","37043","37075","37113",
                 "37087","37099",
                 "37115","37021","37011","37009","37005","37173",
                 "37189","37121","37199","37089","37089"]
ohio_basin_va = ["51105","51169","51195","51120",
                 "51051","51027",
                 "51167","51191","51070","51021","51071","51155",
                 "51035","51195","51197","51173","51077","51185",
                 "51750","51640","51520","51720"]
exclude_from_va  = ["51131","51103","51133","51099",
                  "51159","51630","51179","51153",
                  "51683","51685","51059","51600",
                  "51510","51107","51043","51840",
                  "51069","51013","51001","51013",
                  "51193","51061"]
ohio_basin_ga = ["13295","13111","13291","13241",
                 "13083","13111"]
ms_east_la    = ["22125","22091","22058","22117",
                 "22033","22063",
                 "22103","22093","22095","22029","22051","22075",
                 "22087","22037","22105","22051","22071","22089",
                 "22093"]
gl_oh = ["39055", "39085", "39035", "39103", "39093", "39043"]
ohio_basin_nc = ["37039","37043","37075","37113","37087","37099",
                 "37115","37021","37011","37009","37005","37173",
                 "37189","37121","37199","37089","37089"]
take_from_md   = ["24023","24001","24043"]
ms_east_la = ["22125", "22091", "22058", "22117", "22033", "22063",
    "22103", "22093", "22095", "22029", "22051", "22075",
    "22087", "22037", "22105", "22051", "22071", "22089",
    "22093"]

ohio_basin_al = ["01077", "01083", "01089", "01033", "01059", "01079",
    "01103", "01071", "01049", "01195"]
ohio_basin_ms = ["28141"]
ohio_basin_ga = ["13295", "13111", "13291", "13241", "13083", "13111"]


map_title = "Adjusted New Dixie"
us          = get_geo_pop(Census.postals)

al = subset(us, :stusps => ByRow(==("AL"))) 
al = subset(al, :geoid => ByRow(x -> x ∉ ohio_basin_al))

ms = subset(us, :stusps => ByRow(==("MS"))) 
ms = subset(ms, :geoid => ByRow(x -> x ∉ ohio_basin_ms))

ga = subset(us, :stusps => ByRow(==("GA"))) 
ga = subset(ga, :geoid => ByRow(x -> x ∉ ohio_basin_ga))

fl = subset(us, :stusps => ByRow(==("FL"))) 
fl = subset(fl, :geoid => ByRow(x -> x ∉ south_fl))

sc = subset(us, :stusps => ByRow(==("SC"))) 

nc = subset(us, :stusps => ByRow(==("NC"))) 
nc = subset(nc, :geoid => ByRow(x -> x ∉ ohio_basin_nc))

va = subset(us, :stusps => ByRow(==("VA"))) 
va = subset(va, :geoid => ByRow(x -> x ∉ exclude_from_va))

wv = subset(us, :stusps => ByRow(==("WV"))) 

la = subset(us, :stusps => ByRow(==("LA"))) 
la = subset(la, :geoid => ByRow(x -> x ∈ ms_east_la))

ky = subset(us, :stusps => ByRow(==("KY"))) 
ky = subset(ky, :geoid => ByRow(x -> x ∉ ohio_basin_ky))

tn = subset(us, :stusps => ByRow(==("TN")))
tn = subset(tn, :geoid => ByRow(x -> x ∉ oh_basin_tn))

md = subset(us, :stusps => ByRow(==("MD")))
md = subset(md, :geoid => ByRow(x -> x ∈ take_from_md))

df = vcat(fl,nc,va,wv,ky,tn,md,la,al,ms,ga,sc)


rename!(df, [:geoid, :stusps, :county, :geom, :pop])

breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)

# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df,map_title,dest,fig)
# Display the figure
display(fig)