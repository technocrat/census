# SPDX-License-Identifier: MIT


us              = get_geo_pop(Census.postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])


const colorado_basin_geoids = get_colorado_basin_geoids()
const slope_geoids = get_slope_geoids().geoid
missouri_river_basin = ["30005", "30007", "30013", "30015", "30017",
    "30021", "30027", "30033", "30041", "30045",
    "30049", "30051", "30055", "30059", "30069",
    "30071", "30075", "30079", "30083", "30085",
    "30087", "30091", "30099", "30101", "30105",
    "30109", "38001", "38007", "38011", "38013",
    "38015", "38023", "38025", "38029", "38033",
    "38037", "38041", "38053", "38055", "38057",
    "38059", "38061", "38065", "38085", "38087",
    "38089", "38101", "38105", "46003", "46005",
    "46007", "46009", "46011", "46013", "46015",
    "46017", "46019", "46021", "46023", "46025",
    "46029", "46031", "46033", "46035", "46037",
    "19001", "19003", "31001", "29003", "31003",
    "31005", "29005", "19009", "31007", "27011",
    "31009", "31011", "31013", "31015", "31017",
    "29021", "31019", "31021", "31023", "19027",
    "29033", "19029", "31025", "31027", "29041",
    "31029", "19035", "31031", "31033", "27023",
    "29045", "19039", "31035", "29051", "31037",
    "29053", "19047", "31039", "31041", "31043",
    "19049", "31045", "31047", "31049", "31051",
    "31053", "31055", "31057", "31059", "29071",
    "31061", "19071", "31063", "31065", "31067",
    "31069", "31071", "29073", "31073", "31075",
    "31077", "19073", "19077", "31079", "31081",
    "31083", "19085", "31085", "31087", "29087",
    "31089", "31091", "29089", "31093", "19093",
    "29095", "29099", "31095", "31097", "31099",
    "31101", "31103", "31105", "31107", "27073",
    "31109", "29111", "27081", "29113", "31111",
    "31113", "31115", "31119", "29127", "31117",
    "31121", "19129", "29135", "19133", "19137",
    "29139", "31123", "27101", "31125", "31127",
    "27105", "31129", "29151", "31131", "19145",
    "31133", "31135", "29157", "31137", "31139",
    "29163", "27117", "29165", "31141", "19149",
    "31143", "19155", "29173", "31145", "27127",
    "31147", "19159", "27133", "31149", "19161",
    "29195", "31151", "31153", "31155", "31157",
    "31159", "19165", "31161", "31163", "19167",
    "31165", "29183", "29189", "31167", "27151",
    "19173", "31169", "31171", "31173", "27155",
    "19175", "31175", "29219", "29221", "31177",
    "31179", "31181", "31183", "19193", "27173",
    "31185", "30019"]
az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∈ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))

mt = subset(us, :stusps => ByRow(==("MT")))
mt_keep = ["30011","30025"]
mt = subset(mt, :geoid => ByRow(x -> x ∈ missouri_river_basin || x ∈ mt_keep))

co = subset(us, :stusps => ByRow(x -> x == "CO"))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∈ western_geoids))

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ western_geoids))
ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ western_geoids))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ western_geoids))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ western_geoids))

ok = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∉ eastern_geoids))

tx = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ western_geoids))

ut = subset(us, :stusps => ByRow(==("UT")))
keep_ut = ["48047","49037","49019"]
ut = subset(ut, :geoid => ByRow(x -> x ∈ keep_ut))

df = vcat(mt,nm,wy,az,co,az,nd,sd,ne,ks,tx,ok,ut)

df = subset(df, :stusps => ByRow(x -> x ∉ ["AK"]))
setup_r_environment()
breaks          = rcopy(get_breaks(df,5))
df.pop_bins     = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

dest = """
+proj=aea +lat_1=25 +lat_2=47 +lat_0=36 +lon_0=-110 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
"""

# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Powell", dest, fig)
# Display the figure

display(fig)





