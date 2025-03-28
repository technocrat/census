"""
    get_colorado_basin_geoids() -> Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()
    shapefile_path = joinpath(dirname(@__DIR__), "data", "Colorado_River_Basin_County_Boundaries")
    
    # Read the shapefile
    dataset = ArchGDAL.read(shapefile_path)
    
    # Extract GEOIDs from the feature layer
    layer = ArchGDAL.getlayer(dataset, 0)
    geoids = String[]
    
    for feature in layer
        # Assuming GEOID is a field in the shapefile
        # You might need to adjust the field name if it's different
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end
    
    ArchGDAL.destroy(dataset)
    sort(unique(geoids))
end
