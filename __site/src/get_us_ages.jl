# SPDX-License-Identifier: MIT

using DataFrames: rename!, transform!, ByRow

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