# Loading Census TIGER Shapefiles into PostgreSQL/PostGIS

Loading Census TIGER shapefiles into a PostgreSQL database with PostGIS involves several steps: downloading the data, preparing your database, and then importing the shapefiles. I'll walk you through the entire process with attention to the unique characteristics of TIGER data.

## Understanding TIGER Data Structure

TIGER (Topologically Integrated Geographic Encoding and Referencing) files from the U.S. Census Bureau are organized hierarchically by geographic levels and feature types. Before downloading, it helps to understand what you're looking for:

- State and county boundaries
- Census tracts and block groups
- Roads and address ranges
- Water features
- Administrative boundaries
- And many other geographic entities

## Step 1: Downloading TIGER Shapefiles

The Census Bureau updates TIGER data annually. Here's how to get the most recent data:

~~~<pre>bash

# Create a directory for your TIGER data
mkdir -p tiger_data
cd tiger_data

# Download specific TIGER datasets using wget
# Example for downloading 2023 county boundaries:
wget https://www2.census.gov/geo/tiger/TIGER2023/COUNTY/tl_2023_us_county.zip

# Unzip the downloaded file
unzip tl_2023_us_county.zip
</pre>~~~

For specific datasets, you'll need to navigate the Census Bureau's FTP site structure at: https://www2.census.gov/geo/tiger/

You can also automate this with a script:

~~~<pre>bash

#!/bin/bash
# Example script to download multiple TIGER datasets
YEAR=2023
BASE_URL="https://www2.census.gov/geo/tiger/TIGER${YEAR}"

# Array of datasets to download
DATASETS=(
  "COUNTY/tl_${YEAR}_us_county.zip"
  "TRACT/tl_${YEAR}_01_tract.zip"  # Alabama tracts
  "BG/tl_${YEAR}_01_bg.zip"        # Alabama block groups
  # Add more as needed
)

for DATASET in "${DATASETS[@]}"; do
  echo "Downloading $DATASET"
  wget "${BASE_URL}/${DATASET}"
  unzip -o "${DATASET##*/}"
done
</pre>~~~

## Step 2: Preparing Your PostGIS Database

Ensure your PostgreSQL database has PostGIS enabled:

~~~<pre>bash

# Connect to PostgreSQL
psql -U postgres

# Create a dedicated database for TIGER data
CREATE DATABASE tiger_db;

# Connect to the new database
\c tiger_db

# Enable PostGIS extensions
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;  # Helpful for geocoding
CREATE EXTENSION postgis_tiger_geocoder;  # Optional, for geocoding
</pre>~~~

## Step 3: Importing Shapefiles Using shp2pgsql

The `shp2pgsql` utility converts shapefiles to SQL that can be loaded into PostgreSQL:

~~~<pre>bash

# Basic syntax:
# shp2pgsql -s SRID -I -D -e shapefile table_name | psql -d database_name -U username

# Example for counties (Census TIGER uses SRID 4269, NAD83)
shp2pgsql -s 4269 -I -D -e tl_2023_us_county.shp tiger_counties | psql -d tiger_db -U postgres
</pre>~~~

Breaking down the options:
- `-s 4269`: Sets the SRID (Spatial Reference ID) to NAD83, which is what Census TIGER uses
- `-I`: Creates a GiST spatial index on the geometry column
- `-D`: Uses PostgreSQL's COPY command for faster loading
- `-e`: Creates a new table and doesn't drop existing ones

## Step 4: Creating a Loader Script for Multiple Files

When loading many TIGER files, a script helps automate the process:

~~~<pre>bash

#!/bin/bash
# Script to load multiple shapefiles into PostGIS

DB_NAME="tiger_db"
DB_USER="postgres"
TIGER_DIR="./tiger_data"
SRID=4269

# Function to load a shapefile
load_shapefile() {
  local shp_file=$1
  local table_name=$2
  
  echo "Loading $shp_file into table $table_name"
  shp2pgsql -s $SRID -I -D -e "$shp_file" "$table_name" | psql -d $DB_NAME -U $DB_USER
}

# Load county boundaries
load_shapefile "$TIGER_DIR/tl_2023_us_county.shp" "tiger_counties"

# Load state boundaries
load_shapefile "$TIGER_DIR/tl_2023_us_state.shp" "tiger_states"

# Load census tracts for a specific state (Alabama=01)
load_shapefile "$TIGER_DIR/tl_2023_01_tract.shp" "tiger_tracts_01"

# Add more as needed
</pre>~~~

## Step 5: Using ogr2ogr (Alternative Method)

Another powerful tool for importing spatial data is GDAL's `ogr2ogr`:

~~~<pre>bash

# Basic syntax for loading a shapefile:
ogr2ogr -f "PostgreSQL" PG:"dbname=tiger_db user=postgres" tl_2023_us_county.shp -nln tiger_counties -nlt PROMOTE_TO_MULTI

# Explanation:
# -f "PostgreSQL": Output format
# PG:"connection string": PostgreSQL connection details
# -nln tiger_counties: Name for the new layer (table)
# -nlt PROMOTE_TO_MULTI: Ensures geometry type compatibility
</pre>~~~

## Step 6: Optimizing TIGER Data in PostGIS

