#!/usr/bin/env julia

# Disable RCall REPL integration
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import required packages - only Census is needed now since it exports all DataFrames functions
println("Loading Census package...")
using Census

println("Census package loaded successfully!")

# Initialize census data using the exported function from Census module
println("Initializing census data...")
us = init_census_data()
println("Census data loaded: $(nrow(us)) rows")

# Run some basic operations
println("\nRunning some basic operations:")

println("Getting Connecticut data...")
ct = subset(us, :stusps => ByRow(==("CT")))
println("Connecticut counties: $(nrow(ct))")

println("Getting Maine data...")
me = subset(us, :stusps => ByRow(==("ME")))
println("Maine counties: $(nrow(me))")

println("Getting Massachusetts data...")
ma = subset(us, :stusps => ByRow(==("MA")))
println("Massachusetts counties: $(nrow(ma))")

println("Getting New Hampshire data...")
nh = subset(us, :stusps => ByRow(==("NH")))
println("New Hampshire counties: $(nrow(nh))")

println("Getting Rhode Island data...")
ri = subset(us, :stusps => ByRow(==("RI")))
println("Rhode Island counties: $(nrow(ri))")

println("Getting Vermont data...")
vt = subset(us, :stusps => ByRow(==("VT")))
println("Vermont counties: $(nrow(vt))")

println("Getting New York data...")
ny = subset(us, :stusps => ByRow(==("NY")))
println("New York counties: $(nrow(ny))")

println("\nAll operations completed successfully!") 