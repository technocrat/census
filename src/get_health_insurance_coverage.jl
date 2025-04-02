# SPDX-License-Identifier: MIT

using DataFrames: rename!, transform!, ByRow

"""
    get_health_insurance_coverage() -> DataFrame

Fetch health insurance coverage data by age cohort from the ACS 5-year estimates.
Returns a DataFrame with age groups and their public coverage ratios.

The data includes:
- Total population in each age group
- Population with public coverage
- Ratio of public coverage
"""
function get_health_insurance_coverage()
	# Get ACS 5-year estimates for health insurance variables by age group
	df = get_acs5(
		variables=[
			# Under 18 years
			"B27003_003E", # With public coverage
			"B27003_002E", # Total
			
			# 18 to 34 years
			"B27003_006E", # With public coverage
			"B27003_005E", # Total
			
			# 35 to 64 years
			"B27003_009E", # With public coverage
			"B27003_008E", # Total
			
			# 65 years and over
			"B27003_012E", # With public coverage
			"B27003_011E"  # Total
		],
		geography="county"
	)
	
	# Create age group DataFrame
	result = DataFrame(
		age_group = [
			"Under 18 years",
			"18 to 34 years",
			"35 to 64 years",
			"65 years and over"
		],
		total = [
			df.B27003_002E[1],
			df.B27003_005E[1],
			df.B27003_008E[1],
			df.B27003_011E[1]
		],
		public_coverage = [
			df.B27003_003E[1],
			df.B27003_006E[1],
			df.B27003_009E[1],
			df.B27003_012E[1]
		]
	)
	
	# Calculate ratio of public coverage
	result.ratio = result.public_coverage ./ result.total
	
	return result
end