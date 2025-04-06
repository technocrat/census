# SPDX-License-Identifier: MIT

using LibPQ
using DataFrames
using ArchGDAL
using ..CensusDB: execute

# Import CensusDB module instead of get_db_connection
import ..Census.CensusDB

# Functions for retrieving GEOIDs from the database
# These functions are used to populate the constants in constants.jl

"""
    get_western_geoids() -> Vector{String}

Returns GEOIDs for counties west of 100°W longitude and east of 115°W longitude
to get the high plains counties with historically low rainfall
(< 20 inches per year) requiring irrigation.
Also includes the Oklahoma panhandle counties (Cimarron, Beaver, and Texas).
"""
function get_western_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE ST_X(ST_Centroid(geom)) < -100.0
        OR geoid IN ('40025', '40007', '40139')  -- Cimarron, Beaver, Texas counties
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_eastern_geoids() -> Vector{String}

Returns GEOIDs for counties between 90°W and 100°W longitude
to get the eastern counties with historically high rainfall 
(> 20 inches per year) not requiring irrigation.
Excludes the Oklahoma panhandle counties (Cimarron, Beaver, and Texas).
"""
function get_eastern_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE ST_X(ST_Centroid(geom)) > -100
        AND ST_X(ST_Centroid(geom)) < -90
        AND geoid NOT IN ('40025', '40007', '40139')  -- Exclude Cimarron, Beaver, Texas counties
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_colorado_basin_geoids()::Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()::Vector{String}
    # Get the path to the shapefile using absolute path from project root
    project_root = dirname(dirname(@__DIR__))
    shapefile_path = joinpath(project_root, "data", "Colorado_River_Basin_County_Boundaries", "Colorado_River_Basin_County_Boundaries.shp")
    
    # Print the path for debugging
    @info "Looking for shapefile at: $shapefile_path"
    
    # Check if the file exists
    if !isfile(shapefile_path)
        @warn "Shapefile not found at: $shapefile_path"
        return String[]
    end
    
    # Read the shapefile and extract GEOIDs
    ds = ArchGDAL.read(shapefile_path)
    layer = ArchGDAL.getlayer(ds, 0)
    geoids = String[]
    
    if ArchGDAL.nfeature(layer) == 0
        ArchGDAL.destroy(ds)
        return geoids
    end
    
    for feature in layer
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end
    
    ArchGDAL.destroy(ds)
    unique!(geoids)
    return geoids
end

"""
    get_west_montana_geoids() -> Vector{String}

Returns GEOIDs for counties in western Montana that are part of the Powell nation state.
"""
function get_west_montana_geoids()::Vector{String}
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MT'
        AND ST_X(ST_Centroid(geom)) < -112.5
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_florida_south_geoids() -> Vector{String}

Returns GEOIDs for Florida counties with centroids south of 29°N latitude.
This includes all of southern Florida including the Keys.
"""
function get_florida_south_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'FL'
        AND ST_Y(ST_Centroid(geom)) < 29.0
        ORDER BY ST_Y(ST_Centroid(geom)) DESC;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})

Store the geoids for a nation state in the database.

# Arguments
- `nation_state::String`: The name of the nation state
- `geoids::Union{Vector{String}, Vector{Union{Missing, String}}}`: Vector of geoids to associate with the nation state

# Example
```julia
set_nation_state_geoids("Powell", powell_geoids)
```
"""
function set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})
    CensusDB.with_connection() do conn
        try
            # Start a transaction
            execute(conn, "BEGIN;")
            
            # First, clear the nation for any counties that currently have it
            execute(conn, 
                "UPDATE census.counties SET nation = NULL WHERE nation = \$1;",
                [nation_state]
            )
            
            # Filter out missing values and convert to array
            valid_geoids = filter(!ismissing, collect(String, geoids))
            
            if !isempty(valid_geoids)
                # Then set the new nation for all specified counties in one query
                execute(conn, 
                    "UPDATE census.counties SET nation = \$1 WHERE geoid = ANY(\$2::text[]);",
                    [nation_state, valid_geoids]
                )
            end
            
            # Commit the transaction
            execute(conn, "COMMIT;")
        catch e
            # Rollback on error
            execute(conn, "ROLLBACK;")
            rethrow(e)
        end
    end
end

"""
    get_east_of_cascade_geoids() -> Vector{String}

