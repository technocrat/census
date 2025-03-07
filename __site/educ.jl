using CSV, DataFrames
# Get the directory of the current script
current_dir = @__DIR__
# Set the project directory (one level up from script directory if script is in a subdirectory)
project_dir = "/Users/ro/projects/census"
# Use project_dir as base for all relative paths
data_file = joinpath(project_dir, "data", "educational_attainment.csv")
educ = CSV.read(data_file,DataFrame)
educ
#educ = select(educ, Not([:College_drop1, :College_drop]))
#educ_pct  = select(educ, :State, :Population)
# for col in names(educ)[3:end]
#            educ_pct[!, "$(col)_pct"] = educ[!, col] ./ educ[!, :Population] .* 100
#            end
println(educ)
# Call the function to process your data
# nation_stats = process_education_by_nation(educ, nations)

# nation_stats.Nation = nation_stats.Nation_Name