using DataFrames, LibPQ

function find_county_variables(additional_codes::Vector{String}=String[]; include_base_codes::Bool=true)
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Base variable codes that can be optionally included
    base_codes = ["B01", "B19", "B25", "B23", "B15"]
    
    # Use base codes only if include_base_codes is true
    all_codes = include_base_codes ? vcat(base_codes, additional_codes) : additional_codes
    
    # Ensure we have at least one code to search for
    if isempty(all_codes)
        error("At least one variable code must be specified when base codes are excluded")
    end
    
    # Create the LIKE conditions for each code
    like_conditions = join(["variable_id LIKE '$(code)%'" for code in all_codes], " OR\n    ")
    
    query = """
    SELECT variable_id, label, concept 
    FROM acs_2023_variables 
    WHERE 
    $like_conditions
    AND variable_id LIKE '%01E'
    ORDER BY variable_id
    """
    result = execute(conn, query)
    return DataFrame(result)
end

var_table = find_county_variables(["B27"],include_base_codes=false)
println(var_table.concept)     