# SPDX-License-Identifier: MIT
using Census

"""
Fetch healthcare coverage data for all counties in Massachusetts using ACS 5-year estimates.

Variables:
- B27002_001E: Total civilian noninstitutionalized population
- B27003_001E: Total civilian noninstitutionalized population (for health insurance coverage)
"""
function get_ma_healthcare_data()
    # Get ACS 5-year estimates for healthcare variables
    df = get_acs5(
        variables=["B27002_001E", "B27003_001E"],
        geography="county",
        state="MA"
    )
    
    # Calculate ratio of B27002_001E to B27003_001E
    df.ratio = df.B27002_001E ./ df.B27003_001E
    
    return df
end

# Execute the function and display results
df = get_ma_healthcare_data()
println("\nHealthcare Coverage Data for Massachusetts Counties:")
println("================================================")
println(df) 