
@load "../data/per_capita.bson" df
#   @load "dc.bson"  dc DC has missing for df.tier
#df = vcat(df,dc)
df_subset = df[in.(df.po, Ref(STATES)), :]

# Create numeric values from tiers for the colorscale
data_values = map(x -> findfirst(==(x), TIERS),
                  df_subset.tier)

# Create the choropleth trace
data = choropleth(
    locations    = STATES,
    z            = data_values,
    locationmode ="USA-states"
)

trace = choropleth(
    locations    = df_subset.po,
    z=data_values,
    locationmode = "USA-states",
    colorscale   = COLORSCALE,
    colorbar     = attr(
        title    = "Tier",
        ticktext = TIERS,
        tickvals = 1:length(TIERS),
        tickmode = "array"
    ),
    text         = [string(po, ": ", tier) for (po, tier) in zip(df_subset.po, df_subset.tier)],
    hoverinfo    = "text"
)

layout = Layout(
    title          = "$nation GDP per Capita by State",
    geo=attr(
        scope      = "usa",
        projection = attr(type="albers usa"),
        showlakes  = true,
        lakecolor  = "rgb(255, 255, 255)",
        fitbounds  = "locations",
        xaxis      = attr(showgrid=false),  # Disable gridlines on the x-axis
        yaxis      = attr(showgrid=false),   # Disable gridlines on the y-axis
        legend     = attr(orientation="h") # Set legend orientation to horizontal
    )
)

p        = PlotlyJS.plot(trace, layout)
PlotlyJS.savefig(p, "concordia.svg") # positional order mandatory

ne       = (df_subset[:, [:State, :GDP2Q24, :pop, :ratio]])
ne.ratio = ne.ratio .* 1e6

# Calculate totals
total_gdp   = sum(ne.GDP2Q24)
total_pop   = sum(ne.pop)
total_ratio = total_gdp / total_pop * 1e6

# Create a new row with totals
total_row         = DataFrame(State="Total", GDP2Q24=total_gdp, pop=total_pop, ratio=total_ratio)
total_row.GDP2Q24 = format.(Int.(round.(total_row.GDP2Q24)), commas=true)
total_row.pop     = format.(Int.(round.(total_row.pop)), commas=true)
total_row.ratio   = format.(Int.(round.(total_row.ratio)), commas=true)

dsub              = format_with_commas(ne)
dc                = format_with_commas(total_row)
ne                = vcat(dsub, dc)
ne.GDP2Q24        = format.(Int.(round.(ne.GDP2Q24)), commas=true)
ne.pop            = format.(Int.(round.(ne.pop)), commas=true)
ne.ratio          = format.(Int.(round.(ne.ratio)), commas=true)

# Append the totals row to the original DataFrame
ne         = vcat(dsub, total_row)
rename!(ne, [:State, :GDP, :Population, :PerCapita])
headers    = names(dsub)
headers[2] = "GDP (000,000)"
headers[4] = "GDP per capita"

pretty_table(ne, header=headers,
    backend        = Val(:text),
    alignment      = [:l, :r, :r, :r],
    show_subheader = false)

# Now plot with the parsed geometries
poly!(
    ga1,
    parsed_geometries,
    color=joined_data.pop_bins,
    colormap=map_colors,
    strokecolor=(:black, 0.5),
    strokewidth=1
    )


fig

