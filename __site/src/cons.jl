const STATES = ["MA", "CT", "NH", "RI", "VT", "ME"]
const TIERS = ["Very Low", "Low", "Medium", "High", "Very High"]
const COLORS = ["#4682b4", "#d8bfd8", "#e6e9fa", "#f0e68c", "#a8c3bc",
    "#ffdab9", "#b5d0e3", "#838996"]
const NATIONS = ["Concordia","Metropolis","Factoria","Heartlandia"]

concord    = ["CT", "MA", "ME", "NH", "RI", "VT"]
cumber     = ["WV","KY","TN"]
desert     = ["UT","MT","WY", "CO", "ID"]
dixie      = ["NC", "SC", "FL", "GA","MS","AL"]
factoria   = ["PA", "OH", "MI", "IN", "IL", "WI"]
heartland  = ["MN","IA","NE", "ND", "SD", "KS", "MO"]
lonestar   = ["TX","OK","AR","LA"]
metropolis = ["DE", "MD","NY","NJ","VA","DC"]
pacific    = ["WA","OR","AK"]
sonora     = ["CA","AZ","NM","NV","HI"]

nations    = [concord,cumber,desert,dixie,factoria,heartland,lonestar,metropolis,pacific,sonora]

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
