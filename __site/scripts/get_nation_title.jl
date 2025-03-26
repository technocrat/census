# SPDX-License-Identifier: MIT

function get_nation_title(state_code, nations, titles)
    for (i, nation_states) in enumerate(nations)
        if state_code in nation_states
            return titles[i]
        end
    end
    return missing  # Return missing if no match is found
end

function get_nation_title_by_name(state_name, nations, titles)
    # Mapping of full state names to their codes
    state_name_to_code = Dict(
        "Alabama" => "AL", "Alaska" => "AK", "Arizona" => "AZ", "Arkansas" => "AR",
        "California" => "CA", "Colorado" => "CO", "Connecticut" => "CT", 
        "Delaware" => "DE", "Florida" => "FL", "Georgia" => "GA",
        "Hawaii" => "HI", "Idaho" => "ID", "Illinois" => "IL", "Indiana" => "IN",
        "Iowa" => "IA", "Kansas" => "KS", "Kentucky" => "KY", "Louisiana" => "LA",
        "Maine" => "ME", "Maryland" => "MD", "Massachusetts" => "MA", "Michigan" => "MI",
        "Minnesota" => "MN", "Mississippi" => "MS", "Missouri" => "MO", "Montana" => "MT",
        "Nebraska" => "NE", "Nevada" => "NV", "New Hampshire" => "NH", "New Jersey" => "NJ",
        "New Mexico" => "NM", "New York" => "NY", "North Carolina" => "NC", 
        "North Dakota" => "ND", "Ohio" => "OH", "Oklahoma" => "OK", "Oregon" => "OR",
        "Pennsylvania" => "PA", "Rhode Island" => "RI", "South Carolina" => "SC",
        "South Dakota" => "SD", "Tennessee" => "TN", "Texas" => "TX", "Utah" => "UT",
        "Vermont" => "VT", "Virginia" => "VA", "Washington" => "WA", 
        "West Virginia" => "WV", "Wisconsin" => "WI", "Wyoming" => "WY",
        "District of Columbia" => "DC"
    )
    
    # Get the state code for the given state name
    state_code = get(state_name_to_code, state_name, missing)
    
    if ismissing(state_code)
        return missing  # State name not found in the mapping
    end
    
    # Use the original function to get the nation title
    return get_nation_title(state_code, nations, titles)
end