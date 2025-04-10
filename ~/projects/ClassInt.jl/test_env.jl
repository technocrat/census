#!/usr/bin/env julia

# Simple test to check environment
println("Testing environment...")

using Pkg
Pkg.status()

# List files in current directory
println("\nFiles in current directory:")
for file in readdir()
    println("  - $file")
end

# List files in src directory
if isdir("src")
    println("\nFiles in src directory:")
    for file in readdir("src")
        println("  - $file")
    end
else
    println("\nsrc directory does not exist")
end 