# SPDX-License-Identifier: MIT

# Script to add MS_BASIN_MO GEOID set to GeoIDs module
# SCRIPT
the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
    include(the_path)

using GeoIDs, LibPQ, DataFrames

# Define counties east of Utah 
ms_basin_mo_counties = ["Bollinger","Butler","Cape Girardeau","Clark","Dunklin","Jefferson","Knox","Lewis","Lincoln","Madison","Marion","Mississippi","Monroe","New Madrid","Pemiscot","Perry","Pike","Ralls","Ripley","St. Charles","St. Louis","Ste. Genevieve","Scott","Stoddard","Warren"]
MO = subset(us, :stusps => ByRow(x -> x == "MO"))
ms_basin_mo = subset(MO, :county => ByRow(x -> x ∈ ms_basin_mo_counties)).geoid

# Convert to Vector{String} to match function signature
ms_basin_mo_string = String[string(x) for x in ms_basin_mo if !ismissing(x)]

# Check if set exists
existing_sets = GeoIDs.list_geoid_sets().set_name
if !("ms_basin_mo" in existing_sets)
    @info "Creating 'ms_basin_mo' geoid set..."
    GeoIDs.create_geoid_set(
        "ms_basin_mo",
        "Missouri counties in the Mississippi River Basin not in the Missouri Basin or the three basins in Arkansas",
        ms_basin_mo_string
    )
    @info "Created 'ms_basin_mo' geoid set with $(length(ms_basin_mo_string)) counties"
else
    @info "'ms_basin_mo' geoid set already exists"
    
    # Delete existing set and recreate
    @info "Recreating 'ms_basin_mo' geoid set..."
    db_conn = GeoIDs.DB.get_connection()
    
    # Delete existing set
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_set_members WHERE set_name = 'mo_basin_mn'")
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_sets WHERE set_name = 'mo_basin_mn'")
    LibPQ.close(db_conn)
    
    # Create new set
    GeoIDs.create_geoid_set(
        "mo_basin_mn",
        "Minnesota counties in the Missouri River Basin not in the Missouri Basin or the three basins in Arkansas",
        mo_basin_mn_string
    )
    @info "Recreated 'ms_basin_mo' geoid set with $(length(mo_basin_mo_string)) counties"
end

# Get the geoids from the database to verify
ms_basin_mo_geoids = GeoIDs.get_geoid_set("ms_basin_mo")
@info "Geoid set 'ms_basin_mo' has $(length(ms_basin_mo_geoids)) counties"

# Get county information and print
counties_query = """
SELECT geoid, name, stusps FROM census.counties 
WHERE geoid IN ($(join(map(g -> "'$g'", ms_basin_mo_geoids), ",")))
ORDER BY stusps, name
"""

db_conn = GeoIDs.DB.get_connection()
result = LibPQ.execute(db_conn, counties_query)
counties_df = DataFrame(result)
LibPQ.close(db_conn)

println("Missouri counties in the Mississippi River Basin:")
for row in eachrow(counties_df)
    println("  $(row.geoid): $(row.name), $(row.stusps)")
end

# Reload GeoIDs module constants to make the set available
#GeoIDs.load_predefined_geoids() 