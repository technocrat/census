# SPDX-License-Identifier: MIT
using DrWatson
quickactivate(@__DIR__)
using CSV, DataFrames
include(srcdir()*"/setup.jl")
educ = CSV.read(datadir()*"/educational_attainment.csv",DataFrame)
educ
#educ_pct  = select(educ, :State, :Population)
# for col in names(educ)[3:end]
#            educ_pct[!, "$(col)_pct"] = educ[!, col] ./ educ[!, :Population] .* 100
#            end
# Call the function to process your data
include(srcdir()*"/process_education_by_nation.jl")

nation_stats = process_education_by_nation(educ, nations)

