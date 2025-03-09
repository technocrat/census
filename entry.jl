# SPDX-License-Identifier: MIT

include("scripts/setup.jl")

df = get_state_pop()

function get_gop_votes()
    geo_query = """
        SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as gop
        FROM census.counties us
        LEFT JOIN census.variable_data vd
            ON us.geoid = vd.geoid
            AND vd.variable_name = 'republican'
    """
    us = q(geo_query)
    
    us = dropmissing(us, :nation)
    sort!(us,[:nation,:stusps])
    mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]

    us = us[mask,:] 
    return(combine(groupby(us, :stusps), :gop => sum => :gop))
end

function get_dem_votes()
    geo_query = """
        SELECT us.geoid, us.stusps, us.name, us.nation, ST_AsText(us.geom) as geom, vd.value as dem
        FROM census.counties us
        LEFT JOIN census.variable_data vd
            ON us.geoid = vd.geoid
            AND vd.variable_name = 'democratic'
    """
    us = q(geo_query)
    
    us = dropmissing(us, :nation)
    sort!(us,[:nation,:stusps])
    mask = [s ∉ ["PR","VI","AS","GU","MP"] for s ∈ us.stusps]

    us = us[mask,:] 
    return(combine(groupby(us, :stusps), :dem => sum => :dem))
end

df = leftjoin(df,gop,on = :stusps)
df = leftjoin(df,dem,on = :stusps)

"""
TODO: Get HI/AK state election results to insert into gop & dem tables
"""