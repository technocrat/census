function get_and_print_state_pop_html_table(nation::Vector{String})
	output_nation_state_pop_table(make_nation_state_pop_table(nation))
end

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
	mask = [s ∉ ["PR","VI","AS","GU","MP"] for s in us.stusps]
	us = us[mask,:]	
	return(combine(groupby(us, :stusps), :pop => sum => :pop))
end

function make_nation_state_pop_table(nation::Vector{String})
	state_pop = get_state_pop()
	face      = [s in nation for s in state_pop.stusps] 
	masked    = state_pop[face,:]
	s		  = sort(masked,:pop,rev=true)
	d         = format_with_commas(vcat(s,DataFrame(stusps = "Total", pop = sum(s.pop))))
	d.stusps = [state_names[state] for state in d.stusps]	
	return(d)
end

# Highlighter to make the last row bold
hl_last_row_bold = HtmlHighlighter(
	(data, i, j) -> i == size(data, 1), # Condition: if it's the last row
	HtmlDecoration(font_weight = "bold") # Apply bold formatting
)


# Highlighter for alternating row colors
hl_alternating = HtmlHighlighter(
	(data, i, j) -> isodd(i), # Apply to odd rows
	HtmlDecoration(background = "gray", color = "white")
)

# Function to output table with PrettyTables
function output_nation_state_pop_table(tab::DataFrame)
	pretty_table(
		tab,
		backend = Val(:html),
		alignment = [:l, :r],
		show_subheader = false,
		header = ["State", "Population"],
		highlighters = (hl_last_row_bold,hl_alternating)
		)
end
