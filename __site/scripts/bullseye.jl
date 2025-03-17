Capital        = "Boston"
Capital_Coords = "42° 21′ 37″ N, 71° 3′ 28″ W"
Capital        = "New York"
Capital_Coords = "40° 42′ 46″ N, 74° 0′ 22″ W"
Capital        = "Detroit"
Capital_Coords = "42° 20′ 00″ N, 83° 03′ 00″ W"
Capital        = "Chicago"
Capital_Coords = "41° 52′ 55″ N, 87° 37′ 40″ W"
Capital        = "Minneapolis"
Capital_Coords = "44° 58′ 55″ N, 93° 16′ 09″ W"
Capital        = "Denver"
Capital_Coords = "39° 44′ 42″ N, 104° 57′ 52″ W"
Capital        = "Houston"
Capital_Coords = "29° 45′ 46″ N, 95° 22′ 59″ W"
Capital        = "Seattle"
Capital_Coords = "47° 36′ 00″ N, 122° 20′ 00″ W"
Capital        = "San Francisco"
Capital_Coords = "37° 47′ 00″ N, 122° 25′ 00″ W"
Capital        = "Los Angeles"
Capital_Coords = "34° 03′ 00″ N, 118° 15′ 00″ W"
Capital        = "Phoenix"
Capital_Coords = "33° 26′ 54″ N, 112° 04′ 26″ W"
Capital        = "Salt Lake City"
Capital_Coords = "40° 45′ 39″ N, 111° 53′ 28″ W"
Capital        = "Atlanta"
Capital_Coords = "33° 44′ 56″ N, 84° 23′ 24″ W"
Capital        = "Charlotte"
Capital_Coords = "35° 13′ 38″ N, 80° 50′ 35″ W"
Capital        = "Nashville"
Capital_Coords = "36° 09′ 44″ N, 86° 46′ 28″ W"
Capital        = "Miami"
Capital_Coords = "25° 46′ 00″ N, 80° 12′ 00″ W"
Capital        = "Orlando"
Capital_Coords = "28° 32′ 24″ N, 81° 22′ 48″ W"
Capital        = "Jacksonville"
Capital_Coords = "30° 20′ 13″ N, 81° 39′ 41″ W"
Capital        = "Talahassee"
Capital_Coords = "30° 26′ 18″ N, 84° 16′ 50″W"

include("dms_to_decimal.jl")
pal = ("'Red', 'Green', 'Yellow', 'Blue', 'Purple'",
    "'#E74C3C', '#2ECC71', '#3498DB', '#F1C40F', '#9B59B6'",
    "'#FF4136', '#2ECC40', '#0074D9', '#FFDC00', '#B10DC9'",
    "'#D32F2F', '#388E3C', '#1976D2', '#FBC02D', '#7B1FA2'",
    "'#FF5733', '#C70039', '#900C3F', '#581845', '#FFC300'")
centerpoint = dms_to_decimal("$Capital_Coords")
from = Capital
file_path = "../_assets/$Capital.html"
bands = "50, 100, 200, 400"
band_colors = pal[4]
bullseye = """
<!DOCTYPE html>
<html>
<head>
  <title>Leaflet Template</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    body, html {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
    }
    .flex-container {
        display: flex;
        align-items: flex-start;
        width: 100%;
        height: 100%;
    }
    #map {
        flex: 1;
        height: 100vh;
        margin: 0;
    }
    .tables-container {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        padding: 20px;
    }
    table {
        border-collapse: collapse;
        width: 200px;
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: right;
    }
    .legend {
        padding: 6px 8px;
        background: white;
        background: rgba(255,255,255,0.9);
        box-shadow: 0 0 15px rgba(0,0,0,0.2);
        border-radius: 5px;
        line-height: 24px;
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
var mapOptions = {
   center: [$centerpoint],
   zoom: 7
};
var map = new L.map('map', mapOptions);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
}).addTo(map);

var marker = L.marker([$centerpoint]);
marker.addTo(map);
marker.bindPopup('$from').openPopup();

function milesToMeters(miles) {
   return miles * 1609.34;
}

var colors = [$band_colors];
var radii = [$bands].map(Number);

radii.forEach(function(radius, index) {
    var circle = L.circle([$centerpoint], {
        radius: milesToMeters(radius),
        color: colors[index],
        weight: 2,
        fill: true,
        fillColor: colors[index],
        fillOpacity: 0.05,
        interactive: false
    }).addTo(map);
    console.log('Added circle:', radius, 'miles');
});

var legend = L.control({position: 'bottomleft'});
legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'legend');
    div.innerHTML = '<strong>Miles from center</strong><br>';
    radii.forEach(function(radius, i) {
        div.innerHTML +=
            '<i style="background:' + colors[i] + '; width: 18px; height: 18px; float: left; margin-right: 8px; opacity: 0.7;"></i> ' +
            radius + '<br>';
    });
    return div;
};
legend.addTo(map);

// Add resize handler to ensure map fills container after window resize
window.addEventListener('resize', function() {
    map.invalidateSize();
});
</script>
</body>
</html>
"""

open(file_path, "w") do file
    write(file, bullseye)
end
run(`open $file_path`)
