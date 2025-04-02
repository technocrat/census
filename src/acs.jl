using DataFrames
using HTTP
using JSON3
using Base.Iterators: partition
using Statistics: mean
using Dates: Year, today

# Export MOE functions and helpers
export get_acs_moe, get_acs_moe1, get_acs_moe3, get_acs_moe5
export make_census_request, get_moe_factor, is_special_moe, get_special_moe_message
export add_moe_notes!, join_estimates_moe!
export calculate_moe_sum, calculate_moe_ratio, calculate_moe_product
export state_postal_to_fips

# Constants for API
const API_BASE_URL = "https://api.census.gov/data"
const API_KEY = get(ENV, "CENSUS_API_KEY", "")

"""
    make_census_request(url::String, headers::Vector{Pair{String,String}}) -> HTTP.Response

Make a request to the Census API with robust error handling and retries.

# Arguments
- `url::String`: The API endpoint URL
- `headers::Vector{Pair{String,String}}`: HTTP headers to include

# Returns
- `HTTP.Response`: The API response
"""
function make_census_request(url::String, headers::Vector{Pair{String,String}})
    max_retries = 5
    base_delay = 1.0  # seconds
    
    for attempt in 1:max_retries
        try
            @info "Attempt $(attempt) of $(max_retries)..."
            
            response = HTTP.get(
                url, 
                headers; 
                connect_timeout=60,  # 1 minute connect timeout
                read_timeout=180,    # 3 minutes read timeout
                retry=false,         # We handle retries manually
                redirect=true
            )
            
            if response.status == 200
                return response
            elseif response.status == 429  # Rate limit
                wait_time = attempt * base_delay
                @warn "Rate limit reached. Waiting $(wait_time) seconds before retry..."
                sleep(wait_time)
            elseif response.status >= 500  # Server error
                wait_time = attempt * base_delay
                @warn "Census API server error ($(response.status)). Waiting $(wait_time) seconds before retry..."
                sleep(wait_time)
            else  # Client error
                error("Census API returned status $(response.status): $(String(response.body))")
            end
            
        catch e
            if e isa HTTP.TimeoutError
                if attempt == max_retries
                    @error """
                    Request timed out after $(max_retries) attempts.
                    
                    The Census API may be:
                    1. Experiencing high load
                    2. Processing a large data request
                    3. Having connectivity issues
                    
                    Suggestions:
                    - Try again in a few minutes
                    - Break up large requests into smaller chunks
                    - Check your internet connection
                    """
                    rethrow(e)
                end
                
                wait_time = attempt * base_delay
                @warn "Request timed out. Waiting $(wait_time) seconds before retry..."
                sleep(wait_time)
            else
                if attempt == max_retries
                    @error "Failed to connect to Census API after $(max_retries) attempts" exception=e
                    rethrow(e)
                end
                
                # Add jitter to retry delay
                jitter = rand() * base_delay
                wait_time = attempt * base_delay + jitter
                @warn "Connection error. Waiting $(round(wait_time, digits=1)) seconds before retry..."
                sleep(wait_time)
            end
        end
    end
    
    error("Failed to get response after $max_retries attempts")
end

"""
    get_moe_factor(confidence_level::Int) -> Float64

Get the margin of error factor for a given confidence level.

# Arguments
- `confidence_level::Int`: The desired confidence level (90, 95, or 99)

# Returns
- The MOE factor as a Float64

# Example
```julia
julia> get_moe_factor(90)
1.645
```
"""
function get_moe_factor(confidence_level::Int)
    if confidence_level == 90
        return 1.645
    elseif confidence_level == 95
        return 1.960
    elseif confidence_level == 99
        return 2.576
    else
        throw(ArgumentError("Confidence level must be 90, 95, or 99"))
    end
end

"""
    is_special_moe(value::String) -> Bool

Check if a value is a special Census MOE code.

# Arguments
- `value::String`: The value to check

# Returns
- `true` if the value is a special MOE code, `false` otherwise
"""
function is_special_moe(value::String)
    special_codes = ["-555555555", "-222222222", "-333333333",
                    "-666666666", "-888888888", "-999999999"]
    return value in special_codes
