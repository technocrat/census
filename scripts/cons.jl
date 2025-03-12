# SPDX-License-Identifier: MIT

const partialsdir(args...) = projectdir("_layout/partials", args...)

const concord    = ["CT", "MA", "ME", "NH", "RI", "VT"]
const cumber     = ["WV","KY","TN"]
const desert     = ["UT","MT","WY", "CO", "ID"]
const dixie      = ["NC", "SC", "FL", "GA","MS","AL"]
const factoria   = ["PA", "OH", "MI", "IN", "IL", "WI"]
const heartland  = ["MN","IA","NE", "ND", "SD", "KS", "MO"]
const lonestar   = ["TX","OK","AR","LA"]
const metropolis = ["DE", "MD","NY","NJ","VA","DC"]
const pacific    = ["WA","OR","AK"]
const sonora     = ["CA","AZ","NM","NV","HI"]
const nations    = [concord,cumber,desert,dixie,factoria,heartland,lonestar,metropolis,pacific,sonora]
const EU         = ["Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden"]
const conn       = LibPQ.Connection("dbname=geocoder")
const Titles     = ["Concordia","Cumberland","Deseret","New Dixie","Factoria","Heartlandia", "Metropolis", "Pacifica", "New Sonora", "The Lone Star Republic"]
const postals    = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
const nat_names  = ["concord","cumber","desert","dixie","factoria","heartland","metropolis","pacifica","sonora","lonestar"]

# Generate colorscale in the order of TIERS

map_colors = [
   colorant"#326313",  # FOREST_GREEN
   colorant"#74909a",  # SLATE_GREY
   colorant"#b6d1ba",  # SAGE_GREEN
   colorant"#d8bfd8",  # VIE_EN_ROSE
   colorant"#cfcfcf",  # LIGHT_GRAY
   colorant"#a0ced9",  # SKY_BLUE
   colorant"#486ab2"   # BRIGHT_BLUE
]


