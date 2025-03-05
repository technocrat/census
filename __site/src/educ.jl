educ 				= CSV.read("../data/educational_attainment.csv",DataFrame)

educ.Pop_w_College  = educ.Pop_w_BA .+ educ.Pop_w_GRAD

# Call the function to process your data
nation_stats = process_education_by_nation(educ, nations)


		