# SPDX-License-Identifier: MIT

function get_state_gdp()
    gdp_query = """
        SELECT gdp.county, gdp.state, gdp.gdp
        FROM gdp
    """
    df = q(gdp_query)
    return combine(groupby(df,:state), :gdp => sum => :gdp)
end