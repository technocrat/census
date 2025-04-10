# SPDX-License-Identifier: MIT

# Constants for the Census package

"""
    VALID_POSTAL_CODES::Vector{String}

A vector containing all valid two-letter postal codes for U.S. states and the District of Columbia.
"""
const VALID_POSTAL_CODES = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
]

# Transrockies counties in Montana
const west_montana = ["30023", "30029", "30039", "30047", "30053",
                      "30061", "30063", "30081", "30089", "30093"]

# Define postals as an alias for VALID_POSTAL_CODES for backward compatibility
const postals = VALID_POSTAL_CODES

const VALID_STATE_NAMES = Dict(
    "AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas",
    "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware",
    "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho",
    "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas",
    "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland",
    "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi",
    "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada",
    "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York",
    "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma",
    "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina",
    "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah",
    "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia",
    "WI" => "Wisconsin", "WY" => "Wyoming", "DC" => "District of Columbia"
)

const VALID_STATE_CODES = Dict(
    "Alabama" => "AL", "Alaska" => "AK", "Arizona" => "AZ", "Arkansas" => "AR",
    "California" => "CA", "Colorado" => "CO", "Connecticut" => "CT", "Delaware" => "DE",
    "Florida" => "FL", "Georgia" => "GA", "Hawaii" => "HI", "Idaho" => "ID",
    "Illinois" => "IL", "Indiana" => "IN", "Iowa" => "IA", "Kansas" => "KS",
    "Kentucky" => "KY", "Louisiana" => "LA", "Maine" => "ME", "Maryland" => "MD",
    "Massachusetts" => "MA", "Michigan" => "MI", "Minnesota" => "MN", "Mississippi" => "MS",
    "Missouri" => "MO", "Montana" => "MT", "Nebraska" => "NE", "Nevada" => "NV",
    "New Hampshire" => "NH", "New Jersey" => "NJ", "New Mexico" => "NM", "New York" => "NY",
    "North Carolina" => "NC", "North Dakota" => "ND", "Ohio" => "OH", "Oklahoma" => "OK",
    "Oregon" => "OR", "Pennsylvania" => "PA", "Rhode Island" => "RI", "South Carolina" => "SC",
    "South Dakota" => "SD", "Tennessee" => "TN", "Texas" => "TX", "Utah" => "UT",
    "Vermont" => "VT", "Virginia" => "VA", "Washington" => "WA", "West Virginia" => "WV",
    "Wisconsin" => "WI", "Wyoming" => "WY", "District of Columbia" => "DC"
)

# Nation state mappings
const NATION_ABBREVIATIONS = Dict(
    "cumber" => "Cumberland",
    "dixie" => "New Dixie",
    "lonestar" => "The Lone Star Republic",
    "metropolis" => "Metropolis",
    "heartland" => "Heartlandia",
    "factoria" => "Factoria",
    "desert" => "Deseret",
    "sonora" => "New Sonora",
    "concord" => "Concordia",
    "pacifica" => "Pacifica"
)

# Nation state definitions
const NATION_STATES = Dict(
    "concord" => ["CT", "MA", "ME", "NH", "RI", "VT"],
    "cumber" => ["WV", "KY", "TN"],
    "desert" => ["UT", "MT", "WY", "CO", "ID"],
    "dixie" => ["NC", "SC", "FL", "GA", "MS", "AL"],
    "factoria" => ["PA", "OH", "MI", "IN", "IL", "WI"],
    "heartland" => ["MN", "IA", "NE", "ND", "SD", "KS", "MO"],
    "lonestar" => ["TX", "OK", "AR", "LA"],
    "metropolis" => ["DE", "MD", "NY", "NJ", "VA", "DC"],
    "pacific" => ["WA", "OR", "AK"],
    "sonora" => ["CA", "AZ", "NM", "NV", "HI"]
)

# Geographic constants
const WESTERN_BOUNDARY = -100.0
const EASTERN_BOUNDARY = -90.0
const UTAH_EASTERN_BOUNDARY = -111.047
const CASCADE_BOUNDARY = -121.0


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
    FOREST_GREEN,
    SAGE_GREEN,
    LIGHT_GRAY,
    SLATE_GREY,
    SKY_BLUE,
    BRIGHT_BLUE,
    SUNFLOWER_YELLOW,
    COTTON_CANDY
]

"""
    CensusQuery

A structure representing a query to the Census API.

# Fields
- `year::Int`: The census year to query
- `acs_period::String`: The ACS period (e.g., "1" for 1-year estimates, "5" for 5-year estimates)
- `variables::Vector{String}`: Census variable codes to retrieve
- `geography::String`: Geographic level for the query (e.g., "state", "county")
- `api_key::String`: Census API key for authentication
"""
struct CensusQuery
    year::Int
    acs_period::String
    variables::Vector{String}
    geography::String
    api_key::String
end

