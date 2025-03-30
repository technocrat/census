# SPDX-License-Identifier: MIT
# Script to adjust the Concordia dataset by adding 
# Clinton and Essex counties in New York, 
# and ceding portions of northern Maine to Canada 
# plus moving Fairfield County to Metropolis



using Census

# Define the destination projection - Albers Equal Area centered in mid Maine
dest = get_crs("concordia")


us          = get_geo_pop(postals)  

keep_from_ny = ["36019","36031"]
take_from_ct = ["09160","09190"]
take_from_me = ["23003","20029"]

ny          = subset(us, :stusps => ByRow(==("NY")))
ny          = subset(ny, :geoid  => ByRow(x -> x ∈ keep_from_ny))

ct          = subset(us, :stusps => ByRow(==("CT")))
ct          = subset(ct, :geoid  => ByRow(x -> x ∉ take_from_ct))

me          = subset(us, :stusps => ByRow(==("ME")))
me          = subset(me, :geoid  => ByRow(x -> x ∉ take_from_me))

ma          = subset(us, :stusps => ByRow(==("MA")))
ri          = subset(us, :stusps => ByRow(==("RI")))
nh          = subset(us, :stusps => ByRow(==("NH")))
vt          = subset(us, :stusps => ByRow(==("VT")))

df          = vcat(ny,ct,me,ma,ri,nh,vt)

DataFrames.rename!(df, [:geoid, :stusps, :county, :geom, :pop])
breaks      = RCall.rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)


# Create figure first
fig = Figure(size=(2400, 1600), fontsize=22)
# Now call map_poly with all required parameters
map_poly(df, "Adjusted Concordia", dest, fig)

# Display the figure
display(fig)

