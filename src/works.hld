using ArchGDAL
using DataFrames
using CairoMakie
using GeoInterface
using Shapefile
using ZipFile

shape_tab = Shapefile.Table("data/US County Boundary Files 500k.zip")
df = DataFrame(shape_tab)

# Extract coordinates from each polygon
coords    = [geom === missing ? missing : GeoInterface.coordinates(geom) for geom in df.geometry]

# Import EPSG codes as ISpatialRef
# WGS84
source_crs = ArchGDAL.importEPSG(4326, order = :trad)
# Albers Equal Area
target_crs = ArchGDAL.importEPSG(5070, order = :trad)

# Transform a single coordinate pair
function transform_point(point, source_crs, target_crs)
    x, y = point
    ArchGDAL.createcoordtrans(source_crs, target_crs) do transform
        point_geom = ArchGDAL.createpoint(x, y)
        ArchGDAL.transform!(point_geom, transform)
        return (ArchGDAL.getx(point_geom, 0), ArchGDAL.gety(point_geom, 0))
    end
end

# Transform a polygon (handles nested structure)
function transform_polygon(poly, source_crs, target_crs)
    if ismissing(poly)
        return missing
    end

    # Handle multi-polygon structure
    transformed_poly = map(poly) do ring
        map(ring) do part
            map(point -> transform_point(point, source_crs, target_crs), part)
        end
    end

    return transformed_poly
end

# Apply transformation to all geometries
transformed_coords = map(coords) do poly
    transform_polygon(poly, source_crs, target_crs)
end

# Function to flatten the geometry into plottable form
function prepare_polygon_for_plotting(polygon)
    # Extract just the exterior ring (first ring) from each polygon part
    exterior_rings = [part[1] for part in polygon]

    # Convert to vector of points for each polygon part
    return exterior_rings
end

# Process all counties
plottable_coords = [
    prepare_polygon_for_plotting(county)
    for county in transformed_coords
    if county !== missing
]

fig = Figure()
ax  = Axis(fig[1, 1])

# Plot each county's polygon parts
for county_parts in plottable_coords
    for part in county_parts
        poly!(ax, part)
    end
end

fig
