# SPDX-License-Identifier: MIT

"""
    get_nation_state(state_abbr::String) -> String

Determine which proposed nation state a U.S. state belongs to based on its postal code.

# Arguments
- `state_abbr::String`: Two-letter U.S. state postal code

# Returns
- String: Name of the nation state ("concord", "metropolis", "factoria", etc.)
  Returns "Unknown" if the state doesn't belong to any defined nation state.

# Examples
```julia
julia> get_nation_state("MA")
"concord"

julia> get_nation_state("TX")
"lonestar"

julia> get_nation_state("XX")
"Unknown"
```

# Nation States
- concord: CT, MA, ME, NH, RI, VT
- metropolis: DE, MD, NY, NJ, VA, DC
- factoria: PA, OH, MI, IN, IL, WI
- pacifica: WA, OR, AK
- lonestar: TX, OK, AR, LA
- dixie: NC, SC, FL, GA, MS, AL
- cumber: WV, KY, TN
- heartland: MN, IA, NE, ND, SD, KS, MO
- sonora: CA, AZ, NM, NV, HI
- desert: UT, MT, WY, CO, ID
"""
function get_nation_state(state_abbr)
    # Look up the state in each nation's list of states
    for (nation, states) in NATION_STATES
        if state_abbr in states
            return nation
        end
    end
    return "Unknown"
end