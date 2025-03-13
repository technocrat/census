function report_polarization(recently::DataFrame, historical::DataFrame, 
							 nations::Vector{Vector{String}} = nations, 
							 titles::Vector{String} = Titles,	
							 base_path::String="../_layout/partials/")
	for nation in Titles
		grab 	=  filter(:nation => (x -> x == nation), recently)
		print("<p>Politcal polarization of " * grab[1,1] * ", as measured by the 
			margin between votes for the two major party political nominees, was "
			* grab[1,7] * " in the 2024 election. ")
		grab 	=  filter(:nation => (x -> x == nation), historical)
		print("<p>Politcal polarization of " * grab[1,1] * ", as measured by the 
			margin between votes for the two major party political nominees, was "
			* grab[1,7] * " over the elections from 1968-2020.</p>")
		# Create the output file path
		output_file = joinpath(base_path, "$(nation)_polarization_sentence.html")
		# Write to file
		open(output_file, "w") do f
				write(f, modified_html)
		end
	end
end