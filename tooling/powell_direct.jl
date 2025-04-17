#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Use direct database connections to avoid precompilation issues
using LibPQ
using DataFrames
using CairoMakie
using GeoMakie
using ArchGDAL
using GeometryBasics
using Dates

println("Getting Powell nation state data directly from database...")
conn = LibPQ.Connection("dbname=tiger")

# Get west_of_100th geoids
println("Getting west_of_100th geoids...")
query = """
SELECT gsm.geoid
FROM census.geoid_set_members gsm
JOIN census.geoid_sets gs ON gsm.set_name = gs.set_name AND gsm.version = gs.version
WHERE gs.set_name = 'west_of_100th' AND gs.is_current = TRUE
ORDER BY gsm.geoid;
"""
result = LibPQ.execute(conn, query)
west_of_100th = DataFrame(result).geoid
println("Found $(length(west_of_100th)) counties in west_of_100th")

# Get colorado_basin geoids
println("Getting colorado_basin geoids...")
query = """
SELECT gsm.geoid
FROM census.geoid_set_members gsm
JOIN census.geoid_sets gs ON gsm.set_name = gs.set_name AND gsm.version = gs.version
WHERE gs.set_name = 'colorado_basin' AND gs.is_current = TRUE
ORDER BY gsm.geoid;
"""
result = LibPQ.execute(conn, query)
colorado_basin = DataFrame(result).geoid
println("Found $(length(colorado_basin)) counties in colorado_basin")

# Get east_of_cascades geoids
println("Getting east_of_cascades geoids...")
query = """
SELECT gsm.geoid
FROM census.geoid_set_members gsm
JOIN census.geoid_sets gs ON gsm.set_name = gs.set_name AND gsm.version = gs.version
WHERE gs.set_name = 'east_of_cascades' AND gs.is_current = TRUE
ORDER BY gsm.geoid;
"""
result = LibPQ.execute(conn, query)
east_of_cascades = DataFrame(result).geoid
println("Found $(length(east_of_cascades)) counties in east_of_cascades")

# Get the basic data for all counties
println("Getting county data...")
query = """
SELECT c.geoid, c.stusps, c.name as county, ST_AsText(c.geom) as geom, vd.value as pop
FROM census.counties c
LEFT JOIN census.variable_data vd ON c.geoid = vd.geoid AND vd.variable_name = 'total_population'
ORDER BY c.geoid;
"""
result = LibPQ.execute(conn, query)
us = DataFrame(result)
println("Found $(nrow(us)) counties in the database")

# Filter counties for Powell
println("Filtering counties for Powell...")

# Filter by states and sets
az = filter(row -> row.stusps == "AZ" && row.geoid ∈ colorado_basin, us)
nm = filter(row -> row.stusps == "NM", us)
mt = filter(row -> row.stusps == "MT" && row.geoid ∈ colorado_basin, us)
co = filter(row -> row.stusps == "CO", us)
wy = filter(row -> row.stusps == "WY" && row.geoid ∈ colorado_basin, us)
ks = filter(row -> row.stusps == "KS" && row.geoid ∈ west_of_100th, us)
ne = filter(row -> row.stusps == "NE" && row.geoid ∈ west_of_100th, us)
nd = filter(row -> row.stusps == "ND" && row.geoid ∈ west_of_100th, us)
sd = filter(row -> row.stusps == "SD" && row.geoid ∈ west_of_100th, us)
ok = filter(row -> row.stusps == "OK" && row.geoid ∈ west_of_100th, us)
tx = filter(row -> row.stusps == "TX" && row.geoid ∈ west_of_100th, us)
ut = filter(row -> row.stusps == "UT" && row.geoid ∈ ["49037","49019"], us)
wa = filter(row -> row.stusps == "WA" && row.geoid ∈ east_of_cascades, us)

# Combine all the filtered counties
powell_counties = vcat(mt, nm, wy, az, co, az, nd, sd, ne, ks, tx, ok, ut, wa)
println("Powell nation state has $(nrow(powell_counties)) counties")

# Create a map
println("Creating map...")

# Powell projection string
powell_crs = "+proj=aea +lat_0=37.5 +lon_0=-105 +lat_1=29.5 +lat_2=45.5 +datum=NAD83 +units=m +no_defs"

# Parse the geometries
parse_geom(geom_text) = try
    ArchGDAL.fromWKT(geom_text)
catch e
    @warn "Failed to parse geometry" exception=e
    missing
end

