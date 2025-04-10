#!/usr/bin/env julia

"""
RCall Fix Script

This script rebuilds the RCall package with the correct R_HOME path.
Run this script if you encounter issues with RCall precompilation.
"""

using Pkg

println("🔄 Fixing RCall configuration...")

# Set the R_HOME environment variable
r_home = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"
ENV["R_HOME"] = r_home
println("📌 Setting R_HOME to: $r_home")

# Verify R_HOME directory exists
if !isdir(r_home)
    error("R_HOME directory does not exist: $r_home")
else
    println("✅ R_HOME directory exists")
end

# Disable RCall REPL integration to avoid precompilation issues
ENV["RCALL_ENABLE_REPL"] = "false"

# Force environment to update
if haskey(ENV, "JULIA_LOAD_PATH")
    ENV["JULIA_LOAD_PATH"] = ENV["JULIA_LOAD_PATH"]
end

try
    # Rebuild RCall with the correct R_HOME
    println("🔄 Rebuilding RCall...")
    Pkg.build("RCall")
    println("✅ RCall successfully rebuilt!")
    
    # Try loading RCall
    println("🔄 Testing RCall loading...")
    @eval using RCall
    println("✅ RCall loaded successfully!")
catch e
    println("❌ Error rebuilding or loading RCall:")
    println(e)
end

println("\n📋 Next steps:")
println("1. Start Julia with: julia --project=.")
println("2. Try loading the Census package: using Census") 