@info "DEBUG: Starting aftpart.jl"

# Check if required variables exist
if !(@isdefined state_dfs) || !(@isdefined nations) || !(@isdefined map_title)
    @error "Required variables not defined. Make sure state_dfs, nations, and map_title are defined before including aftpart.jl"
    exit(1)
end

@info "Combine all filtered states using the nations tuple"
@info "DEBUG: Combining filtered states"
try
    global df = vcat([state_dfs[state] for state in nations]...)
    @info "DEBUG: Combined DataFrame has $(nrow(df)) rows"
catch e
    @error "ERROR combining states: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

@info "Update the nation column in the database with the new nation state"
@info "DEBUG: Updating nation column in database"
try
    # This is the crucial step that updates the database
    Census.set_nation_state_geoids(map_title, df.geoid)
    @info "Successfully updated census.counties with nation=$map_title for $(length(df.geoid)) counties"
catch e
    @error "ERROR updating nation state in database: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

@info "Find rows in us where nation is missing"
@info "DEBUG: Finding rows with missing nation"
try
    missing_nation = subset(df, :nation => ByRow(ismissing))
    @info "Found $(nrow(missing_nation)) counties with missing nation"

    @info "Display sample of counties with missing nation"
    if nrow(missing_nation) > 0
        @info "Sample of counties with missing nation:"
        first_few = first(missing_nation, min(5, nrow(missing_nation)))
        for row in eachrow(first_few)
            @info "County: $(row.county), State: $(row.stusps), GEOID: $(row.geoid)"
        end
    end
catch e
    @error "ERROR finding missing nations: $(e)" exception=(e, catch_backtrace())
    # Don't exit on this error
end

@info "DEBUG: aftpart.jl completed successfully"


