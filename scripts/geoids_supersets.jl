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
    ),
)

