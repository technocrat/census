println("Starting test...")

# Explicitly disable RCall REPL integration
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"
println("RCall REPL integration disabled")

println("Importing RCall specific functions...")
using RCall: reval, rcopy, rparse
println("RCall functions imported successfully")

println("Importing RSetup package...")
using RSetup
println("RSetup imported successfully")

println("Setting up R environment...")
RSetup.setup_r_environment()
println("R environment setup completed")

println("Importing Census...")
using Census
println("Census imported successfully")

println("Test completed") 