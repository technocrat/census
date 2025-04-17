# SPDX-License-Identifier: MIT
# SCRIPT

@info "Starting forepart.jl"

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "scripts/preamble.jl")
@info "About to include preamble.jl from path: $the_path"
try
    include(the_path)
    @info "Successfully included preamble.jl"
catch e
    @error "ERROR including preamble.jl: $e" exception=(e, catch_backtrace())
    exit(1)
end

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
@info "Loading required packages"
using DataFrames
using LibPQ
using GeoIDs

@info "Starting nation template script"
@info "Loading Dependencies"
@info "About to include forepart.jl"
@info "Including forepart.jl script for dependencies and state DataFrames creation"
# Main script execution
@info "=== Nation State Creation Template ==="
@info "Loading dependencies"
# Specify relationships between states and the geoid sets

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

@info "\n--- STEP 6: Generating Map and Inspecting Data ---"
@info "DEBUG: About to include midpart.jl"
@info "Including midpart.jl script for map generation and data inspection"
try
    # Check if required variables are defined for midpart.jl
    if !(@isdefined state_dfs) || !(@isdefined nation) || !(@isdefined map_title) || !(@isdefined dest)
        @error "ERROR: Required variables for midpart.jl are not defined"
        @info "state_dfs defined: $(@isdefined state_dfs)"
        @info "nation defined: $(@isdefined nation)"
        @info "map_title defined: $(@isdefined map_title)"
        @info "dest defined: $(@isdefined dest)"
        
        # Try to define missing variables
        if !(@isdefined map_title)
            global map_title = titlecase(nation)
        end
        
        if !(@isdefined dest) && isdefined(Census, :CRS_STRINGS) && haskey(Census.CRS_STRINGS, nation)
            global dest = Census.CRS_STRINGS[nation]
        elseif !(@isdefined dest)
            global dest = "+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
        end
    end
    
    # Create combined dataframe from state_dfs for midpart.jl
    global df = vcat(values(state_dfs)...)
    @info "DEBUG: Created combined dataframe with $(nrow(df)) counties"
    
    # First check if the file exists
    midpart_path = joinpath(@__DIR__, "midpart.jl")
    if !isfile(midpart_path)
        @error "midpart.jl not found at path: $midpart_path"
        exit(1)
    end
    
    include(midpart_path)
    @info "DEBUG: Successfully included midpart.jl"
catch e
    @error "ERROR including midpart.jl: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

@info "\n--- STEP 7: Updating Database ---"
@info "DEBUG: About to include aftpart.jl"
@info "Including aftpart.jl script to update database and check for missing data"
try
    # First check if the file exists
    aftpart_path = joinpath(@__DIR__, "aftpart.jl")
    if !isfile(aftpart_path)
        @error "aftpart.jl not found at path: $aftpart_path"
        exit(1)
    end
    
    include(aftpart_path)
    @info "DEBUG: Successfully included aftpart.jl"
catch e
    @error "ERROR including aftpart.jl: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

@info "\n=== SUCCESS ==="
@info "Nation state creation process completed for: $nation"
