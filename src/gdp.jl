using CSV, DataFrames, LibPQ
include("cons.jl")
include("fill_state.jl")
gdp = CSV.read("../objs/state_and_county_gdp.csv", DataFrame)
fill_state!(gdp)
rename!(gdp, [:county, :gdp, :flag, :state])
gdp = gdp[gdp.flag, :]
gdp = gdp[:, [1, 2, 4]]
gdp.gdp = gdp.gdp .* 1e3
ne = Ne[[1, 3, 4, 5, 6]]
ne_gdp = gdp[in.(gdp.state, Ref(ne)), :]
ct_gdp = CSV.read("../objs/ct_gdp.csv", DataFrame)
rename!(ct_gdp, [:county, :gdp])
ct_gdp.state = fill("Connecticut", 9)
ne_gdp = vcat(ne_gdp, ct_gdp)
CSV.write("../objs/ne_gdp.csv", ne_gdp)
gdp = gdp[.!in.(gdp.state, Ref(ne)), :]
gdp[2839, 1] = "Richmond City"
gdp = vcat(gdp, ne_gdp)

"""CREATE TABLE gdp (
    county VARCHAR(100) NOT NULL,
    gdp NUMERIC(20, 2) NOT NULL,
    state VARCHAR(50) NOT NULL,
    PRIMARY KEY (county, state)
    );
    CREATE INDEX idx_gdp_state ON gdp(state);"""

conn = LibPQ.Connection("dbname=geocoder")

# Create a prepared statement for insertion
stmt = prepare(conn, "INSERT INTO gdp (county, gdp, state) VALUES (\$1, \$2, \$3)")

# Insert rows from the DataFrame
for row in eachrow(gdp)
    execute(stmt, [row.county, row.gdp, row.state])
end

# Don't forget to close the connection when done
close(conn)


us_gdp         = filter(:state => x -> !(x in outliers), us_gdp)
conus_gdp      = filter(:state => x -> !(x in ["AK","HI"]), us_gdp)
concord    = ["CT", "MA", "ME", "NH", "RI", "VT"]
us_gdp.nation  .= ifelse.(in.(:state, Ref(concord)), "concord", us_gdp.nation)
metropolis = ["DE", "MD","NY","NJ","VA","DC"]
us_gdp.nation .= ifelse.(in.(:state, Ref(metropolis)), "metropolis", us_gdp.nation)
factoria   = ["PA", "OH", "MI", "IN", "IL", "WI"]
us_gdp.nation .= ifelse.(in.(:state, Ref(factoria)), "factoria", us_gdp.nation)
lonestar   = ["TX","OK","AR","LA"]
us_gdp.nation .= ifelse.(in.(:state, Ref(lonestar)), "lonestar", us_gdp.nation)
dixie      = ["NC", "SC", "FL", "GA","MS","AL"]
us_gdp.nation .= ifelse.(in.(:state, Ref(dixie)), "dixie", us_gdp.nation)
cumber     = ["WV","KY","TN"]
us_gdp.nation .= ifelse.(in.(:state, Ref(cumber)), "cumber", us_gdp.nation)
heartland  = ["MN","IA","NE", "ND", "SD", "KS", "MO"]
us_gdp.nation .= ifelse.(in.(:state, Ref(heartland)), "heartland", us_gdp.nation)
desert     = ["UT","MT","WY", "CO", "ID"]
us_gdp.nation .= ifelse.(in.(:state, Ref(desert)), "desert", us_gdp.nation)
pacific     = ["WA","OR","AK"]
us_gdp.nation .= ifelse.(in.(:state, Ref(pacific)), "pacific", us_gdp.nation)
sonora     = ["CA","AZ","NM","NV","HI"]
us_gdp.nation .= ifelse.(in.(:state, Ref(sonora)), "sonora", us_gdp.nation)

# First, create the reverse lookup dictionary
reverse_state_names = Dict(value => key for (key, value) in state_names)

# Create a function to determine which region a state belongs to
function get_nation(state_abbr)
    if state_abbr in concord
        return "concord"
    elseif state_abbr in metropolis
        return "metropolis"
    elseif state_abbr in factoria
        return "factoria"
    elseif state_abbr in pacific
        return "pacifica"
    elseif state_abbr in lonestar
        return "lonestar"
    elseif state_abbr in dixie
        return "dixie"
    elseif state_abbr in cumber
        return "cumber"
    elseif state_abbr in heartland
        return "heartland"
    elseif state_abbr in sonora
        return "sonora"
    elseif state_abbr in desert
        return "desert"
    else
        return "Unknown"
    end
end

# Apply this to create the new column
us_gdp.nation = map(state -> begin
    # Get the abbreviation
    abbr = get(reverse_state_names, state, nothing)
    # Return the nation
    abbr === nothing ? "Unknown" : get_nation(abbr)
end, us_gdp.state)

nation_gdp = combine(groupby(us_gdp, :nation), :gdp => sum => :gdp))

# https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
world_gdp = CSV.read("../data/world_gdp.csv",DataFrame)
world_gdp = world_gdp[:,[1,68]]
rename!(world_gdp,[:nation,:gdp23])
dropmissing!(world_gdp, :gdp23)
filter!(row -> row.gdp23 >= 6e11, world_gdp)
# filter(row -> row.gdp23 <= 1e13, world_gdp)
