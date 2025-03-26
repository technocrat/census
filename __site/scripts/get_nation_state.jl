# SPDX-License-Identifier: MIT

# Create a function to determine which region a state belongs to
function get_nation_state(state_abbr)
    if state_abbr in concord
        return "concord"
    elseif state_abbr in metropolis
        return "metropolis"
    elseif state_abbr in factoria
        return "factoria"
    elseif state_abbr in pacific
        return "pacifica"
    elseif state_abbr in lonestar
        return "lonestar"
    elseif state_abbr in dixie
        return "dixie"
    elseif state_abbr in cumber
        return "cumber"
    elseif state_abbr in heartland
        return "heartland"
    elseif state_abbr in sonora
        return "sonora"
    elseif state_abbr in desert
        return "desert"
    else
        return "Unknown"
    end
end