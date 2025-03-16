include("setup.jl")
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

