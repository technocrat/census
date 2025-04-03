# SPDX-License-Identifier: MIT
using Census

# Initialize census data
us = init_census_data()

# Filter for California counties not in SoCal or east of Sierras
df = subset(us, :stusps => ByRow(==("CA")))
df = subset(df, :geoid => ByRow(x -> x ∉ socal && x ∉ east_of_sierras))

# Define projection
dest = """
+proj=aea +lat_1=35 +lat_2=45 +lat_0=40 +lon_0=-120 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
"""

# Create and display map
fig = Figure(size=(2400, 1600), fontsize=22)
map_poly(df, "Silicon Valley", dest, fig)
display(fig)
                                




