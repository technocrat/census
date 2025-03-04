include("setup")
pop 	  = get_state_pop()
deaths 	  = CSV.read("../data/deaths.csv",DataFrame)
migration = CSV.read("../obj/migration.csv",DataFrame)