Returns GEOIDs for counties east of the Cascade Mountains.
"""
function get_east_of_cascade_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR')
        AND ST_X(ST_Centroid(geom)) > -120.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_west_of_cascades() -> Vector{String}

Returns GEOIDs for counties west of the Cascade Mountains.
"""
function get_west_of_cascades()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR')
        AND ST_X(ST_Centroid(geom)) < -120.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_east_of_cascades() -> Vector{String}

Returns GEOIDs for counties east of the Cascade Mountains.
"""
function get_east_of_cascades()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('WA', 'OR')
        AND ST_X(ST_Centroid(geom)) > -120.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_southern_kansas_geoids() -> Vector{String}

Returns GEOIDs for counties in southern Kansas.
"""
function get_southern_kansas_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'KS'
        AND ST_Y(ST_Centroid(geom)) < 38.5
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_northern_kansas_geoids() -> Vector{String}

Returns GEOIDs for counties in northern Kansas.
"""
function get_northern_kansas_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'KS'
        AND ST_Y(ST_Centroid(geom)) >= 38.5
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ne_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in northeastern Missouri.
"""
function get_ne_missouri_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) >= 39.0
        AND ST_X(ST_Centroid(geom)) >= -92.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_southern_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in southern Missouri.
"""
function get_southern_missouri_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) < 38.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_northern_missouri_geoids() -> Vector{String}

Returns GEOIDs for counties in northern Missouri.
"""
function get_northern_missouri_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MO'
        AND ST_Y(ST_Centroid(geom)) >= 38.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_missouri_river_basin_geoids() -> Vector{String}

Returns GEOIDs for counties in the Missouri River Basin.
"""
function get_missouri_river_basin_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('MO', 'KS', 'NE', 'SD', 'ND', 'MT')
        AND ST_X(ST_Centroid(geom)) > -105.0
        AND ST_X(ST_Centroid(geom)) < -90.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_slope_geoids() -> Vector{String}

Returns GEOIDs for counties in the Slope region.
"""
function get_slope_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps IN ('ND', 'SD')
        AND ST_X(ST_Centroid(geom)) > -105.0
        AND ST_X(ST_Centroid(geom)) < -100.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_east_of_utah_geoids() -> Vector{String}

