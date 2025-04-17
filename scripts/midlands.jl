nation = "midlands" 
midlands = (:ia, :il, :mi, :mn, :mo, :wi, :ks, :nd, :ne, :sd)

include(joinpath(@__DIR__, "scripts/forepart.jl"))

# Safely get geoid sets - will return empty arrays if sets don't exist

# BEGIN geoid set selections
ohio_basin_il = GeoIDs.get_geoid_set("ohio_basin_il")
west_of_100th = GeoIDs.get_geoid_set("west_of_100th")
missouri_basin_ks = GeoIDs.get_geoid_set("missouri_basin_ks")
ks_south = GeoIDs.get_geoid_set("ks_south")
north_mo_mo = GeoIDs.get_geoid_set("north_mo_mo")
michigan_peninsula = GeoIDs.get_geoid_set("michigan_upper_peninsula")


# BEGIN subsetting 
# Illinois - exclude Ohio Basin
if !isempty(ohio_basin_il_geoids)
    state_dfs[:il] = subset(state_dfs[:il], :geoid => ByRow(x -> x ∉ ohio_basin_il_geoids))
end

# Michigan - only counties in the Upper Peninsula
if !isempty(michigan_peninsula)
    state_dfs[:mi] = subset(state_dfs[:mi], :geoid => ByRow(x -> x ∈ michigan_peninsula))
end

# Kansas - exclude southern
if !isempty(ks_south)
    state_dfs[:ks] = subset(state_dfs[:ks], :geoid => ByRow(x -> x ∉ ks_south))
end

# Missouri - only northern counties
if !isempty(north_mo_mo)
    state_dfs[:mo] = subset(state_dfs[:mo], :geoid => ByRow(x -> x ∈ north_mo_mo))
end

# Nebraska - exclude west of 100th
if !isempty(west_of_100th)
    state_dfs[:ne] = subset(state_dfs[:ne], :geoid => ByRow(x -> x ∉ west_of_100th))
end

# North Dakota - exclude west of 100th
if !isempty(west_of_100th)
    state_dfs[:nd] = subset(state_dfs[:nd], :geoid => ByRow(x -> x ∉ west_of_100th))
end

# South Dakota - exclude west of 100th
if !isempty(west_of_100th)
    state_dfs[:sd] = subset(state_dfs[:sd], :geoid => ByRow(x -> x ∉ west_of_100th))
end

# Combine all filtered states using the nations tuple
df = vcat([state_dfs[state] for state in nations]...)

include(joinpath(@__DIR__, "scripts/aftpart.jl"))