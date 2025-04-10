# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

"""
Connecticut GDP Processing Module

This module processes Connecticut GDP data by planning region, using county-level GDP data
and population-based allocation factors to distribute GDP across planning regions.

# Dependencies
- Census: Custom package for Census data processing
- CSV: File I/O for CSV files
- DataFrames: Data manipulation and analysis
- Statistics: Statistical operations

# Files Used
- Input: 
  - obj/state_and_county_gdp.csv: County-level GDP data
  - data/connecticut_crosswalk.csv: Planning region definitions and allocation factors
- Output:
  - obj/ct_gdp.csv: Processed GDP by planning region
"""

using CSV
using Statistics

"""
    process_connecticut_gdp()

Process Connecticut GDP data by planning region.

# Processing Steps
1. Reads county-level GDP data from state_and_county_gdp.csv
2. Filters for Connecticut counties
3. Joins with planning region crosswalk data
4. Aggregates GDP by planning region using population-based allocation factors
5. Writes results to ct_gdp.csv in the objects directory

# Returns
- `DataFrame`: Contains columns:
  - `region::String`: Planning region name
  - `gdp::Float64`: GDP allocated to region

# Notes
- GDP values are in thousands of dollars
- Uses population-based allocation factors from connecticut_crosswalk.csv

# Examples
```julia
# Process GDP data and get results
region_gdp = process_connecticut_gdp()

# Access GDP for a specific region
hartford_gdp = region_gdp[region_gdp.region .== "Hartford", :gdp]
```
"""
function process_connecticut_gdp()
    # Get project root directory
    project_root = dirname(dirname(@__FILE__))

    # Read and process county GDP data

    Census.fill_state!(ct_counties)
    ct_counties = filter(:state => x -> x == "Connecticut", ct_counties)
    ct_counties = ct_counties[:, 1:2]
    ct_counties.GDPas2017 = ct_counties.GDPas2017 * 1e3
    rename!(ct_counties, [:county, :gdp])

    # Read and process planning region crosswalk
    crosswalk = CSV.read(joinpath(project_root, "data", "geocorr2022_2508901340.csv"), DataFrame)
    deleteat!(crosswalk, 1)  # Remove redundant header row
    crosswalk = CSV.read(joinpath(project_root, "data", "connecticut_crosswalk.csv"), DataFrame)
    rename!(crosswalk, [:id1, :id2, :county, :region, :pop20, :afact])
    crosswalk.county = [s[1:end-3] for s in crosswalk.county]
    crosswalk.region = transform(crosswalk, :region => ByRow(x -> replace(x, " Planning Region" => "")) => :region).region

    # Join and aggregate by region
    joined = leftjoin(crosswalk, ct_counties, on = :county)
    region_gdp = combine(groupby(joined, :region)) do group
        (region = first(group.region),
         gdp = sum(group.gdp .* group.afact))
    end

    # Write results
    CSV.write(joinpath(project_root, "obj", "ct_gdp.csv"), region_gdp)
    return region_gdp
end

# Execute the processing
process_connecticut_gdp()
