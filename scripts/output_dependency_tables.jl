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

function output_dependency_tables(dataframes::Vector{Any}, 
                                        nation_names::Vector{String}, 
                                        base_path::String="../_layout/partials/")
    
    @assert length(dataframes) == length(nation_names) "Number of DataFrames must match number of nation names"
    
    results = String[]
    
    for (i, df) in enumerate(dataframes)
        # Check if df is a DataFrame
        if !(df isa DataFrame)
            @warn "Item at index $i is not a DataFrame, skipping"
            continue
        end
        
        nation = nation_names[i]
        output_file = joinpath(base_path, "$(nation)_dependency_table.html")
        
        # Get the HTML output as a string
        html_output = sprint() do io
            pretty_table(
                io,
                df,
                backend = Val(:html),
                alignment = [:l, :r],
                show_subheader = false,
                header = ["State", "Dependency Ratio"],
                maximum_columns_width = "50"
            )
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
        
        # Write to file
        open(output_file, "w") do f
            write(f, modified_html)
        end
        
        push!(results, "HTML table for $(nation) written to $(output_file)")
    end
    
    return results
end