ga2 = GeoAxis(
    fig[1,2],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County GDP",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

# Makie.available_gradients
# https://docs.makie.org/stable/explanations/colors

# Now plot with the parsed geometries
poly!(
    ga2,
    parsed_geometries,
    color=joined_data.gdp_bins,
    colormap=map_colors,
    strokecolor=(:black, 0.5),
    strokewidth=1
)

ga3 = GeoAxis(
    fig[1,3],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County Population",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

# Makie.available_gradients
# https://docs.makie.org/stable/explanations/colors

# Now plot with the parsed geometries
poly!(
    ga3,
    parsed_geometries,
    #color=segments[3],
    colormap=:lighttemperaturemap,
    strokecolor=(:black, 0.5),
    strokewidth=1
)
ga4= GeoAxis(
    fig[2,1],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County GDP",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

# Makie.available_gradients
# https://docs.makie.org/stable/explanations/colors

# Now plot with the parsed geometries
poly!(
    ga4,
    parsed_geometries,
    color=segments[4],
    colormap=:lighttemperaturemap,
    strokecolor=(:black, 0.5),
    strokewidth=1
)


ga5 = GeoAxis(
    fig[2,2],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County Population",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

# Makie.available_gradients
# https://docs.makie.org/stable/explanations/colors

# Now plot with the parsed geometries
poly!(
    ga5,
    parsed_geometries,
    color=segments[5],
    colormap=:lighttemperaturemap,
    strokecolor=(:black, 0.5),
    strokewidth=1
)
ga6= GeoAxis(
    fig[2,3],
    source="+proj=longlat +datum=WGS84",
    dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
    title="New England County GDP",
    xlabel="",
    ylabel="",
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false
)

# Makie.available_gradients
# https://docs.makie.org/stable/explanations/colors

# Now plot with the parsed geometries
poly!(
    ga6,
    parsed_geometries,
    color=segments[6],
    colormap=:lighttemperaturemap,
    strokecolor=(:black, 0.5),
    strokewidth=1
)
fig
#!/usr/bin/sh
# 2015 dollars world GPD
    "https://api.worldbank.org/v2/en/indicator/NY.GDP.MKTP.KD?downloadformat=csv"
world_gdp = CSV.read(HTTP.get(url).body, DataFrame)
(echo "country_name,country_code,gdp_2022" &&
awk -F',' '
NR>1 {
        year_2022_col = NF-1;
        gsub(/"/, "", $1);  # Remove quotes from country name
        gsub(/"/, "", $2);  # Remove quotes from country code
        gsub(/"/, "", $year_2022_col);  # Remove quotes from 2022 value
        if ($year_2022_col != "" && $year_2022_col != "," && length($year_2022_col) > 0) {
                printf "%s,%s,%.0f\n", $1, $2, $year_2022_col
        }
}' API_NY.GDP.MKTP.KD_DS2_en_csv_v2_8.csv) > world_gdp.csv\
2022 chained 2015
https://data.worldbank.org/indicator/NY.GDP.MKTP.KD
https://fred.stlouisfed.org/series/NENGNQGSP
https://www.bostonfed.org/Home.aspx
# 2Q24 chained 2017
https://www.bea.gov/sites/default/files/2024-12/lagdp1224.xlsx
    230 │ United States                      USA            22062578283267  2.20626e13
    julia> us_gdp_tot + sum(ne_gdp.gdp)
2.26669026101503e13
"""
            
imports = DataFrame(
    ['State', 'Imports_2024_USD'],
    ['Connecticut', 22738278189],
    ['Maine', 6734020743],
    ['Massachusetts', 43251667099],
    ['New Hampshire', 10206029191],
    ['Rhode Island', 11144208174],
    ['Vermont', 3526169507]
)

            
awk -F, 'BEGIN {OFS=","} {for(i=1;i<=NF;i++) if(i==1 || i==2 || $i ~ /M"$/) printf "%s%s", $i, (i==NF?"\n":",")}' county_ages.csv > county_ages_filtered.csv && mv county_ages_filtered.csv county_ages.csv
            
[U.S. Census Bureau, U.S. Department of Commerce. "Sex by Age." American Community Survey, ACS 5-Year Estimates Detailed Tables, Table B01001, 2023](https://data.census.gov/table/ACSDT5Y2023.B01001?y=2023&d=ACS 5-Year Estimates Detailed Tables). Accessed on February 6, 2025.
            
for row in eachrow(df)
    geoid = row[:geoid]
    name = row[:name]
            
    for variable in new_variables
        value = row[variable]
        variable_name = String(variable)  # Convert Symbol to String if necessary
            
        # Construct and execute the SQL INSERT query
        query = """
            INSERT INTO census.variable_data (geoid, variable_name, value, name)
            VALUES (\$1, \$2, \$3, \$4)
        """
        execute(conn, query, (geoid, variable_name, value, name))
    end
end
            