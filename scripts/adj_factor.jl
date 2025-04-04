# SPDX-License-Identifier: MIT
using Census

# Initialize census data
us = init_census_data()

add_from_metro = ["36003", "36009", "36011",
    "36013", "36014", "36015", "36019", "36019", "36029",
    "36031", "36031", "36033", "36037", "36037", "36037",
    "36041", "36043", "36045", "36049", "36051", "36055",
    "36063", "36065", "36067", "36069", "36073", "36075",
    "36089", "36097", "36099", "36101", "36107", "36109",
    "36117", "36121", "36123"]
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


df = filter(:stusps => x -> x != "WI",df)
df = filter(:stusps => x -> x != "MI",df)
df = filter(:geoid  => x -> x ∉ gl_in,df)
df = filter(:geoid  => x -> x ∉ gl_oh,df)  
df = filter(:geoid  => x -> x ∉ take_from_al,df)
df = filter(:geoid  => x -> x ∉ take_from_ga,df)
df = filter(:geoid  => x -> x ∉ take_from_il,df)
df = filter(:geoid  => x -> x ∉ take_from_ky,df)
df = filter(:geoid  => x -> x ∉ take_from_md,df)
df = filter(:geoid  => x -> x ∉ take_from_metro,df)
df = filter(:geoid  => x -> x ∉ metro_to_gl,df)
df = filter(:geoid  => x -> x ∉ take_from_ms,df)
df = filter(:geoid  => x -> x ∉ take_from_nc,df)
df = filter(:geoid  => x -> x ∉ take_from_oh,df)
df = filter(:geoid  => x -> x ∉ take_from_tn,df)
df = filter(:geoid  => x -> x ∉ take_from_va,df)
df = filter(:geoid  => x -> x ∉ gl_pa && 
                            x ∉ take_from_pa,df)

oh = subset(us, :stusps => ByRow(==("OH")))


pa = subset(us, :stusps => ByRow(==("PA")))


in = subset(us, :stusps => ByRow(==("IN")))


il = subset(us, :stusps => ByRow(==("IL")))


ky = subset(us, :stusps => ByRow(==("KY")))


md = subset(us, :stusps => ByRow(==("MD")))


va = subset(us, :stusps => ByRow(==("VA")))


al = subset(us, :stusps => ByRow(==("AL")))


ms = subset(us, :stusps => ByRow(==("MS")))


ga = subset(us, :stusps => ByRow(==("GA")))


nc = subset(us, :stusps => ByRow(==("NC")))

df = vcat(oh,pa,in,il,ky,md,va,al,ms,ga,nc)

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])


# Define projection

dest = CRS_STRINGS["gateway"]

map_title = "Factoria"
fig = Figure(size=(3200, 2400), fontsize=24)
map_poly(df, map_title, dest, fig)
# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "Census", "img"))
@info "Saving to directory: $img_dir"
saved_path = save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end


display(fig)
# Store the geoids for later use
# set_nation_state_geoids(map_title, df.geoid)
