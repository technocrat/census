"""
Module for handling geographic ID constants and queries.
"""

using LibPQ
using DataFrames
using ArchGDAL
using Census

# Database connection parameters
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

# Notable Geographic IDs
const OSAGE_COUNTY_KS = "20167"  # Used as reference for Southern Kansas
const LOS_ANGELES_COUNTY = "06037"

# Longitude boundaries for regions
const WESTERN_BOUNDARY = -115.0
const EASTERN_BOUNDARY = -90.0
const CONTINENTAL_DIVIDE = -109.5
const SLOPE_WEST = -120.0
const SLOPE_EAST = -115.0
const UTAH_BORDER = -109.0
const CENTRAL_MERIDIAN = -100.0

"""
    get_db_connection() -> LibPQ.Connection

Creates a connection to the PostgreSQL database using default parameters.
"""
function get_db_connection()
    conn = LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
    return conn
end

"""
    get_western_geoids() -> DataFrame

Returns GEOIDs for counties west of 100°W longitude and east of 115°W longitude.
"""
function get_western_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) < $WESTERN_BOUNDARY
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df.geoid
end

"""
    get_eastern_geoids() -> DataFrame

Returns GEOIDs for counties between 90°W and 100°W longitude.
"""
function get_eastern_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) > $EASTERN_BOUNDARY
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df.geoid
end

"""
    get_east_of_utah_geoids() -> DataFrame

Returns GEOIDs for counties east of Utah's border (109°W longitude).
"""
function get_east_of_utah_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM counties
    WHERE ST_X(ST_Centroid(geom)) > $UTAH_BORDER
    ORDER BY lon;
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_slope_geoids() -> DataFrame

Returns GEOIDs for counties between 115°W and 120°W longitude.
"""
function get_slope_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) BETWEEN $SLOPE_WEST AND $SLOPE_EAST
    ORDER BY lon;
    """
    result = execute(conn, query)
    close(conn)
    DataFrame(result)
end

"""
    get_southern_kansas_geoids() -> DataFrame

Returns GEOIDs for Kansas counties south of Osage County.
"""
function get_southern_kansas_geoids()
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM counties WHERE geoid = '$OSAGE_COUNTY_KS'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_DWithin(c.geom, o.geom, 100000)
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    df = DataFrame(LibPQ.load!(DataFrame, conn, query))
    close(conn)
    return df
end

