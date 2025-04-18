# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

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
