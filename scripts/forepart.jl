# SPDX-License-Identifier: MIT
# SCRIPT

@info "Starting forepart.jl"

nations = (:concordia, :cumberland, :deseret, :dixie, :erie, :florida, :lonestar, :metropolis, :midlands, :pacifica, :powell, :siliconia, :southland)

@info "Available nations: " * join(nations, " ")
@info "Enter nation name: "
#===============================================================================================
=#
#nation = :concordia
#===============================================================================================
=#
if isnothing(nation)
    @info "Nation name is required. Please run the script again and provide a valid name."
else
    @info "Nation name: $nation selected"
end


# Define variables at the global scope 
global geoid_sets, state_dfs, map_title, dest, formal_name

state_sets = Dict(
	:concordia => (
		:ct,
		:me,
		:ma,
		:nh,
		:ri,
		:vt,
        :ny
	),
	:cumberland => (
		:oh,
		:in,
		:pa,
		:ny,
		:wv,
		:ky,
		:tn,
		:va,
		:al,
		:ms,
		:ga,
		:nc		
	),
	:deseret => (
		:ut,
		:wa,
		:or,
		:id,
		:nv,
		:ca
	),
	:dixie => (
		:va,
		:nc,
		:sc,
		:ga,
		:al,
		:ms,
		:la,
		:fl,
		:tn,
		:ky
	),
	:erie => (
		 :ny,
		 :pa,
		 :oh,
		 :mi,
		 :in
	),
	:florida => (
		:fl
	),
	:lonestar => (
		:tx,
		:la,
		:ar,
		:ok,
		:mo	
	),
	:metro => (
		:ct,
		:ny,
		:pa,
		:nj,
		:md,
		:de,
		:dc,
		:va
	),
	:midlands => (
		:ia,
		:il, 
		:mi, 
		:mn, 
		:mo, 
		:wi, 
		:ks, 
		:nd, 
		:ne, 
		:sd),
	:pacifica => (
		:wa,
		:or,
		:ca
	),
	:powell => (
		:az,
		:nm,
		:co,
		:tx,
		:ok,
		:ks,
		:ne,
		:sd,
		:nd,
		:wy,
		:mt,
		:ut
	),
	:siliconia => (
		:ca
	),
	:southland => (
		:ca
	)
)

@info("\nState selections included in $nation: ")
state_sets[nation]

# Define variables at the global scope global geoid_sets, state_dfs, map_title, dest
geoids_supersets = Dict(
	:concordia => (
		add_to_concordia = ["36019","36031"],
		take_from_concordia = ["09160","09190"]
	),
	:cumberland => (
		ohio_basin_dixie = GeoIDs.get_geoid_set("ohio_basin_dixie"),
		great_lakes = GeoIDs.get_geoid_set("great_lakes"),
		pa_ny = GeoIDs.get_geoid_set("ohio_basin_pa_ny"),
		ohio_basin_il = GeoIDs.get_geoid_set("ohio_basin_il"),
		ms_basin_tn = GeoIDs.get_geoid_set("ms_basin_tn"),
		ms_basin_ky = GeoIDs.get_geoid_set("ms_basin_ky")
	),
	:deseret => (
		colorado_basin = GeoIDs.get_geoid_set("colorado_basin"),
		east_of_utah = GeoIDs.get_geoid_set("east_of_utah"),
		east_of_cascade = GeoIDs.get_geoid_set("east_of_cascades"),
		missouri_river_basin = GeoIDs.get_geoid_set("missouri_river_basin"),
		east_of_sierras = GeoIDs.get_geoid_set("east_of_sierras"),
		socal = GeoIDs.get_geoid_set("socal")
	),
	:dixie => (
		florida = GeoIDs.get_geoid_set("florida"),
		eastern_la = GeoIDs.get_geoid_set("eastern_la"),
		ohio_basin_dixie = GeoIDs.get_geoid_set("ohio_basin_dixie"),
		northern_va = GeoIDs.get_geoid_set("northern_va")
	),
	:erie => (
		great_lakes = GeoIDs.get_geoid_set("great_lakes"),
		michigan_peninsula = GeoIDs.get_geoid_set("michigan_upper_peninsula")
	),
	:florida => (
		florida = GeoIDs.get_geoid_set("florida")
	),
	:lonestar => (
		central_west_counties = GeoIDs.get_geoid_set("west_of_100th"),
		eastern_geoids = GeoIDs.get_geoid_set("eastern_geoids"),
		southern_missouri = GeoIDs.get_geoid_set("southern_missouri"),
		eastern_la = GeoIDs.get_geoid_set("eastern_la")
	),
	:metropolis => (
		great_lakes = GeoIDs.get_geoid_set("great_lakes"),
		oh_basin_pa_ny = GeoIDs.get_geoid_set("ohio_basin_pa_ny"),
		northern_va = GeoIDs.get_geoid_set("northern_va"),
		take_from_ny = ["36019","36031"],
		add_to_ny = ["09160","09190"]
	),
	:midlands => (
		ohio_basin_il = GeoIDs.get_geoid_set("ohio_basin_il"),
		west_of_100th = GeoIDs.get_geoid_set("west_of_100th"),
		missouri_basin_ks = GeoIDs.get_geoid_set("missouri_basin_ks"),
		ks_south = GeoIDs.get_geoid_set("ks_south"),
		north_mo_mo = GeoIDs.get_geoid_set("north_mo_mo"),
		michigan_upper_peninsula = GeoIDs.get_geoid_set("michigan_upper_peninsula")
	),
	:pacifica => (
		east_of_cascades = GeoIDs.get_geoid_set("east_of_cascades"),
		northern_rural_california = GeoIDs.get_geoid_set("northern_rural_california"),
		east_of_sierras = GeoIDs.get_geoid_set("east_of_sierras"),
		socal = GeoIDs.get_geoid_set("socal")
	),
	:powell => (
		colorado_basin = GeoIDs.get_geoid_set("colorado_basin"),
		west_of_100th = GeoIDs.get_geoid_set("west_of_100th"),
		east_of_cascades = GeoIDs.get_geoid_set("east_of_cascades")
	),
	:siliconia => (
		socal = GeoIDs.get_geoid_set("socal"),
		east_of_sierras = GeoIDs.get_geoid_set("east_of_sierras"),
		northern_rural_california = GeoIDs.get_geoid_set("northern_rural_california")
	),
	:southland => (
		socal = GeoIDs.get_geoid_set("socal")
	)
)

