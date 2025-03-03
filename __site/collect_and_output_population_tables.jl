function collect_and_output_population_tables(pop_df::DataFrame, 
                                              nations::Vector{Vector{String}}, 
                                              state_names::Dict{String,String}, 
                                              titles::Vector{String},
                                              base_path::String="../_layout/partials/")
    
    @assert length(nations) == length(titles) "Number of nation groups must match number of titles"
    
    results = String[]
    
    for (i, states) in enumerate(nations)
        nation_title = titles[i]
        
        # Filter and transform the data for this nation
        nation_data = filter(row -> row.stusps in states, pop_df)
        
        # Create a new DataFrame with state names instead of postal codes
        nation_table = DataFrame(
            state_name = [state_names[code] for code in nation_data.stusps],
            population = nation_data.pop
        )
        
        # Sort by state name for consistency
        sort!(nation_table, :state_name)
        
        # Create the output file path
        output_file = joinpath(base_path, "$(nation_title)_population_table.html")
        
        # Get the HTML output as a string
        html_output = sprint() do io
            pretty_table(
                io,
                nation_table,
                backend = Val(:html),
                alignment = [:l, :r],
                show_subheader = false,
                header = ["State", "Population"],
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
        
        push!(results, "HTML population table for $(nation_title) written to $(output_file)")
    end
    
    return results
end