# SPDX-License-Identifier: MIT
# Script to add EAST_OF_UTAH GEOID set to GeoIDs module
# SCRIPT

using Pkg
Pkg.activate(dirname(@__DIR__)) # Activate main project

using GeoIDs, LibPQ, DataFrames

# Define counties east of Utah 
EAST_OF_UTAH_COUNTIES = [
    # Montana counties bordering Wyoming
    "30003",  # Big Horn County, MT
    "30009",  # Carbon County, MT
    "30111",  # Yellowstone County, MT 
    "30075",  # Powder River County, MT
    "30025",  # Custer County, MT
    "30011",  # Carter County, MT
    # Wyoming counties east of Bighorn Basin
    "56019",  # Johnson County, WY
    "56033",  # Sheridan County, WY
    "56005",  # Campbell County, WY
    "56015",  # Crook County, WY
    "56045",  # Weston County, WY
    "56027",  # Niobrara County, WY
    "56009",  # Converse County, WY
    "56031",  # Platte County, WY
    "56021",  # Laramie County, WY
    "56025",  # Natrona County, WY
    "56001",  # Albany County, WY
    # Colorado counties east of the Continental Divide
    "08069",  # Larimer County, CO
    "08123",  # Weld County, CO
    "08001",  # Adams County, CO
    "08031",  # Denver County, CO
    "08005",  # Arapahoe County, CO
    "08035",  # Douglas County, CO
    "08039",  # Elbert County, CO
    "08041",  # El Paso County, CO
    "08109",  # Saguache County, CO (partial east of divide)
    "08099",  # Prowers County, CO
]

# Check if set exists
existing_sets = GeoIDs.list_geoid_sets().set_name
if !("east_of_utah" in existing_sets)
    @info "Creating 'east_of_utah' geoid set..."
    GeoIDs.create_geoid_set(
        "east_of_utah",
        "Counties east of Utah in Montana, Wyoming, and Colorado",
        EAST_OF_UTAH_COUNTIES
    )
    @info "Created 'east_of_utah' geoid set with $(length(EAST_OF_UTAH_COUNTIES)) counties"
else
    @info "'east_of_utah' geoid set already exists"
    
    # Delete existing set and recreate
    @info "Recreating 'east_of_utah' geoid set..."
    db_conn = GeoIDs.DB.get_connection()
    
    # Delete existing set
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_set_members WHERE set_name = 'east_of_utah'")
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_sets WHERE set_name = 'east_of_utah'")
    LibPQ.close(db_conn)
    
    # Create new set
    GeoIDs.create_geoid_set(
        "east_of_utah",
        "Counties east of Utah in Montana, Wyoming, and Colorado",
        EAST_OF_UTAH_COUNTIES
    )
    @info "Recreated 'east_of_utah' geoid set with $(length(EAST_OF_UTAH_COUNTIES)) counties"
end

# Get the geoids from the database to verify
east_of_utah_geoids = GeoIDs.get_geoid_set("east_of_utah")
@info "Geoid set 'east_of_utah' has $(length(east_of_utah_geoids)) counties"

# Get county information and print
counties_query = """
SELECT geoid, name, stusps FROM census.counties 
WHERE geoid IN ($(join(map(g -> "'$g'", east_of_utah_geoids), ",")))
ORDER BY stusps, name
"""

db_conn = GeoIDs.DB.get_connection()
result = LibPQ.execute(db_conn, counties_query)
counties_df = DataFrame(result)
LibPQ.close(db_conn)

println("Counties east of Utah:")
for row in eachrow(counties_df)
    println("  $(row.geoid): $(row.name), $(row.stusps)")
end

# Reload GeoIDs module constants to make the set available
GeoIDs.load_predefined_geoids() 