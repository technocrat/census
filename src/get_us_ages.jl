# SPDX-License-Identifier: MIT

using DataFrames: rename!, transform!, ByRow

"""
    get_us_ages() -> DataFrame

Read and process U.S. population data by age and sex from a CSV file.

# Returns
- `DataFrame`: A processed DataFrame containing:
  - `age_group::String`: Age group labels
  - `male::Int64`: Male population count
  - `female::Int64`: Female population count

# Data Processing
- Reads data from "data/us_age_table.csv"
- Selects age group and sex columns
- Removes header rows
- Cleans age group labels
- Converts population counts from string to Int64
- Removes commas from numeric values

# Example
```julia
df = get_us_ages()
# Returns:
# 18×3 DataFrame
#  Row │ age_group     male      female   
#      │ String        Int64     Int64    
# ─────┼────────────────────────────────
#    1 │ Under 5      10319427  9868961
#    2 │ 5 to 9       10389638  9959207
#    ⋮ │     ⋮           ⋮         ⋮
```

# Notes
- Assumes a specific CSV file format with age groups and population counts
- Age groups are expected to be in rows 3-20 of the input file
- Population counts are expected to be formatted with commas as thousand separators
"""
function get_us_ages()
	us_age = df = CSV.read(datadir() * "/us_age_table.csv",DataFrame)
	us_age = us_age[:,[1,6,10]]
	us_age = us_age[3:20,:]
	rename!(us_age, [:age_group,:male,:female])
	transform!(us_age, :age_group => ByRow(x -> lstrip(x)) => :age_group)
	transform!(us_age, :male => ByRow(x -> parse(Int64, replace(x, "," => ""))) => :male)
	transform!(us_age, :female => ByRow(x -> parse(Int64, replace(x, "," => ""))) => :female)
	us_age.age_group = String.(us_age.age_group)
	return us_age
end