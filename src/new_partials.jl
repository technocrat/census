bullseye = """
<!DOCTYPE html>
<html>
<head>
    <title>Leaflet Template</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
    <!-- Rest of your head section -->
</head>
<body>
    <!-- Your existing body content -->
<script>
var mapOptions = {
    center: [$centerpoint],
    zoom: 8  // Increased zoom level for better visibility
};
var map = new L.map('map', mapOptions);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
var marker = L.marker([$centerpoint]).addTo(map);
marker.bindPopup('$from').openPopup();

function milesToMeters(miles) {
    return miles * 1609.34;
}

var colors = [$band_colors];
var radii = [$bands];

// Modified circle creation function
radii.forEach(function(radius, index) {
    L.circle([$centerpoint], {
        radius: milesToMeters(radius),
        color: colors[index],
        fill: true,
        fillColor: colors[index],
        fillOpacity: 0.1,
        weight: 2
    }).addTo(map);
});

// Your existing legend code
</script>
</body>
</html>
"""