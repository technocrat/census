# SPDX-License-Identifier: MIT

"""
    dms_to_decimal(coords::AbstractString) -> String

Convert coordinates from degrees, minutes, seconds (DMS) format to decimal degrees (DD).

# Arguments
- `coords::AbstractString`: Coordinates in DMS format "DD° MM′ SS″ N/S, DD° MM′ SS″ E/W"

# Returns
- `String`: Coordinates in decimal degrees format "±DD.DDDD, ±DD.DDDD"

# Format
Input format must be:
- Degrees (°), minutes (′), and seconds (″) with their respective symbols
- Direction (N/S for latitude, E/W for longitude) after each coordinate
- Latitude and longitude separated by comma
- Spaces between components are optional

# Example
```julia
# Basic usage
coord = "42° 21′ 37″ N, 71° 03′ 28″ W"
result = dms_to_decimal(coord)  # Returns "42.36027777777778, -71.05777777777778"

# With decimal seconds
coord = "40° 26′ 46.302″ N, 79° 58′ 56.484″ W"
result = dms_to_decimal(coord)  # Returns "40.44619444444444, -79.98235555555555"
```

# Throws
- `ArgumentError`: If input format is invalid or coordinates are out of range
"""
function dms_to_decimal(coords::AbstractString)
    # Input validation
    if !occursin(",", coords)
        throw(ArgumentError("Invalid format: Latitude and longitude must be separated by comma"))
    end
    
    # Split the input string into latitude and longitude parts
    lat_dms, lon_dms = split(coords, ",")
    
    function to_decimal(dms::AbstractString)
        # Remove any extra whitespace and normalize unicode characters
        dms = strip(dms)
        dms = replace(dms, '′' => "'", '″' => "\"", '°' => "°")
        
        # Try to match the DMS pattern
        m = match(r"^(\d+)°\s*(\d+)['′]\s*(\d+(?:\.\d+)?)[\"″]\s*([NSEW])$", dms)
        if isnothing(m)
            throw(ArgumentError("Invalid DMS format: Expected 'DD° MM′ SS″ D' where D is N/S/E/W"))
        end
        
        # Extract and validate components
        deg, min, sec, dir = m.captures
        deg = parse(Float64, deg)
        min = parse(Float64, min)
        sec = parse(Float64, sec)
        
        # Validate ranges
        if deg < 0 || deg > 180
            throw(ArgumentError("Degrees must be between 0 and 180"))
        end
        if min < 0 || min >= 60
            throw(ArgumentError("Minutes must be between 0 and 59"))
        end
        if sec < 0 || sec >= 60
            throw(ArgumentError("Seconds must be between 0 and 59"))
        end
        
        # Calculate decimal degrees
        decimal = deg + (min / 60) + (sec / 3600)
        
        # Validate based on direction
        if (dir in ["N", "S"] && decimal > 90) || (dir in ["E", "W"] && decimal > 180)
            throw(ArgumentError("Invalid coordinate value for direction $dir"))
        end
        
        # Apply direction
        decimal *= (dir in ["S", "W"]) ? -1 : 1
        
        return decimal
    end
    
    try
        # Convert latitude and longitude to decimal degrees
        lat_decimal = to_decimal(lat_dms)
        lon_decimal = to_decimal(lon_dms)
        
        # Format with consistent precision
        return @sprintf("%.14f, %.14f", lat_decimal, lon_decimal)
    catch e
        if e isa ArgumentError
            rethrow(e)
        else
            throw(ArgumentError("Failed to parse coordinates: $(e.msg)"))
        end
    end
end

export dms_to_decimal