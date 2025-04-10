#!/usr/bin/env julia

println("Starting Census.jl test...")

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"
println("Set environment variables:")
println("  RCALL_ENABLE_REPL: $(ENV["RCALL_ENABLE_REPL"])")
println("  R_HOME: $(ENV["R_HOME"])")

# Clear precompilation cache
println("\nAttempting to clear precompilation cache...")
try
    cache_dir = joinpath(homedir(), ".julia", "compiled", "v1.11", "Census")
    if isdir(cache_dir)
        println("Removing: $cache_dir")
        rm(cache_dir, recursive=true)
        println("  Removed successfully")
    else
        println("Cache directory not found: $cache_dir")
    end
catch e
    println("Failed to clear cache: $e")
end

# Remove and reinstall the package
println("\nRebuilding package from scratch...")
using Pkg
Pkg.activate(".")

# Try to rebuild
try
    Pkg.build("Census")
    println("Build successful")
catch e
    println("Build error: $e")
end

# Try loading the package
println("\nAttempting to load Census...")
try
    using Census
    println("Successfully loaded Census!")
catch e
    println("Failed to load Census: $e")
end

println("\nTest complete.") 