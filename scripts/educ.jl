# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

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

