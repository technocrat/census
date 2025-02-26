function get_and_print_state_pop_html(nation::Vector{String})
	geo_query = """
		SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as pop
		FROM census.counties us
		LEFT JOIN census.variable_data vd
			ON us.geoid = vd.geoid
			AND vd.variable_name = 'total_population'
	"""
	us = q(geo_query)
	
	us = dropmissing(us, :nation)
	sort!(us,[:nation,:stusps])
	mask = [s ∉ ["PR","VI","AS","GU","MP"] for s in us.stusps]
	us = us[mask,:]	
	state_pop  = combine(groupby(us, :stusps), :pop => sum => :pop)
	print_state_pop(nation)
end
