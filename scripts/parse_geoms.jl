function parse_geoms(df::DataFrame = df)
    return [ArchGDAL.fromWKT(geom) for geom in df.geom
       if !ismissing(geom)]
 end