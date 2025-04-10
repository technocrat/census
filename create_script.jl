#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script template generator for Census.jl

"""
    create_script(filename; overwrite=false, template="standard")

Create a new Julia script with proper Census.jl configuration.

# Arguments
- `filename`: Name of the script file to create
- `overwrite`: Whether to overwrite existing files (default: false)
- `template`: Template type to use - "standard", "analysis", or "map" (default: "standard")

# Returns
- Path to the created script file

# Examples
```julia
# Create a basic script
create_script("my_analysis.jl")

# Create a mapping script
create_script("visualize_states.jl", template="map")

# Create an analysis script, overwriting if it exists
create_script("population_analysis.jl", template="analysis", overwrite=true)
```
"""
function create_script(filename; overwrite=false, template="standard")
    # Ensure filename ends with .jl
    if !endswith(filename, ".jl")
        filename = filename * ".jl"
    end
    
    # Determine destination directory - prefer scripts/ subfolder if it exists
    scripts_dir = joinpath(dirname(@__FILE__), "scripts")
    if !isdir(scripts_dir)
        mkdir(scripts_dir)
        println("Created scripts directory: $scripts_dir")
    end
    
    # Construct full path
    filepath = joinpath(scripts_dir, filename)
    
    # Check if file exists
    if isfile(filepath) && !overwrite
        error("File $filepath already exists. Use overwrite=true to replace it.")
    end
    
    # Choose the appropriate template
    content = if template == "standard"
        standard_template()
    elseif template == "analysis"
        analysis_template()
    elseif template == "map"
        map_template()
    else
        error("Unknown template type: $template. Use 'standard', 'analysis', or 'map'.")
    end
    
    # Write the file
    write(filepath, content)
    println("✅ Created script: $filepath")
    
    return filepath
end

# Standard script template
function standard_template()
    """
    #!/usr/bin/env julia
    # SPDX-License-Identifier: MIT
    # SCRIPT
    
    # Load Census.jl - handles importing DataFrames and DataFramesMeta
    push!(LOAD_PATH, expanduser("~/projects/Census.jl"))
    using Census
    
    # Initialize census data
    us = init_census_data()
    println("Loaded \$(nrow(us)) counties")
    
    # Your analysis code goes here
    # ...
    
    # Example: Filter to specific state
    ca = subset(us, :stusps => ByRow(==("CA")))
    println("California has \$(nrow(ca)) counties")
    """
end

# Analysis script template with more data processing
function analysis_template()
    """
    #!/usr/bin/env julia
    # SPDX-License-Identifier: MIT
    # SCRIPT
    
    # Load Census.jl - handles importing DataFrames and DataFramesMeta
    push!(LOAD_PATH, expanduser("~/projects/Census.jl"))
    using Census
    
    # Initialize census data
    us = init_census_data()
    println("Loaded \$(nrow(us)) counties")
    
    # Set up analysis parameters
    state_code = "CA"  # Change to your state of interest
    analysis_year = 2020
    
    # Filter data for analysis
    state_data = subset(us, :stusps => ByRow(==(state_code)))
    println("\$(state_code) has \$(nrow(state_data)) counties")
    
    # Example: Calculate population statistics
    total_pop = sum(skipmissing(state_data.pop))
    avg_pop = total_pop / nrow(state_data)
    
    println("Total population: \$(total_pop)")
    println("Average county population: \$(round(Int, avg_pop))")
    
    # Example: Find top 5 counties by population
    top_counties = first(sort(state_data, :pop => Desc), 5)
    println("\\nTop 5 counties by population:")
    display(select(top_counties, [:name, :pop]))
    
    # Your additional analysis here
    # ...
    """
end

# Mapping script template
function map_template()
    """
    #!/usr/bin/env julia
    # SPDX-License-Identifier: MIT
    # SCRIPT
    
    # Load Census.jl - handles importing DataFrames and DataFramesMeta
    push!(LOAD_PATH, expanduser("~/projects/Census.jl"))
    using Census
    using CairoMakie
    
    # Initialize census data
    us = init_census_data()
    println("Loaded \$(nrow(us)) counties")
    
    # Filter to region of interest
    # Example: California counties
    region = subset(us, :stusps => ByRow(==("CA")))
    println("Region has \$(nrow(region)) counties")
    
    # Create a map
    println("Creating map...")
    fig = Figure(resolution = (800, 600))
    ax = Axis(fig[1, 1], title = "California Counties")
    
    # Add your map visualization code here
    # ...
    
    # Display and save the map
    display(fig)
    save("california_map.png", fig)
    println("Map saved to california_map.png")
    """
end

# If run directly, show usage
if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) < 1
        println("""
        Census.jl Script Generator
        
        Usage:
          julia create_script.jl <filename> [template] [overwrite]
        
        Arguments:
          filename  - Name of the script file to create
          template  - Template type: standard, analysis, or map (default: standard)
          overwrite - Whether to overwrite existing files: true or false (default: false)
        
        Examples:
          julia create_script.jl my_analysis.jl
          julia create_script.jl map_visualization.jl map true
        """)
    else
        filename = ARGS[1]
        template = length(ARGS) >= 2 ? ARGS[2] : "standard"
        overwrite = length(ARGS) >= 3 && lowercase(ARGS[3]) == "true"
        
        try
            path = create_script(filename, template=template, overwrite=overwrite)
            println("Created script: $path")
        catch e
            println("Error: $e")
        end
    end
end 