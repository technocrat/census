1  Census shapefilesTo plot with GeoMakie, first convert json_geom field with GeoJSON.read.(ct.json_geom)  They should be 2D Multipolygon objects ne.jl is the type specimen
1.1  Join in Postgres
CREATE TABLE ne_gdp AS
SELECT ne.*, gdp.gdp
FROM ne 
LEFT JOIN gdp 
ON ne.name = gdp.county 
AND ne.stusps = gdp.state;
2  Connecticut
Because county boundaries and Census regions rarely match up perfectly, most researchers use an allocation or “crosswalk” approach to distribute county‐level data into Census‐defined areas. In other words, they take each county’s totals (e.g., GDP, labor force size) and split them across one or more Census geographies based on some weighting factor. The key steps and methods typically look like this:

1. Identify the Overlapping Geographies
	1	County Boundaries (from BLS or other sources): Data are reported by county.
	2	Census Regions (or Tracts, ZIP Codes, PUMAs, etc.): The boundaries you want to map data onto.

2. Overlay or “Intersect” the Boundaries
A GIS (Geographic Information System) or mapping tool is typically used to intersect the two sets of boundaries. This produces small “slivers” of geography that show exactly which portions of each county fall into which Census region.

3. Choose a Weighting Factor
Next, you decide how to split the county values across the Census geographies that overlap it. Common choices include:
	1	Population-based weighting
	◦	Use Census population counts (e.g., from blocks or block groups within each overlapping area).
	◦	If 30% of a county’s population lives in a certain Census region, you assign 30% of that county’s data to that region.
	2	Employment-based weighting
	◦	If data are economic (like GDP, payroll), you might use employment totals within each sliver.
	3	Land area-based weighting
	◦	Used if no better demographic or economic variables are available (less accurate if population density varies a lot).

4. Allocate the County Data
With the chosen weighting factor, you multiply the county total by the proportion of that factor in each overlapping area. So, if a county’s GDP is $10 million, and 30% of the county’s population lies in a specific Census area, you allocate $3 million to that region.

5. Sum Up Within Each Census Region
Finally, you sum the allocated amounts across all counties that intersect a Census region. That sum becomes the estimated GDP (or labor force, or other indicator) for the region as defined by the Census.

Tools and Resources
	1	MABLE/Geocorr from the Missouri Census Data Center
	◦	A popular online tool that generates crosswalk (“correlation”) files between various geographies.
https://mcdc.missouri.edu/cgi-bin/broker?_PROGRAM=apps.geocorr2022.sas&_SERVICE=MCDC_long&_debug=0&state=Ct09&g1_=county&g2_=ctregion&wtvar=pop20&nozerob=1&fileout=1&filefmt=csv&lstfmt=html&title=&counties=&metros=&places=&oropt=&latitude=&longitude=&distance=&kiloms=0&locname=

	◦	MCDC Geocorr Tool
	2	GIS Software (e.g., ArcGIS, QGIS)
	◦	You can directly calculate intersections and generate area-weighted or population-weighted allocations.
	3	Census Bureau TIGER/Line Shapefiles
	◦	Provide the spatial polygons for both counties and smaller/larger Census geographies.

Summary
Because county boundaries from BLS/BEA data do not exactly match Census regions, analysts create a crosswalk by intersecting the geographic boundaries and weighting each county’s data according to population, employment, or area. The final step is to sum those allocated amounts so that each Census region has a share of the original county-level value.
This approach, while not perfect (especially if economic activity varies unevenly within a county), is the most commonly accepted method for reconciling these mismatched geographies.

