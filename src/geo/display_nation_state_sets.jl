function display_nation_state_sets()
    println("\nNation state sets:")
    for set_name in sort(unique(GeoIDs.list_all_geoids().set_names))
        println("  ", set_name)
    end
end

export display_nation_state_sets
