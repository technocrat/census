# SPDX-License-Identifier: MIT

function get_state_pop()
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
	mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]
	us = us[mask,:]	
	return(combine(groupby(us, :stusps), :pop => sum => :pop))
end