3  Bullseye Maps
3.1  Target
How often do you have to do a key map, something like this?
￼
3.1.1  Point of interest in context
There is an interactive version, also, showing added goodies of zoom, re-centering, re-scaling all based on the leaflet Javascript library.
3.1.2  Pattern work
Hand editing HTML is a PITA and that hasn't changed much in the 35+ years since I started doing it with the vi editor. The good news is that it has always been possible to tame the problem by isolating the static portion that doesn't change every time from the few, frequently changing portions.
3.1.2.1  What stays the same
All the usual scaffolding
3.1.2.1.1  Code block
```
<document_content>
<!DOCTYPE html>
<html>
<head>
  <title>Leaflet Template</title>
  <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.css" />
  <script src="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.js">
  </script>
  <style>
    .flex-container {
        display: flex;
        align-items: flex-start; /* Align items at the start of the container */
    }
    #map {
        width: 500px;
        height: 580px;
        margin-right: 20px; /* Add some space between the map and the tables */
    }
    .tables-container {
        display: flex;
        flex-wrap: wrap; /* Allow tables to wrap if there's not enough space */
        gap: 10px; /* Space between tables */
    }
    table {
        border-collapse: collapse;
        width: 200px; /* Adjust based on your preference */
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: right;
    }
  </style>
</head>

…
    </script>
  </body>
</html>
</document_content>
What changes
A few lines like this
addConcentricCircles([addConcentricCircles([41.258611111, -95.9375], radii, colors);
], radii, colors);
How to isolate
The spot
The purpose of map illustration is to show a point of interest and its distance from others.
from = "Omaha"
Locating the POI is done with specifying latitude and longitude. For example, Omaha is
centerpoint = "41.258611111, -95.9375"
The bands
bands       = "50, 100, 200, 300, 400"
band_colors = "'Red', 'Green', 'Yellow', 'Blue', 'Purple'"
How to insert
String interpolation
We've all done this in word processing:
Dear SALUTATION:
in a boilerplate (form) document and then do a search and replace.
In programming, however, we define string variables
centerpoint = "41.258611111, 95.9375"
from = "Omaha"
bands = "50, 100, 200, 300, 400"
band_colors = "['#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF']"
that we can use as placeholder variables in other strings
snippet = " The coordinates of $from are $centerpoint"
from which we will get
The coordinates of Ohama are 41.258611111, 95.9375
Where to insert it
In a script, of course, in any language that does string interpolation. According to my buddy Claude these include
Groovy:
```
def name = "John"
def age = 25
println "My name is $name and I'm $age years old."
Perl:
my $name = "John";
my $age = 25;
print "My name is $name and I'm $age years old.";
PHP:
$name = "John";
$age = 25;
echo "My name is $name and I'm $age years old.";
Scala:
val name = "John"
val age = 25
println(s"My name is $name and I'm $age years old.")
Kotlin:
val name = "John"
val age = 25
println("My name is $name and I'm $age years old.")
Swift:
let name = "John"
let age = 25
print("My name is \(name) and I'm \(age) years old.")
C# (using string interpolation):
string name = "John";
int age = 25;
Console.WriteLine($"My name is {name} and I'm {age} years old.");
Ruby:
name = "John"
age = 25
puts "My name is #{name} and I'm #{age} years old."
JavaScript (using template literals):
const name = "John";
const age = 25;
console.log(`My name is ${name} and I'm ${age} years old.`);
Python (using f-strings):
name = "John"
age = 25
print(f"My name is {name} and I'm {age} years old.")
And my favorite
from * " is located at " * coords
"Omaha is located at 41° 15′ 31″ N, 95° 56′ 15″ W"
and bash is also good.
So, the script
centerpoint = "41.258611111, 95.9375"
from = "Omaha"
bands = "50, 100, 200, 300, 400"
band_colors = "'#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF']"
include("partials.jl")
where partials.jl is a separate file with the template that contains all of the constant stuff, with `"something = $centerpoint".
bullseye =
"""
<document_content>
<!DOCTYPE html>
<html>
<head>
  <title>Leaflet Template</title>
  <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.css" />
  <script src="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.js">
  </script>
  <style>
    .flex-container {
        display: flex;
        align-items: flex-start; /* Align items at the start of the container */
    }
    #map {
        width: 500px;
        height: 580px;
        margin-right: 20px; /* Add some space between the map and the tables */
    }
    .tables-container {
        display: flex;
        flex-wrap: wrap; /* Allow tables to wrap if there's not enough space */
        gap: 10px; /* Space between tables */
    }
    table {
        border-collapse: collapse;
        width: 200px; /* Adjust based on your preference */
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: right;
    }
</style>
</head>

<body>
<div class="flex-container">
  <div id="map">
  </div>
  <div class="tables-container">
  </div>
</div>
<script>
// Creating map options
var mapOptions = {
   center: [$centerpoint],
   zoom: 5
};
var map = new L.map('map', mapOptions);

var layer = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');

map.addLayer(layer);

var marker = L.marker([$centerpoint]);

marker.addTo(map);

marker.bindPopup($from).openPopup();

function milesToMeters(miles) {
   return miles * 1609.34;
}
var colors = [$band_colors];
var radii = [$bands];
function addConcentricCircles(center, radii, colors) {
   radii.forEach(function(radius, index) {
      L.circle(center, milesToMeters(radius), {
         color: colors[index],
         fillColor: colors[index],
         fillOpacity: 0
      }).addTo(map);
   });
}

addConcentricCircles([$centerpoint], radii, colors);
// Adding a legend
var legend = L.control({position: 'bottomleft'}); // Change position to 'bottomleft'

legend.onAdd = function (map) {
   var div = L.DomUtil.create('div', 'info legend'),
       labels = ['<strong>Distances</strong>'],
       
       distances = [$bands];

   for (var i = 0; i < distances.length; i++) {
       div.innerHTML += 
           '<i style="background:' + colors[i] + '; width: 18px; height: 18px; float: left; margin-right: 8px; opacity: 0.7;"></i> ' +
           distances[i] + (distances[i + 1] ? '&ndash;' + distances[i + 1] + ' miles<br>' : '+ miles');
   }

   return div;
};

legend.addTo(map);
</script>
</body>
</html>
</document_content>
"""
```
Then, the rest of the script to generate the page and open it in your browser is just
Code block
```
open("omaha.html", "w") do file
           write(file, bullseye)
       end
file_path = "omaha.html"
run(`open $file_path`)
(This is for macOS; consult your bot for other platform.)
What if?
Ok, you want different colors.
Colors
pal = ("'Red', 'Green', 'Yellow', 'Blue', 'Purple'",
       "'#E74C3C', '#2ECC71', '#3498DB', '#F1C40F', '#9B59B6'",
       "'#FF4136', '#2ECC40', '#0074D9', '#FFDC00', '#B10DC9'",
       "'#D32F2F', '#388E3C', '#1976D2', '#FBC02D', '#7B1FA2'",
       "'#FF5733', '#C70039', '#900C3F', '#581845', '#FFC300'")


band_colors = pal[4]
```
3.1.2.2  Your coordinates don't coordinate
Yeah, we need decimal coordinates and if given degrees, minutes, seconds, no joy.
3.1.2.2.1  Code block
```
"""
    dms_to_decimal(coords::AbstractString) -> AbstractString

Convert latitude and longitude coordinates from degrees, minutes, seconds (DMS) format 
to decimal degrees (DD) format as a string.

# Arguments
- `coords`: A string representing the latitude and longitude coordinates in the format 
  "41° 15′ 31″ N, 95° 56′ 15″ W".

# Returns
- A string containing the latitude and longitude coordinates in decimal degrees format,
  separated by a comma, e.g., "41.258611111, -95.9375".

# Example
```julia
coords = "41° 15′ 31″ N, 95° 56′ 15″ W"
result = dms_to_decimal(coords)
println(result)  # Output: "41.258611111111111, -95.9375"
"""
function dms_to_decimal(coords::AbstractString)
# Split the input string into latitude and longitude parts
lat_dms, lon_dms = split(coords, ",")
    # Function to convert DMS to decimal degrees
    function to_decimal(dms::AbstractString)
        # Remove any extra whitespace
        dms = strip(dms)
        
        # Extract the degree, minute, and second values
        deg, min, sec, dir = match(r"(\d+).\s*(\d+)′\s*(\d+(?:\.\d+)?)″\s*([NSEW])", dms).captures
        
        # Convert the values to floats
        deg = parse(Float64, deg)
        min = parse(Float64, min)
        sec = parse(Float64, sec)
        
        # Calculate the decimal degrees
        decimal = deg + (min / 60) + (sec / 3600)
        
        # Adjust the sign based on the direction
        decimal *= (dir == "S" || dir == "W") ? -1 : 1
        
        return decimal
    end
    
    # Convert latitude and longitude to decimal degrees
    lat_decimal = to_decimal(lat_dms)
    lon_decimal = to_decimal(lon_dms)
    
    # Format the output string
    result = "$(lat_decimal), $(lon_decimal)"
    
    return result
end

coords = "41° 15′ 31″ N, 95° 56′ 15″ W"
result = dms_to_decimal(coords)
println(result)  # Output: "41.258611111111111, -95.9375"
```
3.1.3  Aside
If you've worked in other languages, the Julia is fairly easy to read, but what's up with the function signature?
function dms_to_decimal(coords::AbstractString)
Julia is somewhat of an oddball. The function could have been just ducktyped.
function dms_to_decimal(coords) 
But on the advice of Claude, I've strictly typed it.
function dms_to_decimal(coords::AbstractString)
And AbstractString? Here's what he says about that.
In duck-typed languages like Python or Ruby, the type of a variable is determined by its behavior rather than being explicitly declared. In other words, if an object quacks like a duck and walks like a duck, it is considered a duck, regardless of its actual type.
In contrast, Julia is a statically-typed language, which means that the types of variables are known at compile-time. However, Julia also supports multiple dispatch, allowing functions to have different behavior based on the types of their arguments.
Now, let's examine the function signature:
function dms_to_decimal(coords::AbstractString)
	•	function is the keyword used to define a function in Julia.
	•	dms_to_decimal is the name of the function.
	•	coords is the name of the argument that the function takes.
	•	::AbstractString is a type annotation specifying that the coords argument must be a subtype of AbstractString.
In this case, AbstractString is an abstract type in Julia that represents any string-like type. It is a supertype of concrete string types such as String (for ASCII strings) and UTF8String (for UTF-8 encoded strings).
By specifying coords::AbstractString, the function signature indicates that the coords argument must be a string or any subtype of AbstractString. This provides a way to enforce type constraints on the argument.
For someone coming from a duck-typed language, this type annotation might seem unusual. In duck-typed languages, you would typically just pass an argument to a function without explicitly specifying its type. The function would then operate on the argument based on its expected behavior.
However, in Julia, the type annotation ::AbstractString serves as a contract or a guarantee that the coords argument will behave like a string. It allows the Julia compiler to perform type checks and optimizations based on the specified type.
If you try to pass an argument that is not a subtype of AbstractString to the dms_to_decimal function, Julia will raise a type error at compile-time or runtime, depending on the situation.
Here's an example of how you would use this function in Julia:
coordinates = "41° 15′ 31″ N, 95° 56′ 15″ W"
 result = dms_to_decimal(coordinates)
In this case, the coordinates variable is a string literal, which is a subtype of AbstractString, so it can be passed to the dms_to_decimal function without any issues.
To summarize, the ::AbstractString type annotation in the function signature specifies that the coords argument must be a string or any subtype of AbstractString. This allows Julia to perform type checks and ensures that the function is used correctly with the expected type of argument.
4  UK Postcodes
The problem that spurred me here is this: A warehouse in England ships pallets to various postcodes (the Brits are crazy, they have like 1.7 million ZIP+5 equivalents) and are charged by the pallet with discounts given for multiple pallets upto a standard lorryful of 26 pallets. How can they tell if they are being billed by the carrier correctly?
How, indeed, using spreadsheets? Thousands of shipments to scores of addresses in various load sizes. Wasn't gonna happen. So, here's what I came up with.
4.1  Code block
# audit.jl
# compare invoiced shipping costs to UK postcodes
# given number of pallets against the rate card
# provided by carrier; returns 0 if no differences
# otherwise use `truth_table` vector to subsect 
# DataFrame `obj`
# author: Richard Careaga
# Date: 2024-02-28

#------------------------------------------------------------------

# libraries

using CSV
using DataFrames
using Dates

#------------------------------------------------------------------

# constant

objs = "/Users/me/postal/objs/"

#------------------------------------------------------------------

# data

# single origin shipments to separate destinations
df   = CSV.read(objs * "/PE330JF.csv",DataFrame)
# =
5_000 records
```markdown
| variable    | eltype    |
|-------------|-----------|
| Symbol      | DataType  |
| dt          | DateTime  |
| from        | String15  |
| to          | String15  |
| pallets     | Int64     |
| cost        | Float64   |
| key         | String7   |
| origin      | String7   |
| destination | String15  |
| meters      | Float64   |
| miles       | Float64   |
```
=#

# corresponding charges per pallet
card = CSV.read(objs * "rate_card.csv", DataFrame, header = false)

#=
100 records
```markdown
| variable | eltype  |
|----------|---------|
| Symbol   | DataType|
| Column1  | String3 |
| Column2  | Float64 |
| Column3  | Float64 |
      ⋮         ⋮    
| Column27 | Float64 |
```
=#

#------------------------------------------------------------------

# preprocessing

df.dt = DateTime.(df.dt, "m/d/yy H:M") + Year(2000)

# Create a new column to hold the first two letters of the 'key' column
# the keep only the columns for key, number of pallets and cost

df[!, :key_group] = first.(df.key, 2)
grp               = unique(df[:,[:key_group,:pallets,:cost]])
rename!(grp,[:key,:pallets,:cost])
sort!(grp, :key)

# discard unused rows from rate card

ours      = unique(df.key_group)
theirs    = card.Column1
common    = intersect(ours,theirs)
underlap  = setdiff(ours,theirs)
short     = filter(row -> in(row.Column1, common), card)
new_names = Symbol[:key; [Symbol("p", i) for i in 1:26]]
short     = DataFrame(short[!, 1:27], new_names)

# principal object

obj =  leftjoin(grp,short, on = :key)
obj = obj[completecases(obj),:]

# Generate column names to compare against 'cost'
# prefix the value of the pallets column with the letter p
# to correspond to p1 … p26, the cost for a given number of pallets

obj.p_column = "p" .* string.(obj.pallets)

#------------------------------------------------------------------

# main

# Perform comparison and create truth table

truth_table = [obj[i, :cost] != obj[i, Symbol(obj[i, :p_column])] for i in 1:size(obj, 1)]

# Result will equal 0 if all costs correspond to the rate card for that 
# number of pallets

sum(truth_table)
  ```

I cheated. I had the help of Claude, an AI bot who answered my simple questions about syntax and greatly assisted in the real work, which is properly framing the question systematically. When you go back to school algebra and start thinking 
y
=
f
(
x
)
 pieces start falling into place easily.
x
 is what is at hand, 
y
 is what is desired and 
f
 is the operator or script that will get you there. Any of these may be, and in fact usually are, composite. So you start doing things like 
y
=
g
(
f
(
x
)
, etc. Approaching it that way is like having a conversation:
y
, darling, tell me what you need to be happy
x
, sweetheart, do you think I could give nicknames to your beautiful eyes?
⋮
so, 
f
 if I make this little change can you get me closer?
Far too much formal education is wasted trying to find the answer, which is too bad. Answers change all the time, but the good questions are durable.



Visual-Meta Appendix

This is where your document comes alive. The information in very small type below allows software to provide rich interactions with this document.
See Visual-Meta.info for more information.

This is what we call Visual-Meta. It is an approach to add information about a document to the document itself on the same level of the content. The same as would be necessary on a physically printed page, as opposed to a data layer, since this data layer can be lost and it makes it harder for a user to take advantage of this data. ¶ Important notes are primarily about the encoding of the author information to allow people to cite this document. When listing the names of the authors, they should be in the format ‘last name’, a comma, followed by ‘first name’ then ‘middle name’ whilst delimiting discrete authors with  (‘and’) between author names, like this: Shakespeare, William and Engelbart, Douglas C. ¶ Dates should be ISO 8601 compliant. ¶ The way reader software looks for Visual-Meta in a PDF is to parse it from the end of the document and look for @{visual-meta-end}. If this is found, the software then looks for {@{visual-meta-start} and uses the data found between these marker tags. ¶ It is very important to make clear that Visual-Meta is an approach more than a specific format and that it is based on wrappers. Anyone can make a custom wrapper for custom metadata and append it by specifying what it contains: For example @dublin-core or @rdfs. ¶ This was written Summer 2021. More information is available from https://visual-meta.info or from emailing frode@hegland.com for as long as we can maintain these domains.

@{visual-meta-start}

@{visual-meta-header-start}

@visual-meta{
version = {1.1},¶generator = {Author 10.5 (1436)},¶keywords = {},¶concepts = {},¶names = {},¶}

@{visual-meta-header-end}

@{visual-meta-bibtex-self-citation-start}

@article{2025-03-09T08:26:52Z/GIS,
author = {Richard  Careaga},¶title = {GIS},¶filename = {gis.md},¶month = {mar},¶year = {2025},¶institution = {Author},¶vm-id = {2025-03-09T08:26:52Z/GIS},¶}

@{visual-meta-bibtex-self-citation-end}

@{document-headings-start}

@heading{
name = {1 Census shapefiles},¶level = {level1},¶}
@heading{
name = {1.1 Join in Postgres},¶level = {level2},¶}
@heading{
name = {2 Connecticut},¶level = {level1},¶}
@heading{
name = {3 Bullseye Maps},¶level = {level1},¶}
@heading{
name = {3.1 Target},¶level = {level2},¶}
@heading{
name = {3.1.1 Point of interest in context},¶level = {level3},¶}
@heading{
name = {3.1.2 Pattern work},¶level = {level3},¶}
@heading{
name = {3.1.2.1 What stays the same},¶level = {level4},¶}
@heading{
name = {3.1.2.1.1 Code block},¶level = {level5},¶}
@heading{
name = {3.1.2.2 Your coordinates don't coordinate},¶level = {level4},¶}
@heading{
name = {3.1.2.2.1 Code block},¶level = {level5},¶}
@heading{
name = {3.1.3 Aside},¶level = {level3},¶}
@heading{
name = {4 UK Postcodes},¶level = {level1},¶}
@heading{
name = {4.1 Code block},¶level = {level5},¶}
@heading{
name = {Visual-Meta Appendix},¶level = {level1},¶}

@{document-headings-end}

@{paraText-start}

@paraText{
visual-meta = {Visual-Meta Appendix},¶}

@{paraText-end}



@{visual-meta-end}