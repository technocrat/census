function output_gdp_compared_to_us_table(df::DataFrame, 
                                        nations::Vector{Vector{String}}, 
                                        titles::Vector{String},
                                        base_path::String=partialsdir())
    
    @assert length(nations) == length(titles) "Number of nation groups must match number of titles"
    
    results = String[]
    println("Base path: ", base_path)
    if !isdir(base_path)
        println("Creating directory: ", base_path)
        mkpath(base_path)
    end
    
    # Format the data for output once
    formatted_df = format_with_commas(df)
    
    for (i, nation) in enumerate(nations)
        current_title = titles[i]
        println("Processing $current_title with $(nrow(formatted_df)) rows...")
        
        # Create the output file path with sanitized filename
        safe_title = replace(current_title, r"[^\w\s-]" => "")
        safe_title = replace(safe_title, r"\s+" => "_")
        output_file = joinpath(base_path, "$(safe_title)_per_capita_table.html")
        println("Output file: ", output_file)
        
        # Generate basic HTML table without any highlighting
        html_output = sprint() do io
            pretty_table(io, formatted_df,
                backend = Val(:html),
                header = ["Nation", "GDP per capita"],
                show_subheader = false,
                alignment = [:l, :r]
            )
        end
        
        # Replace the opening table tag
        modified_html = replace(html_output, "<table" => "<table class=\"tufte-table\"", count=1)
        
        # First, add styles to all rows
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
        
        # Handle header rows
        modified_html = replace(modified_html, r"<tr class = \"header" => "<tr class=\"tufte-table tr header")
        
        # Now find the row for the current country and make the entire row bold
        # First, let's split the HTML into lines for easier processing
        html_lines = split(modified_html, '\n')
        
        # Find the line containing the current country and modify it
        for (idx, line) in enumerate(html_lines)
            if contains(line, current_title)
                println("Found country line: $line")
                # Add style="font-weight: bold;" to the <tr> tag
                html_lines[idx] = replace(line, "<tr" => "<tr style=\"font-weight: bold;\"", count=1)
                println("Modified to: $(html_lines[idx])")
                break
            end
        end
        
        # Rejoin the HTML lines
        modified_html = join(html_lines, '\n')
        
        # Write to file with error handling
        try
            open(output_file, "w") do f
                write(f, modified_html)
            end
            println("Successfully wrote $(length(modified_html)) bytes to file")
            push!(results, "GDP league table for $(current_title) written to $(output_file)")
        catch e
            println("Error writing to file: ", e)
            push!(results, "ERROR: Failed to write HTML for $(current_title): $(e)")
        end
    end
    
    return results
end