# Add diagnostic statements
@info "Census is defined: ", isdefined(Main, :Census)
@info "set_nation_state_geoids is defined in Census: ", isdefined(Census, :set_nation_state_geoids)
@info "set_nation_state_geoids is defined in Main: ", isdefined(Main, :set_nation_state_geoids)
methods(Census.set_nation_state_geoids)

@info "Geoid supersets selections included in $nation:"
geoids_supersets[nation]

# Define a direct database connection function to avoid relying on Census.get_db_connection()
function get_db_connection()
    @info "DEBUG: Creating direct database connection"
    try
        # First try using Census module's connection if available
        if isdefined(Census, :get_db_connection)
            @info "DEBUG: Using Census.get_db_connection"
            return Census.get_db_connection()
        end

        # Otherwise create a direct connection
        @info "DEBUG: Creating direct connection to geocoder database"
        conn = LibPQ.Connection("dbname=geocoder host=localhost")

        if !LibPQ.isopen(conn)
            @info "DEBUG: Connection to geocoder failed, trying census database"
            conn = LibPQ.Connection("dbname=census host=localhost")
        end

        if !LibPQ.isopen(conn)
            @info "DEBUG: Connection to census failed, trying postgres database"
            conn = LibPQ.Connection("dbname=postgres host=localhost")
        end

        if LibPQ.isopen(conn)
            @info "DEBUG: Successfully connected to database"
            return conn
        else
            @error "Failed to connect to any PostgreSQL database"
        end
    catch e

        # Set the map projection and title
        @info "DEBUG: Setting map projection and title for nation: $nation"
        try
            dest = Census.CRS_STRINGS[nation]
            map_title = titlecase(String(nation))
            @info "DEBUG: Map projection set to: $dest"
        catch e
            @error "ERROR setting map projection: $e" exception = (e, catch_backtrace())
            exit(1)
        end
    end
end

# Create a dictionary to store state DataFrames
@info "Creating state DataFrames dictionary"
state_dfs = Dict{Symbol, DataFrame}()

# Check if us dataframe exists
if !(@isdefined us)
    @info "DEBUG: 'us' dataframe not found, attempting to load from database"
    try
        conn = get_db_connection()
        us = DataFrame(LibPQ.execute(conn, "SELECT * FROM census.counties"))
        close(conn)
        @info "DEBUG: Loaded 'us' dataframe from database with $(nrow(us)) rows"
    catch e
        @error "ERROR loading us dataframe: $e" exception=(e, catch_backtrace())
        exit(1)
    end
end

# Use iteration for state selection
@info "Subsetting states: $nations"
for state_sym in nations
    state_code = String(state_sym)
    @info "Processing state: $state_code"
    try
        state_dfs[state_sym] = subset(us, :stusps => ByRow(==(uppercase(state_code))))
        @info "Added $(nrow(state_dfs[state_sym])) counties for $state_code"
    catch e
        @error "ERROR subsetting state $state_code: $e" exception=(e, catch_backtrace())
    end
end

# Create a dictionary to store dataframes of state subsets
    state_dfs = Dict{String, DataFrame}()
    for state_code in Census.postals
        state_dfs[state_code] = subset(us, :stusps => ByRow(==(uppercase(state_code))))
    end

@info "forepart.jl completed successfully"
