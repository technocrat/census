# Sources

## State and County Boundry Files

[Census National County Boundary Files](https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2024&layergroup=Counties+%28and+equivalent%29)

This is a zipped shapefile that contains the boundaries of all the counties and equivalent entities in the United States. It is saved to the `data` directory after unzipping.  

## GDP

[GDP by County, Metro, and Other Areas](https://www.bea.gov/sites/default/files/2024-12/lagdp1224.xlsx)

This is a spreadsheet that is formatted as a presentation table, so some preprocessing is needed to get the data into a format that can be used for analysis.

1. Download the spreadsheet
2. Open it in Excel
3. Remove rows 1-5
3. Use row six to create column headers—label Column A as "county" and Column E as "GDP" with the other columns as "drop"
4. Select Column E and format it as a number without commas
5. Export to CSV to the `obj` directory. By convention, we use the `data` directory for data that is received from others and the `obj` directory for data that is created by the scripts.
6. Use the `create_gdp_database.jl` script to create a database table from the CSV file.

## Connecticut Planning Region GDP

[Connecticut Crosswalk File](https://mcdc.missouri.edu/cgi-bin/broker?_PROGRAM=apps.geocorr2022.sas&_SERVICE=MCDC_long&_debug=0&state=Ct09&g1_=county&g2_=ctregion&wtvar=pop20&nozerob=1&fileout=1&filefmt=csv&lstfmt=html&title=&counties=&metros=&places=&oropt=&latitude=&longitude=&distance=&kiloms=0&locname=)

This file apportions the state's county-level population to the Connecticut planning regions and is used to create the `ct_gdp.csv` file in the `create_gdp_database.jl` script. 

[Colorado Basin boundaries](https://coloradoriverbasin-lincolninstitute.hub.arcgis.com/datasets/a922a3809058416b8260813e822f8980_0/explore?location=36.663436%2C-110.573590%2C5.51) was used to identify counties lying within the watershed.