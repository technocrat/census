# This file was generated, do not modify it. # hide
#| echo: false
#| label: education
# hideall
using CSV, DataFrame
include("educ.jl")
nation 	= "Concordia"
grab 	=  filter(:Nation => (x -> x == nation), nation_stats)
print("In terms of educational attainment, " * grab[1,2] * " of the population has a college degree, of which " * grab[1,3] *" are graduate-level degrees.")