"""
    PostalCode

A type representing a valid U.S. postal code.

# Fields
- `code::String`: A two-letter postal code

# Constructor
    PostalCode(code::AbstractString)

Creates a new `PostalCode` instance. Throws an `ArgumentError` if the code is not valid.

# Examples
```julia
julia> pc = PostalCode("CA")
CA

julia> pc = PostalCode("XX")  # Throws ArgumentError
ERROR: ArgumentError: Invalid postal code: XX. Must be one of the 51 valid US postal codes.
```
"""
struct PostalCode
    code::String 
    function PostalCode(code::AbstractString)
        uppercase_code = uppercase(code)
        if uppercase_code ∉ VALID_POSTAL_CODES
            throw(ArgumentError("Invalid postal code: $(code). Must be one of the 51 valid US postal codes."))
        end
        new(uppercase_code)
    end
end

# Base method extensions for PostalCode
Base.string(pc::PostalCode) = pc.code
Base.show(io::IO, pc::PostalCode) = print(io, pc.code)
Base.:(==)(a::PostalCode, b::PostalCode) = a.code == b.code
Base.hash(pc::PostalCode, h::UInt) = hash(pc.code, h)

"""
    MS_EAST_LA_GEOIDS::Vector{String}

GEOIDs for Louisiana parishes east of the Mississippi River.
"""
const MS_EAST_LA_GEOIDS = ["22125","22091","22058","22117","22033",
                          "22063","22103","22093","22095","22029",
                          "22051","22075","22087","22037","22105",
                          "22071","22089"]

"""
    OHIO_BASIN_MD_GEOIDS::Vector{String}

GEOIDs for Maryland counties in the Ohio River Basin: Washington, Allegany, and Garrett.
"""
const OHIO_BASIN_MD_GEOIDS = ["24043", "24001", "24023"]

"""
    US_POSTALS

Vector of all US state postal codes, including territories.
"""
const US_POSTALS = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
    "DC", "PR", "VI", "GU", "AS", "MP"
] 

"""
    OHIO_BASIN_AL_GEOIDS::Vector{String}

GEOIDs for Alabama counties in the Ohio River Basin.
"""
const OHIO_BASIN_AL_GEOIDS = ["01077","01083","01089","01033",
                             "01059","01079","01103","01071","01049","01195"]

"""
    OHIO_BASIN_MS_GEOIDS::Vector{String}

GEOIDs for Mississippi counties in the Ohio River Basin.
"""
const OHIO_BASIN_MS_GEOIDS = ["28141"]

"""
    OHIO_BASIN_NC_GEOIDS::Vector{String}

GEOIDs for North Carolina counties in the Ohio River Basin.
"""
const OHIO_BASIN_NC_GEOIDS = ["37039","37043","37075","37113","37087","37099",
                             "37115","37021","37011","37009","37005","37173",
                             "37189","37121","37199","37089"]

"""
    OHIO_BASIN_VA_GEOIDS::Vector{String}

GEOIDs for Virginia counties in the Ohio River Basin.
"""
const OHIO_BASIN_VA_GEOIDS = ["51105","51169","51195","51120","51051",
                             "51027","51167","51191","51070","51021",
                             "51071","51155","51035","51197","51173",
                             "51077","51185","51750","51640","51520",
                             "51720"]

"""
    OHIO_BASIN_GA_GEOIDS::Vector{String}

GEOIDs for Georgia counties in the Ohio River Basin.
"""
const OHIO_BASIN_GA_GEOIDS = ["13295","13111","13291","13241","13083"]

"""
    OHIO_BASIN_PA_GEOIDS::Vector{String}

GEOIDs for Pennsylvania counties in the Ohio River Basin.
"""
const OHIO_BASIN_PA_GEOIDS = ["42039","42085","42073","42007","42125","42059",
                             "42123","42083","42121","42053","42047","42033",
                             "42021","42411","42065","42129","42051","42031",
                             "42005","42003","42019","42063","42111"]

"""
    OHIO_BASIN_NY_GEOIDS::Vector{String}

GEOIDs for New York counties in the Ohio River Basin.
"""
const OHIO_BASIN_NY_GEOIDS = ["36003", "36009", "36011", "36013", "36014", 
                             "36015", "36019", "36029", "36031", "36033", 
                             "36037", "36041", "36043", "36045", "36049", 
                             "36051", "36055", "36063", "36065", "36067", 
                             "36069", "36073", "36075", "36089", "36097", 
                             "36099", "36101", "36107", "36109", "36117", 
                             "36121", "36123"]

"""
    MISS_BASIN_KY_GEOIDS::Vector{String}

GEOIDs for Kentucky counties in the Mississippi River Basin.
"""
const MISS_BASIN_KY_GEOIDS = ["21007","21145","21007"]

"""
    MISS_BASIN_TN_GEOIDS::Vector{String}

GEOIDs for Tennessee counties in the Mississippi River Basin.
"""
const MISS_BASIN_TN_GEOIDS = ["47095","47131","47069","47079","47045","47053",
                             "47017","47097","47033","47113","47077","47023",
                             "47157","47047","47109","47183","47075","47166",
                             "47167"]

