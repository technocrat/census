using DataFrames
using CSV
using Plots

function create_age_pyramid(data::DataFrame)
    # Assuming data has columns: age_group, male, female
    
    # Convert absolute numbers to percentages
    total = sum(us_age.male) + sum(us_age.female)
    us_age.male_pct = -100 * us_age.male / total  # Negative for left side
    us_age.female_pct = 100 * us_age.female / total
    
    # Create the pyramid
    p = Plots.plot(
        data.male_pct, data.age_group,
        data.female_pct, data.age_group,
        orientation=:horizontal,
        xlabel="Population (%)",
        ylabel="Age Group",
        label=["Male" "Female"],
        color=[:blue :pink],                        
        legend=:bottom,
        title="Population Pyramid"
    )
    
    return p
end

# Example usage:
# data = CSV.read("census_data.csv", DataFrame)
# pyramid = create_age_pyramid(data)
# savefig(pyramid, "population_pyramid.png")