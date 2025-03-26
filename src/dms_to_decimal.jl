# SPDX-License-Identifier: MIT

"""
    dms_to_decimal(coords::AbstractString)

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
coord = "42° 21′ 37″ N, 71° 3′ 28″ W"
result = dms_to_decimal(coord)
println(result)  # Output: "41.258611111111111, -95.9375"
"""
function dms_to_decimal(coords::AbstractString)
    # Split the input string into latitude and longitude parts
    lat_dms, lon_dms = split(coords, ",")
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