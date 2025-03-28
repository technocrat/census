# SPDX-License-Identifier: MIT
using Census
using CSV, DataFrames
include("fill_state.jl")
objs_dir = "/Users/ro/projects/Census/objs"
ct = CSV.read("$objs_dir/state_and_county_gdp.csv", DataFrame)
fill_state!(ct)
ct = filter(:state => x -> x == "Connecticut", ct)
deleteat!(ct, 1)
ct = ct[:, 1:2]
ct.GDPas2017 = ct.GDPas2017 * 1e3
rename!(ct, [:county, :gdp])
cross = CSV.read(datadir() * "/connecticut_crosswalk.csv", DataFrame)
rename!(cross, [:id1, :id2, :county, :region, :pop20, :afact])
cross.county = [s[1:end-3] for s in cross.county]
transform!(cross, :region => ByRow(x -> replace(x, " Planning Region" => "")) => :region)
joined = leftjoin(cross, ct,
    on = :county)
ct_gdp = combine(groupby(joined, :region)) do group
    (region = first(group.region),
     gdp = sum(group.gdp .* group.afact))
end
CSV.write(objdir() * "/ct_gdp.csv", ct_gdp)
