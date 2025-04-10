# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

using CSV

# Define paths relative to project root
const PROJECT_ROOT = dirname(dirname(@__FILE__))
const DATA_DIR = joinpath(PROJECT_ROOT, "data")
const PARTIALS_DIR = joinpath(PROJECT_ROOT, "_layout", "partials")

# Read data
world = CSV.read(joinpath(DATA_DIR, "world_gdp.csv"), DataFrame)
world = world[!,[1,68]]
rename!(world,[:country,:gdp])
sort!(world, :country)
world[59,1] = "Czech Republic"
eu = filter(:country => x -> x ∈ EU, world)
sort!(eu, :gdp)


function output_gdp_compared_to_eu_table(nations::Vector{Vector{String}}, 
                                        titles::Vector{String},
                                        base_path::String=PARTIALS_DIR)
    
    @assert length(nations) == length(titles) "Number of nation groups must match number of titles"
    
    results = String[]
    # Debug: Print base path to verify it's correct
    println("Base path: ", base_path)
    # Check if directory exists, create if not
    if !isdir(base_path)
        println("Creating directory: ", base_path)
        mkpath(base_path)
    end
    
    for (i, nation) in enumerate(nations)
        nation_title = titles[i]
        println("Processing $nation_title...")
        
        # Sanity check for nation vector
        println("Nation vector: ", nation)
        
        # Make nation state population DataFrame
        df = make_nation_state_gdp_df(nation)
        println("Nation DataFrame created with $(nrow(df)) rows")
        
        my_country = titles[i]
        last(df)[1] = my_country
        rename!(df, [:country, :gdp])
        
        # Check eu DataFrame existence
        if @isdefined(eu)
            println("EU DataFrame exists with $(nrow(eu)) rows")
        else
            error("EU DataFrame not defined")
        end
        
        comparator = vcat(eu, DataFrame(last(df)))
        sort!(comparator, :gdp)
        comparator.gdp = round.((comparator.gdp ./ 1e12), digits = 4)
        output = format_with_commas(comparator)
        
        # Create a highlighter for the specific country
        hl_nation_row_bold = HtmlHighlighter(
            (data, i, j) -> data[i, 1] == my_country,
            HtmlDecoration(font_weight = "bold")
        )
        
        # Create the output file path with sanitized filename
        safe_title = replace(nation_title, r"[^\w\s-]" => "")
        safe_title = replace(safe_title, r"\s+" => "_")
        output_file = joinpath(base_path, "$(safe_title)_eu_gdp_compare_table.html")
        println("Output file: ", output_file)
        
        # Capture the HTML output to a string
        html_output = sprint() do io
            pretty_table(io, output,
                backend = Val(:html),
                header = ["Nation", "GDP (trillions)"],
                show_subheader = false,
                alignment = [:l, :r],
                highlighters = (hl_nation_row_bold,)
            )
        end
        
        # Debug: Check html_output content
        println("HTML output length: ", length(html_output))
        if length(html_output) == 0
            println("Warning: Empty HTML output generated")
        end
        
        # Replace the opening table tag
        modified_html = replace(html_output, "<table" => "<table class=\"tufte-table\"", count=1)
        
        # Add class to all rows, with special class for odd rows
        row_pattern = r"<tr>\s*<td"
        row_count = 0
        modified_html = replace(modified_html, row_pattern => function(match)
            row_count += 1
            if row_count % 2 == 1
                return "<tr class=\"tufte-table tr odd-row\"><td"
            else
                return "<tr class=\"tufte-table tr\"><td"
            end
        end)
        
        # Also handle header rows
        modified_html = replace(modified_html, r"<tr class = \"header" => "<tr class=\"tufte-table tr header")
        
        # Write to file with error handling
        try
            open(output_file, "w") do f
                write(f, modified_html)
            end
            println("Successfully wrote $(length(modified_html)) bytes to file")
            push!(results, "HTML GDP league table for $(nation_title) written to $(output_file)")
        catch e
            println("Error writing to file: ", e)
            push!(results, "ERROR: Failed to write HTML for $(nation_title): $(e)")
        end
    end
    
    return results
end