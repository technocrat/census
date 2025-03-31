# SPDX-License-Identifier: MIT
# update SRC_DIR and DATA_DIR to reflect current project usage
using CSV, DataFrames, Census

include(joinpath(SRC_DIR, "setup.jl"))
educ = CSV.read(joinpath(DATA_DIR, "educational_attainment.csv"), DataFrame)
educ
#educ_pct  = select(educ, :State, :Population)
# for col in names(educ)[3:end]
#            educ_pct[!, "$(col)_pct"] = educ[!, col] ./ educ[!, :Population] .* 100
#            end
# Call the function to process your data
include(joinpath(SRC_DIR, "process_education_by_nation.jl"))

nation_stats = process_education_by_nation(educ, nations)

