#!/usr/bin/env julia

# Script to diagnose and fix RSetup.jl integration issues

println("Checking RSetup.jl installation...")
using Pkg

# First check if we can import RSetup directly
try
    @info "Attempting to import RSetup"
    using RSetup
    @info "RSetup imported successfully"
    
    # Try initializing RSetup
    try
        @info "Testing RSetup.setup_r_environment()"
        RSetup.setup_r_environment()
        @info "RSetup initialization successful"
    catch e
        @warn "RSetup initialization failed" exception=e
    end
catch e
    @warn "Failed to import RSetup" exception=e
end

# Check RSetup development path
rsetup_path = "../RSetup.jl"
if isdir(rsetup_path)
    @info "Found RSetup.jl at: $rsetup_path"
else
    @error "RSetup.jl directory not found at: $rsetup_path"
    exit(1)
end

# Compare the RSetup source with the current dependency
println("\nChecking if RSetup needs updating...")
println("Current RSetup.jl is a local path dependency")
println("Suggesting to re-register the development version...")

# Update the development path dependency
println("\nUpdating RSetup.jl dependency...")
Pkg.develop(path=rsetup_path)
println("RSetup.jl updated. Please restart Julia and try again.")

# Suggest cleaning precompilation cache if needed
println("\nIf the issue persists, consider cleaning the precompilation cache with:")
println("using Pkg; Pkg.precompile()") 