"""
    get_colorado_basin_geoids() -> Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()
    shapefile_path = joinpath(dirname(@__DIR__), "data", "Colorado_River_Basin_County_Boundaries")
    
    # Read the shapefile
    dataset = ArchGDAL.read(shapefile_path)
    
    # Extract GEOIDs from the feature layer
    layer = ArchGDAL.getlayer(dataset, 0)
    geoids = String[]
    
    for feature in layer
        # Assuming GEOID is a field in the shapefile
        # You might need to adjust the field name if it's different
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end
    
    ArchGDAL.destroy(dataset)
    sort(unique(geoids))
end


export get_western_geoids,
       get_eastern_geoids,
       get_east_of_utah_geoids,
       get_slope_geoids,
       get_southern_kansas_geoids,
       get_colorado_basin_geoids 

const western_geoids = get_western_geoids()
const eastern_geoids = get_eastern_geoids()
const east_of_utah_geoids = get_east_of_utah_geoids()
const slope_geoids = get_slope_geoids()
const southern_kansas_geoids = get_southern_kansas_geoids()
const colorado_basin_geoids = get_colorado_basin_geoids()

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

socal = ["06079", "06029", "06071", "06111", "06037",
         "06059", "06065", "06073", "06025", "06083",
         "06079","06029"]

# necal = ["06036", "06023", "06089", "06035", "06027",
#          "06103", "06121", "06007", "06063", "06033",
#          "06101", "06115", "06091", "06057", "06015",
#          "06051", "06003", "06061", "41011", "41015",
#          "41033", "41019", "41029", "41035", "06021",
#          "06105", "41037", "65015", "06093", "06049"]

east_of_sierras = ["06049","06035","06051","06051","06027"]

eastern_geoids = get_eastern_geoids()

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

rio_basin_tx  = ["48141","48229","48109","48243","48377",
                 "48301","48389","48371","48043","48443",
                 "48465","48105","48103","48475"]
rio_basin_nm  = ["35039","35056","35049","35028","35043",
                 "35001","35053","35013","35051","35061"]
rio_basin_co  = ["08023","08021","08105","08003","08109"]

mo_basin_ia = ["19119", "19143", "19167", "19141", "19077",
    "19149", "19047", "19035", "19151", "19041",
    "19193", "19071", "19173", "19021", "19093",
    "19161", "19133", "19145", "19085", "19165",
    "19009", "19155", "19029", "19129", "19137",
    "19003", "19059"]
mo_basin_ia = ["19071", "19129", "19155", "19085", "19133", "19193"]
mo_basin_mn = ["27117", "27133", "27195"]
mo_basin_mo = ["29005", "29087", "29147", "29003", "29021",
    "29165", "29047", "29049", "29063", "29075",
    "29177", "29025", "29061", "29081", "29041",
    "29089", "29175", "29121", "29001", "29197",
    "29027", "29007", "29137", "29205", "29227",
    "29019", "29139", "29163", "29173", "29127",
    "29111", "29045", "29183", "29189", "28510",
    "29027", "29129", "29079", "29117", "29033",
    "29171", "29211", "29115", "29199", "29103",
    "29510", "29219", "25215"]

ar_basin_mo   = ["29011","29145","29119","29109","29009",
    "29077","29043","29209","29113","29067",
    "29227","29997","29153","29091","29149",
    "29181","29213","29017","29123","29187",
    "29097"]

ms_basin_mo   = ["29071","29065","29099","29221","29093",
    "29179","29031","29223","29207","29069",
    "29155","29143","29133","29201","29017",
    "29179","29187","29123","29186",
    "29157"]

"""
Get Missouri counties that are north of St. Charles County and east of Schuyler County,
plus Schuyler and Adair counties. Returns a DataFrame with geoid and name of qualifying counties.
"""
function get_ne_missouri_counties()
    query = """
    WITH reference_counties AS (
        SELECT 
            geom as schuyler_geom,
            ST_XMin(geom) as schuyler_west
        FROM census.counties 
        WHERE name = 'Schuyler' AND stusps = 'MO'
    ),
    st_charles AS (
        SELECT ST_YMax(geom) as st_charles_north
        FROM census.counties 
        WHERE name = 'St. Charles' AND stusps = 'MO'
    )
    SELECT DISTINCT c.geoid, c.name
    FROM census.counties c, reference_counties r, st_charles s
    WHERE c.stusps = 'MO'
    AND (
        -- Include Schuyler and Adair counties regardless of position
        c.name IN ('Schuyler', 'Adair')
        OR (
            -- All other counties must be north of St. Charles and east of Schuyler
            ST_YMin(c.geom) > s.st_charles_north  -- North of St. Charles
            AND ST_XMin(c.geom) > r.schuyler_west  -- East of Schuyler
        )
    )
    ORDER BY c.name;
    """
    
    conn = get_db_connection()
    result = execute(conn, query)
    close(conn)
    
    DataFrame(result)
end

"""
Get Missouri counties that are south of Perry County's southern boundary,
excluding Vernon, Cedar, Polk, Dallas, Webster, Laclede, Wright, Texas, Dent and Iron counties.
Returns a vector of geoids.
"""
function get_southern_missouri_counties()
    query = """
    WITH perry_boundary AS (
        SELECT ST_YMin(ST_Envelope(geom)) as southern_boundary
        FROM census.counties 
        WHERE name = 'Perry' AND stusps = 'MO'
    )
    SELECT c.geoid, c.name
    FROM census.counties c, perry_boundary p
    WHERE c.stusps = 'MO'
    AND ST_Y(ST_Centroid(c.geom)) < p.southern_boundary
    AND c.name NOT IN ('Vernon', 'Cedar', 'Polk', 'Dallas', 'Webster', 
                      'Laclede', 'Wright', 'Texas', 'Dent', 'Iron', 
                      'Washington', 'St. Francois', 'St. Louis') 
    ORDER BY c.name;
    """
    
    conn = get_db_connection()
    result = execute(conn, query)
    close(conn)
    
    DataFrame(result).geoid
end 

function get_northern_missouri_counties()
    setdiff(get_geo_pop(["MO"]).geoid, get_southern_missouri_counties())
end

"""
Get Missouri River basin counties from Canadian border to Texas County's southern boundary.
Returns a DataFrame with geoid and name of qualifying counties.
"""
function get_missouri_river_basin_counties()
    query = """
    WITH texas_boundary AS (
        SELECT ST_YMin(ST_Transform(geom, 26915)) as southern_boundary
        FROM census.counties 
        WHERE name = 'Texas' AND stusps = 'MO'
    )
    SELECT DISTINCT c.geoid, c.name
    FROM census.counties c, texas_boundary t
    WHERE c.stusps IN ('MT', 'ND', 'SD', 'NE', 'IA', 'MO', 'KS')
    AND ST_YMin(ST_Transform(c.geom, 26915)) > t.southern_boundary  -- North of Texas County
    AND ST_Intersects(
        ST_Transform(c.geom, 26915),
        ST_Transform(
            ST_GeomFromText('POLYGON((-115.0 49.0, -90.0 49.0, -90.0 37.0, -115.0 37.0, -115.0 49.0))', 4326),
            26915
        )
    )  -- Within Missouri River basin extent
    ORDER BY c.name;
    """
    
    conn = get_db_connection()
    result = execute(conn, query)
    close(conn)
    
    DataFrame(result)
end

export get_ne_missouri_counties,
       get_southern_missouri_counties,
       get_northern_missouri_counties,
       get_missouri_river_basin_counties
