# confirm that this is not needed in core.jl
# SPDX-License-Identifier: MIT

# Directory paths
const PROJECT_ROOT = dirname(@__DIR__)  # Parent of scripts directory
const SCRIPTS_DIR = @__DIR__           # Current scripts directory
const OBJ_DIR = joinpath(PROJECT_ROOT, "obj")
const PARTIALS_DIR = joinpath(PROJECT_ROOT, "_layout", "partials")
const SRC_DIR = joinpath(PROJECT_ROOT, "src")
const DATA_DIR = joinpath(PROJECT_ROOT, "data")

# Database connection settings
const DB_HOST = "localhost"
const DB_PORT = 5432
const DB_NAME = "geocoder"

# Notable geographic IDs
const OSAGE_COUNTY_KS = "20167"  # Used as reference for Southern Kansas
const LOS_ANGELES_COUNTY = "06037"

# Geographic boundaries
const WESTERN_BOUNDARY = -115.0
const EASTERN_BOUNDARY = -90.0
const CONTINENTAL_DIVIDE = -109.5
const SLOPE_WEST = -120.0
const SLOPE_EAST = -115.0
const UTAH_BORDER = -109.0
const CENTRAL_MERIDIAN = -100.0

# Nation definitions
const concord = ["CT", "MA", "ME", "NH", "RI", "VT"]
const cumber = ["WV", "KY", "TN"]
const desert = ["UT", "MT", "WY", "CO", "ID"]
const dixie = ["NC", "SC", "FL", "GA", "MS", "AL"]
const factoria = ["PA", "OH", "MI", "IN", "IL", "WI"]
const heartland = ["MN", "IA", "NE", "ND", "SD", "KS", "MO"]
const lonestar = ["TX", "OK", "AR", "LA"]
const metropolis = ["DE", "MD", "NY", "NJ", "VA", "DC"]
const pacific = ["WA", "OR", "AK"]
const sonora = ["CA", "AZ", "NM", "NV", "HI"]

# Nation collections
const nations = [concord, cumber, desert, dixie, factoria, heartland, metropolis, pacific, sonora, lonestar]
const nat_names = ["concord", "cumber", "desert", "dixie", "factoria", "heartland", "metropolis", "pacifica", "sonora", "lonestar"]
const Titles = ["Concordia", "Cumberland", "Deseret", "New Dixie", "Factoria", "Heartlandia", "Metropolis", "Pacifica", "New Sonora", "The Lone Star Republic"]

# EU member states
const EU = ["Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden"]

# US state codes
const postals = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
const VALID_POSTAL_CODES = Set(postals)

# Color definitions
using Colors
const SALMON_PINK = "#fd7e7e"
const COTTON_CANDY = "#f8c8dc"
const SLATE_GREY = "#74909a"
const SKY_BLUE = "#a0ced9"
const SUNFLOWER_YELLOW = "#ffd700"
const SAGE_GREEN = RGB(0.196, 0.388, 0.075)
const FOREST_GREEN = RGB(0.196, 0.388, 0.075)
const BRIGHT_BLUE = RGB(0.282, 0.416, 0.698)
const LIGHT_GRAY = RGB(0.812, 0.812, 0.812)
const VIE_EN_ROSE = RGB(0.847, 0.749, 0.847)

# Map colors
const map_colors = [
    # VIE_EN_ROSE,
    # SALMON_PINK,
    # COTTON_CANDY,
    FOREST_GREEN,
    SAGE_GREEN,
    LIGHT_GRAY,
    SLATE_GREY,
    SKY_BLUE,
    BRIGHT_BLUE,
    SUNFLOWER_YELLOW,
    COTTON_CANDY
]


# Database connection - moved to a function to avoid precompilation issues
function get_db_connection()
    return LibPQ.Connection("dbname=geocoder")
end