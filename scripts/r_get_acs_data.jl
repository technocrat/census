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
    r_get_acs_data(; geography::String, variables::Dict{String, String}, state::String,
                 year::Union{Integer, Nothing} = nothing, survey::Union{String, Nothing} = nothing)

Retrieve American Community Survey (ACS) data through R's tidycensus package.

# Arguments
- `geography::String`: Geographic level for data collection (e.g., "county", "tract", "block group")
- `variables::Dict{String, String}`: Dictionary mapping desired variable names to Census variable codes
- `state::String`: State abbreviation (e.g., "MA", "NY")
- `year::Union{Integer, Nothing} = nothing`: Survey year. Defaults based on current date and survey type
- `survey::Union{String, Nothing} = nothing`: Type of ACS survey. Use "acs1" for 1-year estimates,
   nothing for 5-year estimates

# Details
Year defaults are determined by current date and survey type:
- For 1-year ACS (`survey="acs1"`): after September, uses previous year
- For 5-year ACS: after December, uses previous year
- Otherwise uses two years prior

ACS availability notes:
- 1-year estimates (`survey="acs1"`) are only available for geographies with populations ≥ 65,000
- 2020 data is not available for ACS (use get_decennial() instead)
- 1-year and 5-year surveys are published in September and December respectively

# Returns
DataFrame containing requested ACS data

# Examples
```julia
# Get 5-year estimates for counties in Massachusetts
vars = Dict("median_income" => "B19013_001")
df = r_get_acs_data(geography="county", variables=vars, state="MA")

# Get 1-year estimates for 2022
df = r_get_acs_data(geography="county", variables=vars, state="MA",
                  survey="acs1", year=2022)
```
"""
function r_get_acs_data(; geography::String,
                      variables::Dict{String, String},
                      state::String,
                      year::Union{Integer, Nothing} = nothing,
                      survey::Union{String, Nothing} = nothing)

    try
        Census.RSetup.setup_r_environment()
    catch e
        error("Failed to set up R environment: ", sprint(showerror, e))
    end

    # Determine current date for default year logic
    current_date = Dates.now()
    current_year = Dates.year(current_date)
    current_month = Dates.month(current_date)

    # Calculate default year based on current date
    if isnothing(year)
        # After September, 1-year ACS for previous year becomes available
        # After December, 5-year ACS for previous year becomes available
        if current_month >= 9 && !isnothing(survey) && survey == "acs1"
            year = current_year - 1
        elseif current_month >= 12
            year = current_year - 1
        else
            year = current_year - 2
        end
    end

    # Check for 2020 restriction
    if year == 2020
        throw(ArgumentError("ACS is not available for 2020. Use get_decennial() or pick a later year."))
    end

    # Convert Julia Dict to R named vector
    var_names = collect(keys(variables))
    var_codes = collect(values(variables))
    
    # Use proper R string interpolation
    R"""
    r_vars <- setNames(c($(var_codes)), c($(var_names)))
    """

    # Build R function call with proper error handling
    try
        if isnothing(survey)
            R"""
            # Ensure tidycensus is loaded
            library(tidycensus)
            
            # Call R get_acs() with the provided parameters
            data <- get_acs(geography = $(geography),
                          variables = r_vars,
                          state = $(state),
                          year = $(year))
            """
        else
            R"""
            # Ensure tidycensus is loaded
            library(tidycensus)
            
            # Call R get_acs() with the provided parameters including survey
            data <- get_acs(geography = $(geography),
                          variables = r_vars,
                          state = $(state),
                          year = $(year),
                          survey = $(survey))
            """
        end
    catch e
        if isa(e, RCall.REvalError)
            error("R evaluation error: ", sprint(showerror, e))
        else
            rethrow(e)
        end
    end

    # Convert R data frame to Julia DataFrame with error handling
    try
        return rcopy(R"data")
    catch e
        error("Failed to convert R data frame to Julia DataFrame: ", sprint(showerror, e))
    end
end

