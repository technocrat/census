# answer include in core.jl and export?
state_names = Dict(
    "AL" => "Alabama",
    "AK" => "Alaska",
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "FL" => "Florida",
    "GA" => "Georgia",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming",
    "DC" => "District of Columbia",
    "Total" => "Total"
)

reverse_state_dict = Dict(value => key for (key, value) in state_names)

abbr_to_full = Dict(
    "cumber" => "Cumberland",
    "dixie" => "New Dixie",
    "lonestar" => "The Lone Star Republic",
    "metropolis" => "Metropolis",
    "heartland" => "Heartlandia",
    "factoria" => "Factoria",
    "desert" => "Deseret",
    "sonora" => "New Sonora",
    "concord" => "Concordia",
    "pacifica" => "Pacifica")

state_to_nation = Dict{String,String}()
for (i, states) in enumerate(nations)
    for state in states
        state_to_nation[state] = Titles[i]
    end
end
