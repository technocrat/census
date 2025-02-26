const STATES = ["MA", "CT", "NH", "RI", "VT", "ME"]
const TIERS = ["Very Low", "Low", "Medium", "High", "Very High"]
const COLORS = ["#4682b4", "#d8bfd8", "#e6e9fa", "#f0e68c", "#a8c3bc",
    "#ffdab9", "#b5d0e3", "#838996"]
const NATIONS = ["Concordia","Metropolis","Factoria","Heartlandia"]

nation = NATIONS[1]

# Define named color constants
const SALMON_PINK = "#fd7e7e"
const COTTON_CANDY = "#f8c8dc"
const SLATE_GREY = "#74909a"
const SKY_BLUE = "#a0ced9"
const SAGE_GREEN = "#b6d1ba"

# Create a mapping of tiers to colors that's easy to modify
const TIER_COLORS = Dict(
    "Very Low" => SALMON_PINK,
    "Low" => COTTON_CANDY,
    "Medium" => SLATE_GREY,
    "High" => SKY_BLUE,
    "Very High" => SAGE_GREEN
)

# Generate colorscale in the order of TIERS
const COLORSCALE = [
    [0.00, TIER_COLORS[TIERS[2]]],
    [0.25, TIER_COLORS[TIERS[1]]],
    [0.50, TIER_COLORS[TIERS[3]]],
    [0.75, TIER_COLORS[TIERS[4]]],
    [1.00, TIER_COLORS[TIERS[5]]]
]

map_colors = [
   colorant"#326313",  # FOREST_GREEN
   colorant"#74909a",  # SLATE_GREY
   colorant"#b6d1ba",  # SAGE_GREEN
   colorant"#d8bfd8",  # VIE_EN_ROSE
   colorant"#cfcfcf",  # LIGHT_GRAY
   colorant"#a0ced9",  # SKY_BLUE
   colorant"#486ab2"   # BRIGHT_BLUE
]

# Create a mapping of tiers to colors that's easy to modify
const TIER_COLORS = Dict(
    "Very Low"    => SALMON_PINK,
    "Low"         => COTTON_CANDY,
    "Medium"      => SLATE_GREY,
    "High"        => SKY_BLUE,
    "Very High"   => SAGE_GREEN
)

# Generate colorscale in the order of TIERS
const COLORSCALE = [
    [0.00, TIER_COLORS[TIERS[2]]],
    [0.25, TIER_COLORS[TIERS[1]]],
    [0.50, TIER_COLORS[TIERS[3]]],
    [0.75, TIER_COLORS[TIERS[4]]],
    [1.00, TIER_COLORS[TIERS[5]]]
]