Returns GEOIDs for counties east of Utah.
"""
function get_east_of_utah_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE ST_X(ST_Centroid(geom)) > -111.0
        AND ST_X(ST_Centroid(geom)) < -102.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_socal_geoids()

Returns GEOIDs for Southern California counties, including:
- San Luis Obispo, Kern, and San Bernardino counties
- All counties south of these counties
"""
function get_socal_geoids()
    CensusDB.with_connection() do conn
        query = """
            WITH socal_counties AS (
                -- Explicitly include the northernmost counties
                SELECT geoid
                FROM census.counties
                WHERE stusps = 'CA'
                AND name IN ('San Luis Obispo', 'Kern', 'San Bernardino')
                
                UNION
                
                -- Include all counties south of these
                SELECT geoid
                FROM census.counties
                WHERE stusps = 'CA'
                AND ST_Y(ST_Centroid(geom)) <= (
                    SELECT MAX(ST_Y(ST_Centroid(geom)))
                    FROM census.counties
                    WHERE name IN ('San Luis Obispo', 'Kern', 'San Bernardino')
                    AND stusps = 'CA'
                )
            )
            SELECT geoid
            FROM socal_counties
            ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_east_of_sierras_geoids()

Returns GEOIDs for California counties bordering Nevada (except Placer County) plus Plumas County.
These counties form the eastern Sierra region.
"""
function get_east_of_sierras_geoids()
    CensusDB.with_connection() do conn
        query = """
            WITH border_counties AS (
                SELECT DISTINCT c1.geoid, c1.name
                FROM census.counties c1
                JOIN census.counties c2 ON ST_Touches(c1.geom, c2.geom)
                WHERE c1.stusps = 'CA' 
                AND c2.stusps = 'NV'
                AND c1.geoid != '06061'  -- Exclude Placer County
                UNION
                SELECT geoid, name
                FROM census.counties
                WHERE stusps = 'CA'
                AND name = 'Plumas'
            )
            SELECT geoid 
            FROM border_counties
            ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_exclude_from_va_geoids() -> Vector{String}

Returns GEOIDs for Virginia counties northeast of Highland County's centroid.
Highland County is explicitly included in the results.
"""
function get_exclude_from_va_geoids()
    CensusDB.with_connection() do conn
        query = """
        WITH highland_centroid AS (
            SELECT ST_X(ST_Centroid(geom)) as ref_lon,
                   ST_Y(ST_Centroid(geom)) as ref_lat
            FROM census.counties 
            WHERE stusps = 'VA' AND name = 'Highland'
        ),
        northeast_counties AS (
            SELECT c.geoid
            FROM census.counties c, highland_centroid h
            WHERE c.stusps = 'VA'
            AND (ST_Y(ST_Centroid(c.geom)) > h.ref_lat 
                 OR (ST_Y(ST_Centroid(c.geom)) = h.ref_lat 
                     AND ST_X(ST_Centroid(c.geom)) > h.ref_lon))
        ),
        highland_county AS (
            SELECT geoid
            FROM census.counties
            WHERE stusps = 'VA' AND name = 'Highland'
        )
        SELECT geoid FROM (
            SELECT geoid FROM northeast_counties
            UNION
            SELECT geoid FROM highland_county
        ) combined
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_non_miss_basin_la_geoids() -> Vector{String}

Returns GEOIDs for Louisiana parishes not in the Mississippi Basin:
Bossier, Caddo, Caldwell, East Carroll, Madison, Morehouse, Natchitoches,
Ouachita, Red River, Richland, Union, and West Carroll.
"""
function get_non_miss_basin_la_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'LA'
        AND name IN (
            'Caddo',
            'Bossier',
            'Red River',
            'Natchitoches',
            'Union',
            'Morehouse',
            'West Carroll',
            'East Carroll',
            'Ouachita',
            'Richland',
            'Madison',
            'Caldwell'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_exclude_from_la_geoids() -> Vector{String}

Returns GEOIDs for the following Louisiana parishes:
Cameron, Choctaw, Beauregard, Vernon, Sabine, DeSoto, and Calcasieu.
"""
function get_exclude_from_la_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'LA'
        AND name IN (
            'Cameron',
            'Choctaw',
            'Beauregard',
            'Vernon',
            'Sabine',
            'De Soto',
            'Calcasieu'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_va_geoids() -> Vector{String}

Returns GEOIDs for Virginia counties in the Ohio River Basin:
Buchanan, Dickenson, Lee, and Scott counties.
"""
function get_ohio_basin_va_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'VA'
        AND name IN (
            'Buchanan',
            'Dickenson',
            'Lee',
            'Scott'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_al_geoids() -> Vector{String}

Returns GEOIDs for Alabama counties in the Ohio River Basin:
Colbert, Franklin, Lauderdale, Lawrence, Limestone, Madison, and Morgan counties.
"""
function get_ohio_basin_al_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'AL'
        AND name IN (
            'Colbert',
            'Franklin',
            'Lauderdale',
            'Lawrence',
            'Limestone',
            'Madison',
            'Morgan'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_ms_geoids() -> Vector{String}

Returns GEOIDs for Mississippi counties in the Ohio River Basin:
Alcorn, Benton, DeSoto, Marshall, Prentiss, Tippah, Tishomingo, and Union counties.
"""
function get_ohio_basin_ms_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MS'
        AND name IN (
            'Alcorn',
            'Benton',
            'DeSoto',
            'Marshall',
            'Prentiss',
            'Tippah',
            'Tishomingo',
            'Union'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_nc_geoids() -> Vector{String}

Returns GEOIDs for North Carolina counties in the Ohio River Basin:
Ashe, Avery, Mitchell, Watauga, and Yancey counties.
"""
function get_ohio_basin_nc_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'NC'
        AND name IN (
            'Ashe',
            'Avery',
            'Mitchell',
            'Watauga',
            'Yancey'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_ga_geoids() -> Vector{String}

Returns GEOIDs for Georgia counties in the Ohio River Basin:
Catoosa, Dade, Murray, Walker, and Whitfield counties.
"""
function get_ohio_basin_ga_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'GA'
        AND name IN (
            'Catoosa',
            'Dade',
            'Murray',
            'Walker',
            'Whitfield'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_ohio_basin_md_geoids() -> Vector{String}

Returns GEOIDs for Maryland counties in the Ohio River Basin:
Allegany and Garrett counties.
"""
function get_ohio_basin_md_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'MD'
        AND name IN (
            'Allegany',
            'Garrett'
        )
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_hudson_bay_drainage_geoids() -> Vector{String}

Returns GEOIDs for counties in the Hudson Bay drainage basin:
Counties in North Dakota and Minnesota that drain into the Red River of the North.
"""
function get_hudson_bay_drainage_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE (stusps = 'ND' AND ST_X(ST_Centroid(geom)) > -97.5)
        OR (stusps = 'MN' AND ST_X(ST_Centroid(geom)) < -93.5)
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

"""
    get_miss_river_basin_sd_geoids() -> Vector{String}

Returns GEOIDs for South Dakota counties in the Mississippi River Basin:
Counties east of the Missouri River.
"""
function get_miss_river_basin_sd_geoids()
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid
        FROM census.counties
        WHERE stusps = 'SD'
        AND ST_X(ST_Centroid(geom)) > -100.0
        ORDER BY geoid;
        """
        result = execute(conn, query)
        return result[:, :geoid]
    end
end

# Export all functions
export get_western_geoids,
       get_eastern_geoids,
       get_colorado_basin_geoids,
       get_west_montana_geoids,
       get_florida_south_geoids,
       get_east_of_cascade_geoids,
       get_west_of_cascades,
       get_east_of_cascades,
       get_southern_kansas_geoids,
       get_northern_kansas_geoids,
       get_ne_missouri_geoids,
       get_southern_missouri_geoids,
       get_northern_missouri_geoids,
       get_missouri_river_basin_geoids,
       get_slope_geoids,
       get_east_of_utah_geoids,
       get_socal_geoids,
       get_east_of_sierras_geoids,
       get_exclude_from_va_geoids,
       get_non_miss_basin_la_geoids,
       get_exclude_from_la_geoids,
       get_ohio_basin_va_geoids,
       get_ohio_basin_al_geoids,
       get_ohio_basin_ms_geoids,
       get_ohio_basin_nc_geoids,
       get_ohio_basin_ga_geoids,
       get_ohio_basin_md_geoids,
       get_hudson_bay_drainage_geoids,
       get_miss_river_basin_sd_geoids

module Geoids

using LibPQ
using DataFrames
using ..CensusDB: execute

"""
    get_geoid_by_state_county(state::String, county::String)

Get the GEOID for a specific state and county combination.
"""
function get_geoid_by_state_county(state::String, county::String)
    query = """
    SELECT geoid FROM counties 
    WHERE state = \$1 AND county = \$2;
    """
    df = execute(conn, query, [state, county])
    return isempty(df) ? nothing : df[1, :geoid]
end

"""
    get_state_county_by_geoid(geoid::String)

Get the state and county names for a specific GEOID.
"""
function get_state_county_by_geoid(geoid::String)
    query = """
    SELECT state, county FROM counties 
    WHERE geoid = \$1;
    """
    df = execute(conn, query, [geoid])
    return isempty(df) ? nothing : (df[1, :state], df[1, :county])
end

"""
    get_geoids_by_state(state::String)

Get all GEOIDs for a specific state.
"""
function get_geoids_by_state(state::String)
    query = """
    SELECT geoid FROM counties 
    WHERE state = \$1 
    ORDER BY geoid;
    """
    df = execute(conn, query, [state])
    return df.geoid
end

end # module Geoids 