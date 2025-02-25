# don't use as is'
# using HTTP: Connections
include("libr.jl")
include("func.jl")

const STATES = ["MA", "CT", "NH", "RI", "VT", "ME"]
const TIERS = ["Very Low", "Low", "Medium", "High", "Very High"]
const COLORS = ["#4682b4", "#d8bfd8", "#e6e9fa", "#f0e68c", "#a8c3bc",
    "#ffdab9", "#b5d0e3", "#838996"]
const NATIONS = ["Concordia"]

nation = NATIONS[1]

# Define named color constants
const SALMON_PINK = "#fd7e7e"
const COTTON_CANDY = "#f8c8dc"
const SLATE_GREY = "#74909a"
const SKY_BLUE = "#a0ced9"
const SAGE_GREEN = "#b6d1ba"

# Create a mapping of tiers to colors that's easy to modify
const TIER_COLORS = Dict(
    "Very Low" => SALMON_PINK,
    "Low" => COTTON_CANDY,
    "Medium" => SLATE_GREY,
    "High" => SKY_BLUE,
    "Very High" => SAGE_GREEN
)

# Generate colorscale in the order of TIERS
const COLORSCALE = [
    [0.00, TIER_COLORS[TIERS[2]]],
    [0.25, TIER_COLORS[TIERS[1]]],
    [0.50, TIER_COLORS[TIERS[3]]],
    [0.75, TIER_COLORS[TIERS[4]]],
    [1.00, TIER_COLORS[TIERS[5]]]
]

# First, let's get the joined data directly from postgres
query = """
    SELECT ne.geoid, ne.stusps, ne.name, ST_AsGeoJSON(ne.geom) as json_geom, vd.value as total_population
    FROM census.counties ne
    LEFT JOIN census.variable_data vd
        ON ne.geoid = vd.geoid
        AND vd.variable_name = 'total_population'
    WHERE ne.stusps IN ('ME', 'NH', 'VT', 'MA', 'RI', 'CT')
"""

# Assuming you're using LibPQ.jl

conn = LibPQ.Connection("dbname=geocoder user=geo")
result = execute(conn, query)
ne_pop = DataFrame(result)
close(conn)
# Convert JSON geometry strings to GeoJSON geometries
# no geometries = GeoJSON.MultiPolygon.(JSON3.read.(ne_pop.json_geom))
# no geometries = GeoJSON.MultiPolygon.(joined_data.json_geom))
geometries = JSON3.read.(joined_data.json_geom)

# Convert population values to Float64
populations = log.(Float64.(ne_pop.total_population))

fig = Figure(size=(1200, 800), fontsize=22)
ga = GeoAxis(
    fig[1:2, 1:4],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County Populations",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

poly!(
    ga, geometries;
    color=populations,
    colormap=:viridis,
    strokecolor=(:black, 0.5),  # Added transparency to stroke
    strokewidth=1
)

Colorbar(fig[1:2, 5], label="Population")

fig

query = 
"""
WITH age_totals AS (
    SELECT 
        CASE 
            WHEN v.variable_name LIKE '%under_5_years' THEN 'Under 5 years'
            WHEN v.variable_name LIKE '%5_to_9_years' THEN '5 to 9 years'
            WHEN v.variable_name LIKE '%10_to_14_years' THEN '10 to 14 years'
            WHEN v.variable_name IN ('male_15_to_17_years', 'male_18_and_19_years', 'female_15_to_17_years', 'female_18_and_19_years') THEN '15 to 19 years'
            WHEN v.variable_name IN ('male_20_years', 'male_21_years', 'male_22_to_24_years', 'female_20_years', 'female_21_years', 'female_22_to_24_years') THEN '20 to 24 years'
            WHEN v.variable_name LIKE '%25_to_29_years' THEN '25 to 29 years'
            WHEN v.variable_name LIKE '%30_to_34_years' THEN '30 to 34 years'
            WHEN v.variable_name LIKE '%35_to_39_years' THEN '35 to 39 years'
            WHEN v.variable_name LIKE '%40_to_44_years' THEN '40 to 44 years'
            WHEN v.variable_name LIKE '%45_to_49_years' THEN '45 to 49 years'
            WHEN v.variable_name LIKE '%50_to_54_years' THEN '50 to 54 years'
            WHEN v.variable_name LIKE '%55_to_59_years' THEN '55 to 59 years'
            WHEN v.variable_name IN ('male_60_and_61_years', 'male_62_to_64_years', 'female_60_and_61_years', 'female_62_to_64_years') THEN '60 to 64 years'
            WHEN v.variable_name IN ('male_65_and_66_years', 'male_67_to_69_years', 'female_65_and_66_years', 'female_67_to_69_years') THEN '65 to 69 years'
            WHEN v.variable_name LIKE '%70_to_74_years' THEN '70 to 74 years'
            WHEN v.variable_name LIKE '%75_to_79_years' THEN '75 to 79 years'
            WHEN v.variable_name LIKE '%80_to_84_years' THEN '80 to 84 years'
            WHEN v.variable_name LIKE '%85_years_and_over' THEN '85 years and over'
        END as age_group,
        CASE WHEN v.variable_name LIKE 'male%' THEN 'M' ELSE 'F' END as gender,
        SUM(v.value) as total
    FROM census.counties c
    JOIN census.variable_data v ON c.geoid = v.geoid
    WHERE c.stusps IN ('ME', 'NH', 'VT', 'MA', 'RI', 'CT')
    AND v.variable_name != 'total_population'
    GROUP BY age_group, gender
)
SELECT 
    age_group,
    SUM(CASE WHEN gender = 'M' THEN total END) as male,
    SUM(CASE WHEN gender = 'F' THEN total END) as female
FROM age_totals
WHERE age_group IS NOT NULL
GROUP BY age_group
ORDER BY 
    CASE 
        WHEN age_group = 'Under 5 years' THEN 1
        WHEN age_group = '85 years and over' THEN 99
        ELSE CAST(SPLIT_PART(age_group, ' ', 1) AS INTEGER)
    END;
    """
    
    
conn = LibPQ.Connection("dbname=geocoder user=geo")
result = execute(conn, query)
df = DataFrame(result)
close(conn)