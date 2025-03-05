educ = CSV.read("../data/educational_attainment.csv",DataFrame)
educ = select(df, Not([:College_drop1, :College_drop]))
educ_pct  = select(educ, :State, :Population)
for col in names(educ)[3:end]
           educ_pct[!, "$(col)_pct"] = educ[!, col] ./ educ[!, :Population] .* 100
           end
# Call the function to process your data
nation_stats = process_education_by_nation(educ, nations)

nation_stats.Nation = nation_stats.Nation_Name