#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Simple module loader for Census.jl

# Add package directory to LOAD_PATH
package_dir = dirname(@__FILE__)
if !(package_dir in LOAD_PATH)
    push!(LOAD_PATH, package_dir)
end

# Add src directory to LOAD_PATH
src_dir = joinpath(package_dir, "src")
if isdir(src_dir) && !(src_dir in LOAD_PATH)
    push!(LOAD_PATH, src_dir)
end

# Export a simple function to check if the package is available
function is_census_available()
    try
        @eval using Census
        return true
    catch
        return false
    end
end

# Simple function to load the Census module
function load_census()
    try
        @eval using Census
        return true
    catch e
        @warn "Failed to load Census module: $e"
        return false
    end
end

# Auto-load Census module when this file is included
if !@isdefined(Census)
    load_census()
end

# Print success message if loaded in interactive mode
if isinteractive() && @isdefined(Census)
    println("✅ Census module loaded successfully")
end 