# SPDX-License-Identifier: MIT
# need to take out Erie
add_from_metro = ["36003", "36009", "36011",
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
    "43063"]
ohio_basin_pa = ["42039","42085","42073","42007","42125","42059",
    "42123","42083","42121","42053","42047","42033",
    "42021","42411","42065","42129","42051","42031",
    "42005","42003","42019","42063","42111"]
ohio_basin_al = ["01077","01083","01089","01033","01059","01079",
    "01103","01071","01049","01195"]
ohio_basin_ms = ["28141"]
ohio_basin_nc = ["37039","37043","37075","37113","37087","37099",
                 "37115","37021","37011","37009","37005","37173",
                 "37189","37121","37199","37089","37089"]
ohio_basin_ga = ["13295","13111","13291","13241","13083","13111"]
ohio_basin_va = ["51105","51169","51195","51120","51051","51027",
"51167","51191","51070","51021","51071","51155",
"51035","51195","51197","51173","51077","51185",
"51750","51640","51520","51720"]
gl_pa = ["42049"]
gl_in = ["18127", "18091", "18141", "18039", "18151", "18111",
        "18073", "18149", "18099", "18085", "18113", "18033",
        "18089", "18087"]
gl_oh = ["39055", "39085", "39035", "39103", "39093", "39043",
        "39077", "39033", "39147", "39143", "39123", "39095",
        "39173", "39063", "39007", "39003", "39137", "39065",
        "39051", "39171", "39069", "39161", "39039", "39125",
        "39175", "39173", "37199"]
metro_to_gl = ["23003", "23029", "36009",
    "36011", "36013", "36014", "36019", "36029",
    "36031", "36033", "36037", "36037", "36037",
    "36041", "36043", "36045", "36049", "36051",
    "36055", "36063", "36065", "36067", "36069",
    "36073", "36075", "36089", "36099", "36117",
    "36121"]
miss_basin_ky = ["21039","21105","21083","21039","21105","21075",
    "23007","21145","21007"]
ohio_basin_ky = setdiff(get_geo_pop(["KY"]).geoid,miss_basin_ky)
miss_basin_tn = ["47095","47131","47069","47079","47045","47053",
    "47017","47097","47033","47113","47077","47023",
    "47157","47047","47069","47109","47023","46069",
    "47183","47075","47166","47167"]
ohio_basin_md = ["24023","24001","24043"]
ohio_basin_tn = setdiff(get_geo_pop(["TN"]).geoid,miss_basin_tn)
ohio_basin_il = ["17019", "17183", "17041", "17045", "17029", "17023",
    "17079", "17033", "17159", "17101", "17047", "17165",
    "17193", "17059", "17069", "17151", "17049", "17025",
    "17191", "17185", "17065", "17035", "17075"]
ohio_basin_oh = setdiff(get_geo_pop(["OH"]).geoid,gl_oh)

take_from_al     = setdiff(get_geo_pop(["AL"]).geoid,ohio_basin_al)
take_from_ms     = setdiff(get_geo_pop(["MS"]).geoid,ohio_basin_ms)
take_from_ga     = setdiff(get_geo_pop(["GA"]).geoid,ohio_basin_ga)
take_from_nc     = setdiff(get_geo_pop(["NC"]).geoid,ohio_basin_nc)
take_from_md     = setdiff(get_geo_pop(["MD"]).geoid,ohio_basin_md)
take_from_pa     = setdiff(get_geo_pop(["PA"]).geoid,ohio_basin_pa)
take_from_oh     = setdiff(get_geo_pop(["OH"]).geoid,ohio_basin_oh)
take_from_il     = setdiff(get_geo_pop(["IL"]).geoid,ohio_basin_il)
take_from_in     = setdiff(get_geo_pop(["IN"]).geoid,ohio_basin_in)
take_from_ky     = setdiff(get_geo_pop(["KY"]).geoid,ohio_basin_ky)
take_from_tn     = setdiff(get_geo_pop(["TN"]).geoid,ohio_basin_tn)
take_from_va     = setdiff(get_geo_pop(["VA"]).geoid,ohio_basin_va)
take_from_metro  = setdiff(get_geo_pop(["NY"]).geoid,add_from_metro)

df = get_geo_pop(postals)

oh = subset(df, :stusps => ByRow(==("OH")))
oh = subset(oh, :geoid => ByRow(x -> x ∉ take_from_oh))

pa = subset(df, :stusps => ByRow(==("PA")))
pa = subset(pa, :geoid => ByRow(x -> x ∉ take_from_pa))

il = subset(df, :stusps => ByRow(==("IL")))
il = subset(il, :geoid => ByRow(x -> x ∉ take_from_il))

in = subset(df, :stusps => ByRow(==("IN")))
in = subset(in, :geoid => ByRow(x -> x ∉ take_from_in))     

ky = subset(df, :stusps => ByRow(==("KY")))
ky = subset(ky, :geoid => ByRow(x -> x ∉ take_from_ky))

tn = subset(df, :stusps => ByRow(==("TN")))
tn = subset(tn, :geoid => ByRow(x -> x ∉ take_from_tn)) 

va = subset(df, :stusps => ByRow(==("VA")))
va = subset(va, :geoid => ByRow(x -> x ∉ take_from_va)) 

ny = subset(df, :stusps => ByRow(==("NY")))
ny = subset(ny, :geoid => ByRow(x -> x ∉ take_from_metro))

df = vcat(oh,pa,il,in,ky,tn,va,ny)  

rename!(df, [:geoid, :stusps, :county, :geom, :pop])

breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)
map_title = "Adjusted Factoria"
dest = "+proj=aea +lat_0=38 +lon_0=-85 +lat_1=30 +lat_2=45 +datum=NAD83 +units=m +no_defs"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, map_title, dest, fig)
# Display the figure

display(fig)