"""
    HUDSON_BAY_DRAINAGE_GEOIDS::Vector{String}

GEOIDs for North Dakota and Minnesota counties that drain into Hudson Bay via the Red River
and its tributaries.
"""
const HUDSON_BAY_DRAINAGE_GEOIDS = [
    # North Dakota counties
    "38067",  # Pembina County
    "38019",  # Cavalier County
    "38099",  # Walsh County
    "38071",  # Ramsey County
    "38063",  # Nelson County
    "38035",  # Grand Forks County
    "38097",  # Traill County
    "38091",  # Steele County
    "38017",  # Cass County
    "38077",  # Richland County
    "38081",  # Sargent County
    "38073",  # Ransom County
    "38003",  # Barnes County
    "38039",  # Griggs County
    "38027",  # Eddy County
    "38005",  # Benson County
    "38095",  # Towner County
    
    # Minnesota counties
    "27069",  # Kittson County
    "27135",  # Roseau County
    "27077",  # Lake of the Woods County
    "27071",  # Koochiching County
    "27089",  # Marshall County
    "27113",  # Pennington County
    "27125",  # Red Lake County
    "27119",  # Polk County
    "27107",  # Norman County
    "27087",  # Mahnomen County
    "27027",  # Clay County
    "27029",  # Clearwater County
    "27007",  # Beltrami County
    "27167"   # Wilkin County
]

"""
    OHIO_BASIN_DIXIE_GEOIDS::Vector{String}

Combined GEOIDs for all Dixie region counties in the Ohio River Basin, including counties from Alabama, 
Mississippi, North Carolina, Virginia, and Georgia.
"""
const OHIO_BASIN_DIXIE_GEOIDS = vcat(
    OHIO_BASIN_AL_GEOIDS,
    OHIO_BASIN_MS_GEOIDS,
    OHIO_BASIN_NC_GEOIDS,
    OHIO_BASIN_VA_GEOIDS,
    OHIO_BASIN_GA_GEOIDS
)

"""
    MISS_RIVER_BASIN_SD::Vector{String}

GEOIDs for South Dakota counties in the Mississippi River Basin.
"""
const MISS_RIVER_BASIN_SD = [
    "46109",  # Roberts County
    "46051",  # Grant County
    "46039"   # Deuel County
]

# Nation definitions
const CONCORD = ["CT","MA","ME","NH","RI","VT"]
const METROPOLIS = ["DE", "MD","NY","NJ","VA","DC"]
const FACTORIA = ["PA", "OH", "MI", "IN", "IL", "WI"]
const LONESTAR = ["TX","OK","AR","LA"]
const DIXIE = ["NC", "SC", "FL", "GA","MS","AL"]
const CUMBER = ["WV","KY","TN"]
const HEARTLAND = ["MN","IA","NE", "ND", "SD", "KS", "MO"]
const DESERT = ["UT","MT","WY", "CO", "ID"]
const PACIFIC = ["WA","OR","AK"]
const SONORA = ["CA","AZ","NM","NV","HI"]

const NATIONS = ["concord","metropolis","factoria","lonestar","dixie","cumber","heartland", "desert","pacific","sonora"]
const NATION_LISTS = [CONCORD, METROPOLIS, FACTORIA, LONESTAR, DIXIE, CUMBER, HEARTLAND, DESERT, PACIFIC, SONORA]
const TITLES = NATIONS  # For now, using the same names as titles

"""
    SOCAL_GEOIDS::Vector{String}

GEOIDs for Southern California counties including Imperial, Kern, Los Angeles, Orange, Riverside, 
San Bernardino, San Diego, San Luis Obispo, Santa Barbara, and Ventura counties.
"""
const SOCAL_GEOIDS::Vector{String} = [
    "06025",  # Imperial County
    "06029",  # Kern County
    "06037",  # Los Angeles County
    "06059",  # Orange County
    "06065",  # Riverside County
    "06071",  # San Bernardino County
    "06073",  # San Diego County
    "06079",  # San Luis Obispo County
    "06083",  # Santa Barbara County
    "06111"   # Ventura County
]

"""
    NORTHERN_VA_GEOIDS::Vector{String}

GEOIDs for counties in Northern Virginia, including areas surrounding Washington D.C.
Counties include Prince William, Loudoun, Fairfax, Arlington, Alexandria, and others in the region.
"""
const NORTHERN_VA_GEOIDS::Vector{String} = [
    "51131", # Northampton County
    "51103", # Lancaster County
    "51133", # Northumberland County
    "51099", # King George County
    "51159", # Richmond County
    "51630", # Fredericksburg city
    "51179", # Stafford County
    "51153", # Prince William County
    "51683", # Manassas city
    "51685", # Manassas Park city
    "51059", # Fairfax County
    "51600", # Fairfax city
    "51510", # Alexandria city
    "51107", # Loudoun County
    "51043", # Clarke County
    "51840", # Winchester city
    "51069", # Frederick County
    "51013", # Arlington County
    "51001", # Accomack County
    "51193", # Westmoreland County
    "51061"  # Fauquier County
]

