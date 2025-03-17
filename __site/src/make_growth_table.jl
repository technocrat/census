# SPDX-License-Identifier: MIT

function make_growth_table()
	pop 	  	  	= get_state_pop()
	pop.State 	  	= [state_names[code] for code in pop.stusps]
	sort!(pop,:State)
	pop = pop[!,[:State,:pop]]
	births		  	= CSV.read(datadir()*"/births.csv",DataFrame)
	births.State	= pop.State
	deaths 	  	  	= CSV.read(objdir()*"/deaths.csv",DataFrame)
	deaths.deaths 	= deaths.Population .* deaths.Crude_Rate / 1e5
	natural		  	= hcat(births,deaths,makeunique=true)
	natural		  	= natural[!,[:State,:Births,:Deaths]]
	natural.natural = natural.Births .- natural.Deaths
	migration 	  	= CSV.read(datadir()*"/migration.csv",DataFrame)
	foreign		  	= CSV.read(datadir()*"/foreign_immigrants.csv",DataFrame)
	migration	  	= innerjoin(migration,foreign,on=:State,makeunique=true)
	migration       = migration[!,[:State,:immigrants,:emmigrants,:foreign_immigrants]]
	migration.net_domestic = migration.immigrants .- migration.emmigrants
	migration.net 	= migration.net_domestic .+ migration.foreign_immigrants
	growth 		  	= innerjoin(natural,migration, on = :State)
	growth.growth	= growth.natural .+ growth.net
	return(growth[!,[:State,:Births,:Deaths,:natural,:net_domestic,:foreign_immigrants,:growth]])
end
