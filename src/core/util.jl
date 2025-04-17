# SPDX-License-Identifier: MIT

"""
Utility functions for working with census data
"""

"""
    customcut(x::Vector, breaks::Vector) -> Vector{String}

Create custom bin labels for a vector of values using specified breaks.

# Arguments
- `x`: Vector of values to bin
- `breaks`: Vector of break points to use for binning

# Returns
- Vector of formatted strings representing bins (e.g., "0 - 100", "> 500")

# Example
```julia
values = [10, 150, 300, 700]
breaks = [0, 100, 500, 1000]
bins = customcut(values, breaks) # ["0 - 100", "100 - 500", "500 - 1000", "> 1000"]
```
"""
function customcut(x::Vector, breaks::Vector)
    n = length(breaks)
    result = similar(x, String)
    
    for i in eachindex(x)
        value = x[i]
        if ismissing(value)
            result[i] = "Missing"
            continue
        end
        
        for j in 1:(n-1)
            if j == 1 && value <= breaks[j]
                result[i] = "≤ $(breaks[j])"
                break
            elseif j == n-1 && value > breaks[j]
                result[i] = "> $(breaks[j])"
                break
            elseif value > breaks[j] && value <= breaks[j+1]
                result[i] = "$(breaks[j]) - $(breaks[j+1])"
                break
            end
        end
    end
    
    return result
end

"""
    list_geoid_sets() -> Vector{String}

List all available geoid set constants defined in the Census module.

# Returns
- `Vector{String}`: Names of all geoid set constants 

# Example
```julia
sets = list_geoid_sets()
# Use a specific set
geoids = Census.FLORIDA_GEOIDS
```
"""
function list_geoid_sets()
    # Get all module variables
    all_names = names(Census, all=true)
    
    # Filter for variables ending with _GEOIDS and that are exported
    geoid_sets = String[]
    for name in all_names
        name_str = String(name)
        if endswith(name_str, "_GEOIDS")
            push!(geoid_sets, name_str)
        end
    end
    
    return sort(geoid_sets)
end

"""
    get_geo_pop(geo_tuple)

Calculate the population for a specific geographic area based on its postal code and county name.

# Arguments
- `geo_tuple`: A tuple containing (county_name, postal_code) or a PostalCode object.

# Returns
- A DataFrame containing population data for the specified geographic area.

# Example
```julia
# Using a tuple
get_geo_pop(("Bernalillo", "NM"))

# Using a PostalCode object
get_geo_pop(PostalCode("Bernalillo", "NM"))
```
"""
function get_geo_pop(geo_tuple)
    # Check if geo_tuple is a PostalCode or a tuple
    if geo_tuple isa PostalCode
        county = geo_tuple.county
        state = geo_tuple.state
    else
        county, state = geo_tuple
    end
    
    conn = get_db_connection() 
    query = "SELECT SUM(pop) FROM census.counties WHERE stusps = '$state' AND name = '$county'"
    result = LibPQ.execute(conn, query)
    if result === nothing || LibPQ.nrows(result) == 0 || ismissing(result[1, 1])
        close(conn)
        @warn "No population data found for $county, $state"
        return missing
    end
    pop = result[1, 1]
    close(conn)
    return pop
end

"""
    customcut(x; breaks=(), labels=(), include_lowest=true, right=true, na_label="NA")

Custom cut function for binning numeric data into categorical variables.

# Arguments
- `x::AbstractArray`: Numeric data to bin.
- `breaks::AbstractArray`: Vector of break points for binning.
- `labels::AbstractArray`: Labels for the bins. If not provided, default labels will be created.
- `include_lowest::Bool`: Whether to include the lowest value in the first bin. Default `true`.
- `right::Bool`: Whether the intervals are closed on the right (and open on the left) or vice versa. Default `true`.
- `na_label::String`: Label for missing values. Default "NA".

# Returns
- CategoricalArray with binned data.

# Example
```julia
# Bin data into 5 equal-size bins
breaks = collect(range(minimum(data), maximum(data), length=6))
result = customcut(data, breaks=breaks)
```
"""
function customcut(x; breaks=(), labels=(), include_lowest=true, right=true, na_label="NA")
    if length(breaks) == 0
        error("Breaks must be provided")
    end
    
    # Create default labels if not provided
    if length(labels) == 0
        labels = map(i -> string(i), 1:(length(breaks)-1))
    end
    
    # Create categorical array for results
    result = CategoricalArray{String}(undef, length(x))
    
    # Assign values to bins
    for i in eachindex(x)
        if ismissing(x[i])
            result[i] = na_label
            continue
        end
        
        # Find which bin the value belongs in
        bin_found = false
        for j in 1:(length(breaks)-1)
            lower_bound = breaks[j]
            upper_bound = breaks[j+1]
            
            if j == 1 && include_lowest
                # For the first bin, check if value is in [lower, upper)
                if right && x[i] >= lower_bound && x[i] < upper_bound
                    result[i] = labels[j]
                    bin_found = true
                    break
                # For the first bin, check if value is in (lower, upper]
                elseif !right && x[i] > lower_bound && x[i] <= upper_bound
                    result[i] = labels[j]
                    bin_found = true
                    break
                end
            else
                # For subsequent bins, check if value is in [lower, upper)
                if right && x[i] >= lower_bound && x[i] < upper_bound
                    result[i] = labels[j]
                    bin_found = true
                    break
                # For subsequent bins, check if value is in (lower, upper]
                elseif !right && x[i] > lower_bound && x[i] <= upper_bound
                    result[i] = labels[j]
                    bin_found = true
                    break
                end
            end
        end
        
        # If last bin and value equals the highest break value
        if !bin_found && x[i] == breaks[end]
            if right && include_lowest
                result[i] = labels[end]
            elseif !right
                result[i] = labels[end]
            else
                result[i] = na_label
            end
        # If value doesn't fit in any bin
        elseif !bin_found
            result[i] = na_label
        end
    end
    
    return result