After loading the data, some optimization steps are recommended:

~~~<pre>sql
-- Connect to your database
\c tiger_db

-- Update table statistics
VACUUM ANALYZE tiger_counties;

-- Add a geoid index for faster joins with demographic data
CREATE INDEX idx_tiger_counties_geoid ON tiger_counties (geoid);

-- Convert to a different projection if needed (e.g., to Web Mercator for web maps)
ALTER TABLE tiger_counties 
ADD COLUMN geom_web geometry(MultiPolygon, 3857);

UPDATE tiger_counties 
SET geom_web = ST_Transform(geom, 3857);

CREATE INDEX idx_tiger_counties_geom_web 
ON tiger_counties USING GIST(geom_web);
</pre>~~~

## Step 7: Using the Census Bureau's Loader Scripts

The Census Bureau provides specialized loader scripts specifically for TIGER data:

~~~<pre>bash

# Download the nation script
wget https://www2.census.gov/geo/tiger/TIGER_DP/2023ACS/nation_script_load.sh

# Make it executable
chmod +x nation_script_load.sh

# Edit the script to customize database connection parameters
# Then run it
./nation_script_load.sh
</pre>~~~

These scripts are designed to work with the PostGIS TIGER geocoder extension and include proper table structures and relationships.

## Example: Query Census TIGER Data

Once your data is loaded, you can run spatial queries:

~~~<pre>sql
-- Find all counties in a state
SELECT county.name, state.name 
FROM tiger_counties county 
JOIN tiger_states state ON ST_Intersects(county.geom, state.geom) 
WHERE state.name = 'California';

-- Find census tracts within 5km of a point
SELECT tract.geoid, tract.name 
FROM tiger_tracts tract 
WHERE ST_DWithin(
  tract.geom::geography, 
  ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4269)::geography, 
  5000
);

-- Count population by county (assuming you've loaded demographic data)
SELECT county.name, SUM(tract.population) as total_pop 
FROM tiger_counties county 
JOIN tiger_tracts tract ON ST_Intersects(county.geom, tract.geom) 
GROUP BY county.name 
ORDER BY total_pop DESC;
</pre>~~~

## Working with TIGER Data in Julia

Since you're coding in Julia, here's how you might interact with your TIGER data:

~~~<pre>julia
using LibPQ
using DataFrames
using GeoInterface
using GeoFormatTypes

# Connect to the PostgreSQL database
conn = LibPQ.Connection("dbname=tiger_db user=postgres")

# Query counties in a state
query = """
SELECT county.name as county_name, 
       county.geoid as county_geoid,
       ST_AsGeoJSON(county.geom) as geometry
FROM tiger_counties county
WHERE county.statefp = '06'  -- California
LIMIT 10;
"""

result = execute(conn, query)
counties_df = DataFrame(result)

# Process the results
for row in eachrow(counties_df)
    county_name = row.county_name
    county_geoid = row.county_geoid
    
    # Parse the GeoJSON geometry
    geom_json = row.geometry
    geom = GeoFormatTypes.GeoJSON(geom_json)
    
    # Access properties of the geometry
    println("$county_name ($county_geoid) has area: $(GeoInterface.area(geom)) square degrees")
end

# Close connection
close(conn)
</pre>~~~

## Advanced: Setting up a Nationwide TIGER Geocoder

If your goal is geocoding, the PostGIS TIGER geocoder extension can create a complete address geocoding system:

~~~<pre>bash
# First, enable the extensions
psql -d tiger_db -U postgres -c "CREATE EXTENSION postgis_tiger_geocoder;"

# Download the loader scripts
wget https://raw.githubusercontent.com/postgis/postgis/master/extras/tiger_geocoder/tiger_loader.sql

# Edit the nation_script_load.sh file to set database parameters
# Then run it to download and load all TIGER data needed for geocoding
./nation_script_load.sh
</pre>~~~

This process will download many gigabytes of data and can take several hours to complete, but will give you a complete geocoding system.

# Add a nations field to census.counties

```
psql -d geocoder -c "ALTER TABLE census.counties ADD COLUMN IF NOT EXISTS nation char;"
```

## Troubleshooting Common Issues

1. **Encoding problems**: TIGER files use Latin1 encoding. If you see character problems:
~~~<pre>sql
   -- Check and possibly set client encoding
   SHOW client_encoding;
   SET client_encoding TO 'LATIN1';
</pre>~~~

2. **Memory issues during loading**:
   - Split your loading process into smaller batches
   - Increase PostgreSQL memory parameters in postgresql.conf:
~~~<pre>
     maintenance_work_mem = 256MB
     work_mem = 16MB
</pre>~~~

3. **Slow loading**: 
   - Temporarily disable indexes during bulk loads:
     ~~~<pre>sql
     -- Disable triggers
     ALTER TABLE tiger_counties DISABLE TRIGGER ALL;
     -- Load data...
     -- Then re-enable triggers
     ALTER TABLE tiger_counties ENABLE TRIGGER ALL;
     </pre>~~~

By following these steps, you'll have a comprehensive geographic database with Census TIGER data ready for spatial analysis, mapping, and potentially geocoding applications. The structured approach ensures that your data is properly organized, indexed, and optimized for geographic queries.