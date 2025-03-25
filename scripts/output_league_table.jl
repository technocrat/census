function output_league_table(df::DataFrame)
    output_file = partialsdir() * "/league_table.html"

    html_output = sprint() do io
        pretty_table(
            io,
            df,  # Pass the DataFrame to pretty_table
            backend=Val(:html),
            alignment=[:l, :r, :r, :r, :r, :r, :r],
            show_subheader=false,
            header=["Nation", "Population", "GDP", "Per Capita GDP", "College Degree", "Graduate Degree", "Dependency Ratio"]
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
    end)  # Close the replace function

    # Correctly handle header rows
    modified_html = replace(modified_html, r"<tr class=\"header\"" => "<tr class=\"tufte-table tr header\"")

    # Write to file
    open(output_file, "w") do f
        write(f, modified_html)
    end
end
