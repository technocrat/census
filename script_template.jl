#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import the Census module which exports all needed functions
using Census

# Your script code starts here
# ...

# Example usage:
us = init_census_data()

# Filter to specific states
example_state = subset(us, :stusps => ByRow(==("NY")))

# Display results
println("Found $(nrow(example_state)) counties in example state") 