end

"""
    save_plot_to_img_dir(plot, title; format="png")

Save a plot to the project's IMG_DIR directory with a standardized naming convention.

# Arguments
- `plot`: The plot object to save (can be Plots.Plot or CairoMakie.Figure)
- `title::String`: Title to use for the filename (will be sanitized)
- `format::String`: Optional. File format to save as (default: "png")

# Returns
- String: The full path to the saved file

# Example
```julia
fig = Figure()
# ... plot creation code ...
save_plot_to_img_dir(fig, "Population Density")
```
"""
function save_plot_to_img_dir(plot, title; format="png")
    # Use the global IMG_DIR constant that's defined at the module level
    @info "Saving to Census.IMG_DIR: $(IMG_DIR)"
    
    # Call the save_plot function with the correct directory
    saved_path = save_plot(plot, title, format=format, directory=IMG_DIR)
    
    # Verify the file was created
    if isfile(saved_path)
        @info "File successfully created at: $saved_path"
    else
        @error "Failed to create file at: $saved_path"
    end
    
    return saved_path
end

"""
    get_eastward_of_100w_geoids()

Gets the GEOIDs for counties with centroids east of 100°W longitude.

# Returns
- A vector of GEOIDs as strings.
"""
function get_eastward_of_100w_geoids()
    return get_centroid_longitude_range_geoids(-99.9999, -65.0)
end

"""
    get_westward_of_100w_geoids()

Gets the GEOIDs for counties with centroids west of 100°W longitude.

# Returns
- A vector of GEOIDs as strings.
"""
function get_westward_of_100w_geoids()
    return get_centroid_longitude_range_geoids(-180.0, -100.0001)
end

"""
    list_geoid_sets()

Lists all available geoid sets and their sources.

# Returns
- A DataFrame with columns for the set name and source.
"""
function list_geoid_sets()
    # Define all our geoid set functions with their sources
    geoid_fns = [
        ("eastward_of_100w", "Census.get_eastward_of_100w_geoids()"),
        ("westward_of_100w", "Census.get_westward_of_100w_geoids()"),
        ("between_110w_115w", "Census.get_110w_to_115w_geoids()")
        # Add more as needed
    ]
    
    # Create DataFrame
    return DataFrame(
        set_name = first.(geoid_fns),
        source = last.(geoid_fns)
    )
end

"""
    create_script(script_name::String; destination::String="")

Creates a template script file with proper imports and structure.

# Arguments
- `script_name::String`: Name of the script file to create (without .jl extension)
- `destination::String`: Optional. Directory to place the script (default: scripts directory)

# Returns
- The path to the created script file

# Example
```julia
create_script("analyze_population") # Creates scripts/analyze_population.jl
```
"""
function create_script(script_name::String; destination::String="")
    if !endswith(script_name, ".jl")
        script_name = script_name * ".jl"
    end
    
    if isempty(destination)
        destination = joinpath(dirname(dirname(@__DIR__)), "scripts")
    end
    
    # Ensure destination directory exists
    mkpath(destination)
    
    # Full path to the script
    script_path = joinpath(destination, script_name)
    
    # Create script content
    script_content = """
    # SPDX-License-Identifier: MIT
    # SCRIPT
    
    # Load the comprehensive preamble that handles visualization
    using Census
    using DataFrames
    using DataFramesMeta
    
    # Your code goes here
    println("Script $(script_name) is running...")
    
    # Example of creating a plot
    # fig = Figure(size=(1200, 800))
    # ... plotting code ...
    # Census.save_plot_to_img_dir(fig, "My Plot Title")
    """
    
    # Write script to file
    write(script_path, script_content)
    
    @info "Created script template at $(script_path)"
    return script_path
end 