# Function to convert ArchGDAL geometry to GeometryBasics.Polygon
function convert_to_polygon(geom)
    if ismissing(geom)
        return missing
    end
    
    try
        geomtype = ArchGDAL.getgeomtype(geom)
        
        if geomtype == ArchGDAL.wkbMultiPolygon
            # For MultiPolygon, take the first polygon
            return convert_to_polygon(ArchGDAL.getgeom(geom, 0))
        elseif geomtype == ArchGDAL.wkbPolygon || geomtype == ArchGDAL.wkbUnknown
            # For Polygon or Unknown, try to get the exterior ring
            ring = ArchGDAL.getgeom(geom, 0)  # First ring is exterior
            points = [Point2f(ArchGDAL.getx(ArchGDAL.getpoint(ring, i)), 
                              ArchGDAL.gety(ArchGDAL.getpoint(ring, i))) 
                     for i in 0:(ArchGDAL.ngeom(ring)-1)]
            return GeometryBasics.Polygon(points)
        else
            @warn "Unsupported geometry type: $geomtype"
            return missing
        end
    catch e
        @warn "Failed to convert geometry to polygon" exception=e
        return missing
    end
end

# Parse the geometries
powell_counties.parsed_geom = map(parse_geom, powell_counties.geom)
powell_counties.polygon = map(convert_to_polygon, powell_counties.parsed_geom)

# Create a simple plot function
function create_map(df, title, crs_string)
    fig = Figure(size=(2400, 1600), fontsize=22)
    
    # Create geographical axis with the specified CRS
    ax = GeoAxis(
        fig[1, 1],
        dest = crs_string,
        title = title
    )
    
    # Plot each polygon
    for (i, row) in enumerate(eachrow(df))
        if !ismissing(row.polygon)
            poly!(ax, [row.polygon], color = :blue, strokewidth = 1, 
                 strokecolor = :black, transparency = true, alpha = 0.7)
        end
    end
    
    return fig
end

# Create the map
powell_map = create_map(powell_counties, "Powell", powell_crs)

# Save the figure
img_dir = joinpath(@__DIR__, "img")
if !isdir(img_dir)
    mkdir(img_dir)
end

save_path = joinpath(img_dir, "Powell_direct_$(Dates.format(now(), "yyyymmdd_HHMMSS")).png")
println("Saving map to: $save_path")
save(save_path, powell_map)

# Display confirmation
if isfile(save_path)
    println("Map successfully saved to: $save_path")
else
    println("Failed to save map to: $save_path")
end

# Store Powell geoids for later use
println("Storing Powell geoids in database...")
geoids_list = powell_counties.geoid

# Check if "Powell" nation state exists in counties table
query = """
SELECT COUNT(*) FROM census.counties WHERE nation_state = 'Powell'
"""
result = LibPQ.execute(conn, query)
count = result[1,1]

if count > 0
    # Update existing records
    println("Updating existing Powell nation state records...")
    LibPQ.execute(conn, "BEGIN;")
    
    try
        # Clear existing Powell assignments
        LibPQ.execute(conn, "UPDATE census.counties SET nation_state = NULL WHERE nation_state = 'Powell';")
        
        # Set nation_state to Powell for selected counties
        for geoid in geoids_list
            LibPQ.execute(conn, "UPDATE census.counties SET nation_state = 'Powell' WHERE geoid = '$geoid';")
        end
        
        LibPQ.execute(conn, "COMMIT;")
        println("Successfully updated Powell nation state with $(length(geoids_list)) counties")
    catch e
        LibPQ.execute(conn, "ROLLBACK;")
        println("Error updating Powell nation state: $e")
    end
else
    # First time creating Powell
    println("Creating new Powell nation state...")
    LibPQ.execute(conn, "BEGIN;")
    
    try
        # Set nation_state to Powell for selected counties
        for geoid in geoids_list
            LibPQ.execute(conn, "UPDATE census.counties SET nation_state = 'Powell' WHERE geoid = '$geoid';")
        end
        
        LibPQ.execute(conn, "COMMIT;")
        println("Successfully created Powell nation state with $(length(geoids_list)) counties")
    catch e
        LibPQ.execute(conn, "ROLLBACK;")
        println("Error creating Powell nation state: $e")
    end
end

println("Powell nation state has been updated with the expanded west_of_100th counties (including those with centroids between -110°W and -115°W)")
println("These changes are now saved in the database.")

LibPQ.close(conn)
println("Done!") 