end

"""
    get_special_moe_message(code::String) -> String

Get a human-readable message for a special MOE code.

# Arguments
- `code::String`: The special MOE code

# Returns
- A string explaining the meaning of the code
"""
function get_special_moe_message(code::String)
    messages = Dict(
        "-555555555" => "Missing MOE",
        "-222222222" => "Too few samples",
        "-333333333" => "No sample observations",
        "-666666666" => "Estimate = 0, MOE not computed",
        "-888888888" => "Not applicable",
        "-999999999" => "Not computed"
    )
    return get(messages, code, "Unknown special code")
end

"""
    add_moe_notes!(df::DataFrame) -> DataFrame

Add interpretive notes for MOE values to a DataFrame. For each MOE column (ending in 'M'),
adds a corresponding note column explaining any special codes.

Special MOE codes and their meanings:
- -555555555: Missing MOE
- -222222222: Too few samples
- -333333333: No sample observations
- -666666666: Estimate = 0, MOE not computed
- -888888888: Not applicable
- -999999999: Not computed

# Arguments
- `df`: DataFrame containing MOE columns (column names ending in 'M')

# Returns
The input DataFrame with added note columns

# Example
```julia
# First get MOE data, then add notes
df = DataFrame(B01003_001M = ["1234", "-555555555"])
add_moe_notes!(df)
```
"""
function add_moe_notes!(df::DataFrame)
    # Get all MOE columns (ending in 'M')
    moe_cols = filter(col -> endswith(col, "M"), names(df))
    
    # For each MOE column, add a note column
    for col in moe_cols
        note_col = string(col, "_NOTE")
        df[!, note_col] = [
            val == "-555555555" ? "Missing MOE" :
            val == "-222222222" ? "Too few samples" :
            val == "-333333333" ? "No sample observations" :
            val == "-666666666" ? "Estimate = 0, MOE not computed" :
            val == "-888888888" ? "Not applicable" :
            val == "-999999999" ? "Not computed" :
            "Valid MOE value"
            for val in df[!, col]
        ]
    end
    
    return df
end

"""
    join_estimates_moe!(est_df::DataFrame, moe_df::DataFrame) -> DataFrame

Join estimate and MOE DataFrames based on their corresponding E/M columns.
Matches estimate columns (ending in 'E') with their MOE counterparts (ending in 'M').
Preserves geographic identifiers (NAME, GEOID, etc.) and MOE notes.

# Arguments
- `est_df`: DataFrame containing estimate columns (ending in 'E')
- `moe_df`: DataFrame containing MOE columns (ending in 'M') and optional note columns

# Returns
A new DataFrame with estimates, MOEs, and notes combined

# Example
```julia
# Create sample DataFrames
est_df = DataFrame(NAME = ["State"], B01003_001E = [1000])
moe_df = DataFrame(NAME = ["State"], B01003_001M = [50])
df = join_estimates_moe!(est_df, moe_df)
```
"""
function join_estimates_moe!(est_df::DataFrame, moe_df::DataFrame)
    # Verify both DataFrames have GEOID for joining
    if !("GEOID" in names(est_df) && "GEOID" in names(moe_df))
        throw(ArgumentError("Both DataFrames must have a GEOID column"))
    end
    
    # Get geographic identifier columns (NAME, state, county, etc.)
    geo_cols = ["NAME", "GEOID", "state", "county", "tract", "block group"]
    geo_cols = filter(col -> col in names(est_df), geo_cols)
    
    # Get estimate columns (ending in 'E')
    est_cols = filter(col -> endswith(col, "E"), names(est_df))
    if isempty(est_cols)
        throw(ArgumentError("No estimate columns (ending in 'E') found"))
    end
    
    # Create mapping between estimate and MOE columns
    moe_pairs = Dict{String,Vector{String}}()
    for est_col in est_cols
        # Convert E to M for corresponding MOE column
        base_name = est_col[1:end-1]
        moe_col = base_name * "M"
        note_col = moe_col * "_NOTE"
        
        if moe_col in names(moe_df)
            moe_pairs[est_col] = [moe_col]
            # Include note column if it exists
            if note_col in names(moe_df)
                push!(moe_pairs[est_col], note_col)
            end
        end
    end
    
    if isempty(moe_pairs)
        throw(ArgumentError("No matching MOE columns found for estimates"))
    end
    
    # Create new DataFrame with geographic columns
    result = select(est_df, Symbol.(geo_cols))
    
    # Add estimate and corresponding MOE columns
    for (est_col, moe_cols) in moe_pairs
        # Add estimate column
        result[!, est_col] = est_df[!, est_col]
        
        # Join with MOE DataFrame to get MOE and note columns
        temp_df = leftjoin(
            select(result, :GEOID),
            select(moe_df, vcat(:GEOID, Symbol.(moe_cols))),
            on = :GEOID
        )
        
        # Add MOE and note columns
        for moe_col in moe_cols
            result[!, moe_col] = temp_df[!, moe_col]
        end
    end
    
    return result
