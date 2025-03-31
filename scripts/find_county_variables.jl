function find_county_variables()
    conn = LibPQ.Connection("dbname=geocoder")
    query = """
    SELECT variable_id, label, concept 
    FROM acs_2023_variables 
    WHERE 
    -- Population data
    variable_id LIKE 'B01%' OR
    -- Income data
    variable_id LIKE 'B19%' OR 
    -- Housing data
    variable_id LIKE 'B25%' OR
    -- Employment data
    variable_id LIKE 'B23%' OR
    -- Education data
    variable_id LIKE 'B15%'
    ORDER BY variable_id
    """
    result = execute(conn, query)
    return DataFrame(result)
end


var_table = find_county_variables()