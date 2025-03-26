# takes a data frame of male and female ages and returns
# the ratio of persons aged 65 plus to those aged 16-64
function calculate_dependency_ratio(df::DataFrame)
    # Initialize population sums
    young_pop   = 0.0
    old_pop     = 0.0
    working_pop = 0.0
    
    for row in eachrow(df)
        total = row.male + row.female  # Get total population for the age group
        
        # Check age group and add to appropriate category
        if occursin("Under 5", row.age_group) || 
           occursin("5 to 9", row.age_group)  || 
           occursin("10 to 14", row.age_group)
           young_pop += total
        elseif occursin("65", row.age_group) || 
               occursin("70", row.age_group) || 
               occursin("75", row.age_group) || 
               occursin("80", row.age_group) || 
               occursin("85", row.age_group)
           old_pop += total
        else
           working_pop += total
        end
    end
    
    # Calculate dependency ratio
    return round((young_pop + old_pop) / working_pop * 100,digits = 2)
end

