function output_nation_dependency_ratios(tab::DataFrame, output_file::String="$the_nation" * "_dependency_table" * ".html")
    # Get the HTML output as a string
    html_output = sprint() do io
        pretty_table(
            io,
            tab,
            backend = Val(:html),
            alignment = [:l, :r],
            show_subheader = false,
            header = ["State", "Dependency Ratio"],
            maximum_columns_width = "50",
            highlighters = (last_row_bold, hl_alternating)
        )
    end
    
    # Replace the opening table tag
    modified_html = replace(html_output, "<table" => "<table class=\"tufte-table\"", count=1)
    
    # Write to file
    open(output_file, "w") do f
        write(f, modified_html)
    end
    
    # return "HTML table written to $(output_file)"
end