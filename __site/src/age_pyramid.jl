using DataFrames
using CSV
using Plots

function create_age_pyramid(data::DataFrame)
    # Assuming data has columns: age_group, male_pop, female_pop
    
    # Convert absolute numbers to percentages
    total_pop = sum(data.male_pop) + sum(data.female_pop)
    data.male_pct = -100 * data.male_pop / total_pop  # Negative for left side
    data.female_pct = 100 * data.female_pop / total_pop
    
    # Create the pyramid
    p = plot(
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