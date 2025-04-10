#!/usr/bin/env julia

println("Starting Census.jl rebuild process...")

# Set R_HOME environment variable
r_home = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"
ENV["R_HOME"] = r_home
println("Set R_HOME to: $(ENV["R_HOME"])")

# Activate the project environment
using Pkg
Pkg.activate(".")

# First, make sure RSetup is updated
println("\nUpdating RSetup dependency...")
Pkg.develop(path="../RSetup.jl")

# Delete the build files for RCall to force a clean build
rcall_path = joinpath(homedir(), ".julia", "packages", "RCall")
build_path = nothing
if isdir(rcall_path)
    for dir in readdir(rcall_path, join=true)
        if isdir(dir)
            build_file = joinpath(dir, "deps", "build.log")
            if isfile(build_file)
                build_path = build_file
                println("Found RCall build log at: $build_path")
                try
                    rm(build_file)
                    println("Deleted RCall build log")
                catch e
                    println("Warning: Failed to delete RCall build log: $e")
                end
            end
        end
    end
end

# Rebuild RCall
println("\nRebuilding RCall...")
Pkg.build("RCall"; verbose=true)

# Precompile the dependencies
println("\nPrecompiling dependencies...")
Pkg.precompile()

# Force rebuild of Census.jl
println("\nForcing rebuild of Census.jl...")
Pkg.build("Census"; verbose=true)

# Final precompilation
println("\nFinal precompilation...")
Pkg.precompile()

println("\nRebuild complete. Try using Census now.") 