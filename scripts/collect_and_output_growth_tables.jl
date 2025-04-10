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

function collect_and_output_growth_tables(growth::DataFrame, 
                                          nations::Vector{Vector{String}}, 
                                          state_names::Dict{String,String}, 
                                          titles::Vector{String},
                                          base_path::String=partialsdir())
    
    @assert length(nations) == length(titles) "Number of nation groups must match number of titles"
    
    results = String[]
    
    for (i, states) in enumerate(nations)
        nation_title = titles[i]
        
        # Filter for selected states
        nation_data = filter(row -> row.State in [state_names[code] for code in states], growth)
        
        # Sort by state name
        sort!(nation_data, :State)
        # Create a DataFrame for the totals
        total_line = DataFrame(
            State              = "Total",
            Births             = sum(nation_data.Births),
            Deaths             = sum(nation_data.Deaths),
            natural            = sum(nation_data.natural),
            net_domestic       = sum(nation_data.net_domestic),
            foreign_immigrants = sum(nation_data.foreign_immigrants),
            growth             = sum(nation_data.growth)
        )
        # Add the total line
        nation_table = vcat(nation_data, total_line)
        # Format numbers with commas
        formatted_table = format_with_commas(nation_table)
        # Create the output file path
        print(base_path)
        output_file = joinpath(base_path, "$(nation_title)_growth_table.html")
        
        # Create an HtmlHighlighter to make the last row bold
        hl_last_row_bold = HtmlHighlighter(
            (data, i, j) -> i == size(data, 1),
            HtmlDecoration(font_weight = "bold")
        )
        
        # Get the HTML output as a string
        html_output = sprint() do io
            pretty_table(
                io,
                formatted_table,
                backend = Val(:html),
                alignment = [:l, :r, :r, :r, :r, :r, :r],
                show_subheader = false,
                header = ["State", "Births", "Deaths", "Natural Growth", 
                          "Domestic Migration", "International Migration", "Net Growth"],
                highlighters = (hl_last_row_bold,)
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
        
        push!(results, "HTML growth table for $(nation_title) written to $(output_file)")
    end
    
    return results
end