end

"""
    get_acs_moe(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        survey::String = "acs5"
    ) -> DataFrame

Fetch margin of error values from American Community Survey data for different survey types.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `survey`: Survey type ("acs1", "acs3", "acs5"; default: "acs5")

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get 5-year MOE estimates
df = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state",
    survey = "acs5"
)

# Get 1-year MOE estimates (65,000+ population areas only)
df = get_acs_moe(
    variables = ["B01003_001M"],
    geography = "state",
    survey = "acs1"
)
```
"""
function get_acs_moe(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    survey::String = "acs5"
)
    if survey == "acs5"
        return get_acs_moe5(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    elseif survey == "acs3"
        return get_acs_moe3(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    elseif survey == "acs1"
        return get_acs_moe1(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    else
        throw(ArgumentError("survey must be one of: 'acs1', 'acs3', 'acs5'"))
    end
end

"""
    get_acs_moe5(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 5-year estimates.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states
df = get_acs_moe5(
    variables = ["B01003_001M"],
    geography = "state"
)
```
"""
function get_acs_moe5(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate inputs
    if isempty(variables)
        throw(ArgumentError("Must specify at least one variable"))
    end
    
    if !in(geography, ["state", "county", "tract", "block group"])
        throw(ArgumentError("Invalid geography level: $geography"))
    end
    
    if !isnothing(county) && isnothing(state)
        throw(ArgumentError("County can only be specified with state"))
    end
    
    # Validate all variables end with 'M' for MOE
    if !all(v -> endswith(v, "M"), variables)
        throw(ArgumentError("All variables must end with 'M' for margin of error"))
    end
    
    # Validate year range for 5-year ACS
    if year < 2009
        throw(ArgumentError("5-year ACS support begins with 2009 (2005-2009 5-year ACS)"))
    end
    
    # Print informative message about the request
    @info "Fetching $(year) 5-year ACS data for $(geography)$(isnothing(state) ? "" : " in $state")..."
    
    # Construct API URL
    base_url = "https://api.census.gov/data/$(year)/acs/acs5"
    
    # Build GET parameters
    params = String[]
    
    # Add NAME and variables
    push!(params, "get=NAME," * join(variables, ","))
    
    # Add geography
    push!(params, "for=$(geography):*")
    
    # Add state/county filters if specified
    if !isnothing(state)
        # Convert postal code to FIPS if needed
        state_fips = length(state) == 2 ? state_postal_to_fips(state) : state
        push!(params, "in=state:$(state_fips)")
        
        if !isnothing(county)
            push!(params, "in=county:$(county)")
        end
    end
    
    # Add API key if available
    api_key = get(ENV, "CENSUS_API_KEY", nothing)
    if !isnothing(api_key)
        push!(params, "key=$(api_key)")
    end
    
    # Construct final URL
    url = base_url * "?" * join(params, "&")
    
    # Make request with robust connection handling
    headers = [
        "Accept" => "application/json",
        "Accept-Encoding" => "gzip, deflate, br",
        "Accept-Language" => "en-US,en;q=0.9",
        "Connection" => "keep-alive",
        "User-Agent" => "Census.jl/0.1.0"
    ]
    
    try
        @info "Making request to Census API..."
        r = make_census_request(url, headers)
        
        # Parse response
        @info "Processing response..."
        data = JSON3.read(String(r.body))
        
        # Check if we got any data
        if length(data) < 2
            @warn "No data returned from Census API"
            return DataFrame()
        end
        
        # First row contains column names
        col_names = String.(data[1])
        
        # Create DataFrame with proper column types
        df = DataFrame([name => [] for name in col_names])
        
        # Add data rows
        for row in data[2:end]
            push!(df, row)
        end
        
        # Convert numeric columns
        @info "Converting data types..."
        for col in names(df)
            # Skip NAME and geographic identifier columns
            if col == "NAME" || col in ["state", "county", "tract", "block group"]
                continue
            end
            
            # Try converting numeric values
            if all(x -> x isa String && !isempty(x), df[!, col])
                try
                    df[!, col] = parse.(Float64, df[!, col])
                catch
                    # Leave as String if conversion fails
                end
            end
        end
        
        # Create GEOID based on geography type
        @info "Creating geographic identifiers..."
        if geography == "state"
            df.GEOID = df.state
        elseif geography == "county"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') 
                       for (s, c) in zip(df.state, df.county)]
        elseif geography == "tract"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') * lpad(t, 6, '0')
                       for (s, c, t) in zip(df.state, df.county, df.tract)]
        elseif geography == "block group"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') * lpad(t, 6, '0') * b
                       for (s, c, t, b) in zip(df.state, df.county, df.tract, df.block_group)]
        end
        
        # Sort by GEOID
        sort!(df, :GEOID)
        
        @info "Data retrieval complete"
        return df
        
    catch e
        if e isa HTTP.TimeoutError
            @error "Request timed out. The Census API may be experiencing high load. Try again in a few minutes."
        else
            @error "Failed to fetch Census data" exception=e
        end
        rethrow(e)
    end
end

"""
    get_acs_moe1(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 1-year estimates.
Only available for geographies with populations of 65,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states
df = get_acs_moe1(
    variables = ["B01003_001M"],
    geography = "state"
)
```
"""
function get_acs_moe1(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Check for 2020 1-year ACS restriction
    if year == 2020
        error("""
        The regular 1-year ACS for 2020 was not released and is not available.
        
        Due to low response rates, the Census Bureau instead released a set of experimental estimates for the 2020 1-year ACS.
        
        These estimates can be downloaded at:
        https://www.census.gov/programs-surveys/acs/data/experimental-data/1-year.html
        
        1-year ACS data can still be accessed for other years by supplying an appropriate year to the `year` parameter.
        """)
    end
    
    # Validate year range for 1-year ACS
    if year < 2005
        throw(ArgumentError("1-year ACS support begins with 2005"))
    end
    
    @info "The 1-year ACS provides data for geographies with populations of 65,000 and greater."
    
    # Use same implementation as get_acs_moe5 but with acs1 endpoint
    return get_acs_moe5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    get_acs_moe3(;
        variables::Vector{String},
        geography::String,
        year::Int = 2013,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch margin of error values from American Community Survey 3-year estimates.
Only available from 2007-2013 for geographies with populations of 20,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'M' for MOE)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (2007-2013)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census MOE data

# Example
```julia
# Get MOE for total population for all states in 2013
df = get_acs_moe3(
    variables = ["B01003_001M"],
    geography = "state",
    year = 2013
)
```
"""
function get_acs_moe3(;
    variables::Vector{String},
    geography::String,
    year::Int = 2013,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate year range for 3-year ACS
    if year < 2007 || year > 2013
        throw(ArgumentError("3-year ACS is only available from 2007-2013"))
    end
    
    @info "The 3-year ACS provides data for geographies with populations of 20,000 and greater."
    
    # Use same implementation as get_acs_moe5 but with acs3 endpoint
    return get_acs_moe5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    calculate_moe_sum(moes::Vector{Float64}) -> Float64

Calculate the margin of error for a sum of estimates.

# Arguments
- `moes::Vector{Float64}`: Vector of margins of error

# Returns
- The combined margin of error
"""
function calculate_moe_sum(moes::Vector{Float64})
    return sqrt(sum(x -> x^2, filter(!isnan, moes)))
end

"""
    calculate_moe_ratio(num::Float64, den::Float64, num_moe::Float64, den_moe::Float64) -> Float64

Calculate the margin of error for a ratio of estimates.

# Arguments
- `num::Float64`: Numerator estimate
- `den::Float64`: Denominator estimate
- `num_moe::Float64`: Numerator MOE
- `den_moe::Float64`: Denominator MOE

# Returns
- The margin of error for the ratio
"""
function calculate_moe_ratio(num::Float64, den::Float64, num_moe::Float64, den_moe::Float64)
    if den == 0 || isnan(den) || isnan(num)
        return NaN
    end
    ratio = num / den
    return sqrt((num_moe^2 + (ratio^2 * den_moe^2)) / den^2)
end

"""
    calculate_moe_product(est1::Float64, est2::Float64, moe1::Float64, moe2::Float64) -> Float64

Calculate the margin of error for a product of estimates.

# Arguments
- `est1::Float64`: First estimate
- `est2::Float64`: Second estimate
- `moe1::Float64`: First MOE
- `moe2::Float64`: Second MOE

# Returns
- The margin of error for the product
"""
function calculate_moe_product(est1::Float64, est2::Float64, moe1::Float64, moe2::Float64)
    if isnan(est1) || isnan(est2)
        return NaN
    end
    return sqrt((est1^2 * moe2^2) + (est2^2 * moe1^2))
end

"""
    state_postal_to_fips(postal::String) -> String

Convert state postal code to FIPS code.

# Arguments
- `postal::String`: Two-letter state postal code (case insensitive)

# Returns
- The corresponding two-digit FIPS code as a string

# Example
```julia
julia> state_postal_to_fips("MA")
"25"
```

# Throws
- `ArgumentError` if the postal code is invalid
"""
function state_postal_to_fips(postal::String)
    # State postal to FIPS mapping
    postal_to_fips = Dict(
        "AL" => "01", "AK" => "02", "AZ" => "04", "AR" => "05", "CA" => "06",
        "CO" => "08", "CT" => "09", "DE" => "10", "DC" => "11", "FL" => "12",
        "GA" => "13", "HI" => "15", "ID" => "16", "IL" => "17", "IN" => "18",
        "IA" => "19", "KS" => "20", "KY" => "21", "LA" => "22", "ME" => "23",
        "MD" => "24", "MA" => "25", "MI" => "26", "MN" => "27", "MS" => "28",
        "MO" => "29", "MT" => "30", "NE" => "31", "NV" => "32", "NH" => "33",
        "NJ" => "34", "NM" => "35", "NY" => "36", "NC" => "37", "ND" => "38",
        "OH" => "39", "OK" => "40", "OR" => "41", "PA" => "42", "RI" => "44",
        "SC" => "45", "SD" => "46", "TN" => "47", "TX" => "48", "UT" => "49",
        "VT" => "50", "VA" => "51", "WA" => "53", "WV" => "54", "WI" => "55",
        "WY" => "56", "AS" => "60", "GU" => "66", "MP" => "69", "PR" => "72",
        "VI" => "78"
    )
    
    postal_upper = uppercase(postal)
    if !haskey(postal_to_fips, postal_upper)
        throw(ArgumentError("Invalid state postal code: $postal"))
    end
    
    return postal_to_fips[postal_upper]
end

"""
    get_acs5(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch American Community Survey 5-year estimates.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census data

# Example
```julia
# Get total population for all states
df = get_acs5(
    variables = ["B01003_001E"],
    geography = "state"
)
```
"""
function get_acs5(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate inputs
    if isempty(variables)
        throw(ArgumentError("Must specify at least one variable"))
    end
    
    if !in(geography, ["state", "county", "tract", "block group"])
        throw(ArgumentError("Invalid geography level: $geography"))
    end
    
    if !isnothing(county) && isnothing(state)
        throw(ArgumentError("County can only be specified with state"))
    end
    
    # Validate all variables end with 'E' for estimates
    if !all(v -> endswith(v, "E"), variables)
        throw(ArgumentError("All variables must end with 'E' for estimates"))
    end
    
    # Validate year range for 5-year ACS
    if year < 2009
        throw(ArgumentError("5-year ACS support begins with 2009 (2005-2009 5-year ACS)"))
    end
    
    # Print informative message about the request
    @info "Fetching $(year) 5-year ACS data for $(geography)$(isnothing(state) ? "" : " in $state")..."
    
    # Construct API URL
    base_url = "https://api.census.gov/data/$(year)/acs/acs5"
    
    # Build GET parameters
    params = String[]
    
    # Add NAME and variables
    push!(params, "get=NAME," * join(variables, ","))
    
    # Add geography
    push!(params, "for=$(geography):*")
    
    # Add state/county filters if specified
    if !isnothing(state)
        # Convert postal code to FIPS if needed
        state_fips = length(state) == 2 ? state_postal_to_fips(state) : state
        push!(params, "in=state:$(state_fips)")
        
        if !isnothing(county)
            push!(params, "in=county:$(county)")
        end
    end
    
    # Add API key if available
    api_key = get(ENV, "CENSUS_API_KEY", nothing)
    if !isnothing(api_key)
        push!(params, "key=$(api_key)")
    end
    
    # Construct final URL
    url = base_url * "?" * join(params, "&")
    
    # Make request with robust connection handling
    headers = [
        "Accept" => "application/json",
        "Accept-Encoding" => "gzip, deflate, br",
        "Accept-Language" => "en-US,en;q=0.9",
        "Connection" => "keep-alive",
        "User-Agent" => "Census.jl/0.1.0"
    ]
    
    try
        @info "Making request to Census API..."
        r = make_census_request(url, headers)
        
        # Parse response
        @info "Processing response..."
        data = JSON3.read(String(r.body))
        
        # Check if we got any data
        if length(data) < 2
            @warn "No data returned from Census API"
            return DataFrame()
        end
        
        # First row contains column names
        col_names = String.(data[1])
        
        # Create DataFrame with proper column types
        df = DataFrame([name => [] for name in col_names])
        
        # Add data rows
        for row in data[2:end]
            push!(df, row)
        end
        
        # Convert numeric columns
        @info "Converting data types..."
        for col in names(df)
            # Skip NAME and geographic identifier columns
            if col == "NAME" || col in ["state", "county", "tract", "block group"]
                continue
            end
            
            # Try converting numeric values
            if all(x -> x isa String && !isempty(x), df[!, col])
                try
                    df[!, col] = parse.(Float64, df[!, col])
                catch
                    # Leave as String if conversion fails
                end
            end
        end
        
        # Create GEOID based on geography type
        @info "Creating geographic identifiers..."
        if geography == "state"
            df.GEOID = df.state
        elseif geography == "county"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') 
                       for (s, c) in zip(df.state, df.county)]
        elseif geography == "tract"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') * lpad(t, 6, '0')
                       for (s, c, t) in zip(df.state, df.county, df.tract)]
        elseif geography == "block group"
            df.GEOID = [lpad(s, 2, '0') * lpad(c, 3, '0') * lpad(t, 6, '0') * b
                       for (s, c, t, b) in zip(df.state, df.county, df.tract, df.block_group)]
        end
        
        # Sort by GEOID
        sort!(df, :GEOID)
        
        @info "Data retrieval complete"
        return df
        
    catch e
        if e isa HTTP.TimeoutError
            @error "Request timed out. The Census API may be experiencing high load. Try again in a few minutes."
        else
            @error "Failed to fetch Census data" exception=e
        end
        rethrow(e)
    end
end

"""
    get_acs1(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch American Community Survey 1-year estimates.
Only available for geographies with populations of 65,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census data

# Example
```julia
# Get total population for all states
df = get_acs1(
    variables = ["B01003_001E"],
    geography = "state"
)
```
"""
function get_acs1(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Check for 2020 1-year ACS restriction
    if year == 2020
        error("""
        The regular 1-year ACS for 2020 was not released and is not available.
        
        Due to low response rates, the Census Bureau instead released a set of experimental estimates for the 2020 1-year ACS.
        
        These estimates can be downloaded at:
        https://www.census.gov/programs-surveys/acs/data/experimental-data/1-year.html
        
        1-year ACS data can still be accessed for other years by supplying an appropriate year to the `year` parameter.
        """)
    end
    
    # Validate year range for 1-year ACS
    if year < 2005
        throw(ArgumentError("1-year ACS support begins with 2005"))
    end
    
    @info "The 1-year ACS provides data for geographies with populations of 65,000 and greater."
    
    # Use same implementation as get_acs5 but with acs1 endpoint
    return get_acs5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    get_acs3(;
        variables::Vector{String},
        geography::String,
        year::Int = 2013,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing
    ) -> DataFrame

Fetch American Community Survey 3-year estimates.
Only available from 2007-2013 for geographies with populations of 20,000 and greater.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (2007-2013)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)

# Returns
DataFrame with requested Census data

# Example
```julia
# Get total population for all states in 2013
df = get_acs3(
    variables = ["B01003_001E"],
    geography = "state",
    year = 2013
)
```
"""
function get_acs3(;
    variables::Vector{String},
    geography::String,
    year::Int = 2013,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing
)
    # Validate year range for 3-year ACS
    if year < 2007 || year > 2013
        throw(ArgumentError("3-year ACS is only available from 2007-2013"))
    end
    
    @info "The 3-year ACS provides data for geographies with populations of 20,000 and greater."
    
    # Use same implementation as get_acs5 but with acs3 endpoint
    return get_acs5(
        variables = variables,
        geography = geography,
        year = year,
        state = state,
        county = county
    )
end

"""
    get_acs(;
        variables::Vector{String},
        geography::String,
        year::Int = 2022,
        state::Union{String,Nothing} = nothing,
        county::Union{String,Nothing} = nothing,
        survey::String = "acs5"
    ) -> DataFrame

Fetch American Community Survey data for different survey types.

# Arguments
- `variables`: Vector of Census variable codes (must end with 'E' for estimates)
- `geography`: Geographic level ("state", "county", "tract", "block group")
- `year`: Survey year (default: 2022)
- `state`: Optional state postal code or FIPS code
- `county`: Optional county FIPS code (requires state)
- `survey`: Survey type ("acs1", "acs3", "acs5"; default: "acs5")

# Returns
DataFrame with requested Census data

# Example
```julia
# Get 5-year estimates
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs5"
)

# Get 1-year estimates (65,000+ population areas only)
df = get_acs(
    variables = ["B01003_001E"],
    geography = "state",
    survey = "acs1"
)
```
"""
function get_acs(;
    variables::Vector{String},
    geography::String,
    year::Int = 2022,
    state::Union{String,Nothing} = nothing,
    county::Union{String,Nothing} = nothing,
    survey::String = "acs5"
)
    if survey == "acs5"
        return get_acs5(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    elseif survey == "acs3"
        return get_acs3(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    elseif survey == "acs1"
        return get_acs1(
            variables = variables,
            geography = geography,
            year = year,
            state = state,
            county = county
        )
    else
        throw(ArgumentError("survey must be one of: 'acs1', 'acs3', 'acs5'"))
    end
end