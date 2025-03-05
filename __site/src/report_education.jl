function report_education(nation_stats::DataFrame, nations::Vector{Vector{String}}, titles::Vector{String},	base_path::String="../_layout/partials/")
	for nation in Titles
		grab 	=  filter(:Nation => (x -> x == nation), nation_stats)
		print("<p>In terms of educational attainment, " * grab[1,2] * " of the population has a college degree, of which " * grab[1,3] *" are graduate-level degrees.</p>")
		# Create the output file path
		output_file = joinpath(base_path, "$(nation)_education_sentence	.html")
		# Write to file
		open(output_file, "w") do f
				write(f, modified_html)
		end
	end
end


function report_education(nation_stats::DataFrame, Titles::Vector{String}, base_path::String="../_layout/partials/")
	for nation in Titles
		grab = filter(:Nation => (x -> x == nation), nation_stats)
		
		# Create the HTML content
		html_content = "<p>In terms of educational attainment, " * grab[1,2] * " of the population has a college degree, of which " * grab[1,3] * " are graduate-level degrees.</p>"
		
		# Create the output file path
		output_file = joinpath(base_path, "$(nation)_education_sentence.html")
		
		# Write to file
		open(output_file, "w") do f
			write(f, html_content)
		end
	end
end


function report_education(
	stats::DataFrame 		= nation_stats, 
	titles::Vector{String} 	= Titles,
	base_path::String 		= "../_layout/partials/"
)
	# Create directory if it doesn't exist
	mkpath(base_path)
	
	for nation in titles
		# Find matching data
		matching_rows = filter(:Nation => (x -> x == nation), nation_stats)
		
		# Skip if no matching data found
		isempty(matching_rows) && continue
		
		# Create the HTML content
		html_content = "<p>In terms of educational attainment, " * matching_rows[1, :Pop_w_College_pct] * 
						" of the population has a college degree, of which " * 
						matching_rows[1, :Pop_w_GRAD_pct] * " are graduate-level degrees.</p>"
						
		# Create the output file path (removing spaces)
		output_file = joinpath(base_path, "$(replace(nation, " " => "_"))_education_sentence.html")
		
		# Write to file
		open(output_file, "w") do f
			write(f, html_content)
		end
		
		# Provide feedback
		println("Created file: $output_file")
	end
end