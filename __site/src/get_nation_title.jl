function get_nation_title(state_code, nations, titles)
    for (i, nation_states) in enumerate(nations)
        if state_code in nation_states
            return titles[i]
        end
    end
    return missing  # Return missing if no match is found
end