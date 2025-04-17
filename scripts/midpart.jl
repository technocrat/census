@info("DEBUG: Starting midpart.jl")

# Check if required variables exist
if !(@isdefined state_dfs) || !(@isdefined nation) || !(@isdefined map_title) || !(@isdefined dest)
    @error "Required variables not defined. Make sure state_dfs, nation, map_title, and dest are defined before including midpart.jl"
    exit(1)
end

@info "DEBUG: Combining state DataFrames"
# Combine all state DataFrames into one
try
    global df = vcat(values(state_dfs)...)
    @info "DEBUG: Combined DataFrame has $(nrow(df)) rows"
catch e
    @error "ERROR combining DataFrames: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

# Create bins for population
@info "DEBUG: Creating population bins"
try
    selected_method = "fisher"
    bin_indices = Breakers.get_bin_indices(df.pop, 7)
    df.bin_values = bin_indices[selected_method]
    @info "DEBUG: Population bins created successfully"
catch e
    @error "ERROR creating population bins: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

# Create figure
@info "DEBUG: Creating figure"
try
    global fig = Figure(size=(2400, 1600), fontsize=22)
    Census.map_poly(df, map_title, dest, fig)
    @info "DEBUG: Figure created successfully"
catch e
    @error "ERROR creating figure: $(e)" exception=(e, catch_backtrace())
    exit(1)
end

# Save the figure using the exported IMG_DIR from Census module
@info "DEBUG: Saving figure"
try
    @info "Saving to directory: $(Census.IMG_DIR)"
    saved_path = Census.save_plot(fig, map_title, directory=Census.IMG_DIR)
    @info "Plot saved to: $saved_path"

    # Verify file exists
    if isfile(saved_path)
        @info "File successfully created at: $saved_path"
    else
        @error "Failed to create file at: $saved_path"
    end
    @info "DEBUG: Figure saved successfully"
catch e
    @error "ERROR saving figure: $(e)" exception=(e, catch_backtrace())
    # Don't exit on figure save failure
end

# Display the figure
@info "DEBUG: Displaying figure"
try
    display(fig)
    @info "DEBUG: Figure displayed successfully"
catch e
    @error "ERROR displaying figure: $(e)" exception=(e, catch_backtrace())
    # Don't exit on display failure
end

# Add diagnostic before calling set_nation_state_geoids
@info "Before calling set_nation_state_geoids:"
@info "Type of df.geoid: $(typeof(df.geoid))"
@info "Length of df.geoid: $(length(df.geoid))"
@info "Sample of df.geoid: $(first(df.geoid, 5))"

@info "DEBUG: midpart.jl completed successfully"
