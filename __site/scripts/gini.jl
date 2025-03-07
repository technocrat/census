function gini(v::Vector{Int})
    # Ensure the input vector is sorted
    sorted_v = sort(v)
    
    # Calculate the cumulative sum of the sorted vector
    S = cumsum(sorted_v)
    
    # Calculate the Gini coefficient using the formula
    n = length(v)
    numerator = 2 * sum(i * y for (i, y) in enumerate(sorted_v))
    denominator = n * sum(sorted_v)
    
    # Return the Gini coefficient
    return (numerator / denominator - (n + 1)) / n
end

# Example usage:
income_data = [50.0, 20.0, 30.0, 10.0, 40.0]
gini_coefficient = gini(income_data)
println("Gini Coefficient: ", gini_coefficient)