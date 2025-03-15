# SPDX-License-Identifier: MIT

using DrWatson; quickactivate(@__DIR__)
function scriptdir()
	return projectdir()*"/scripts"
end
function objdir()
	return projectdir()*"/obj"
end
function partialsdir()
	return projectdir()*"/_layout/partials"
end
include(scriptdir()*"/libr.jl")
include(scriptdir()*"/cons.jl")
include(scriptdir()*"/dict.jl")
include(scriptdir()*"/highlighters.jl")
include(scriptdir()*"/stru.jl")
