# SPDX-License-Identifier: MIT
# Script to update the GeoIDs module to include the NORTHERN_VA_GEOIDS constant
# SCRIPT

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, DataFrames, LibPQ

@info "Updating GeoIDs module to include NORTHERN_VA_GEOIDS"

# Check if the set exists in the database
conn = LibPQ.Connection("dbname=tiger")
check_query = "SELECT COUNT(*) FROM census.geoid_sets WHERE set_name = 'northern_va'"
result = LibPQ.execute(conn, check_query)
set_exists = DataFrame(result)[1, 1] > 0
LibPQ.close(conn)

if !set_exists
    @error "The 'northern_va' set doesn't exist in the database yet. Run add_northern_va_to_geoids.jl first."
    exit(1)
end

# Update the GEOID_MAPPING in migrate_geoids_to_module.jl
geoids_script_path = joinpath(@__DIR__, "migrate_geoids_to_module.jl")

if !isfile(geoids_script_path)
    @error "Could not find migrate_geoids_to_module.jl script at $geoids_script_path"
    exit(1)
end

# Read the file content
file_content = read(geoids_script_path, String)

# Check if NORTHERN_VA_GEOIDS is already in the mapping
if !occursin("\"NORTHERN_VA_GEOIDS\" =>", file_content)
    # Find the position to insert our new entry
    # Look for the last entry before the closing parenthesis
    last_entry_pos = findlast("\"", file_content)
    if last_entry_pos === nothing
        @error "Could not find a suitable position to insert the new entry"
        exit(1)
    end
    
    # Find the next closing parenthesis after the last entry
    closing_paren_pos = findnext(")", file_content, last_entry_pos.stop)
    if closing_paren_pos === nothing
        @error "Could not find the closing parenthesis of the dictionary"
        exit(1)
    end
    
    # Find the last comma before the closing parenthesis
    last_comma_pos = findprev(",", file_content, closing_paren_pos.start)
    if last_comma_pos === nothing
        @error "Could not find the last comma in the dictionary"
        exit(1)
    end
    
    # Prepare our new entry
    new_entry = "\n    \"NORTHERN_VA_GEOIDS\" => \"northern_va\","
    
    # Insert the new entry before the closing parenthesis
    new_file_content = file_content[1:last_comma_pos.stop] * new_entry * file_content[last_comma_pos.stop+1:end]
    
    # Write back to the file
    write(geoids_script_path, new_file_content)
    
    @info "Updated GEOID_MAPPING in $geoids_script_path to include NORTHERN_VA_GEOIDS"
else
    @info "NORTHERN_VA_GEOIDS is already in the GEOID_MAPPING dictionary"
end

@info "To use the northern_va GEOID set, you need to:"
@info "1. Ensure Census.NORTHERN_VA_GEOIDS is being exported"
@info "2. Run the migrate_geoids_to_module.jl script to update the GeoIDs module constants"
@info "3. Add 'const NORTHERN_VA_GEOIDS = String[]' to the GeoIDs.jl module if not already there"
@info "4. Run GeoIDs.initialize_predefined_geoid_sets() to load the geoids from the database" 