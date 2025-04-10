# SPDX-License-Identifier: MIT

# Explicitly disable RCall REPL integration
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

using Test
using DataFrames
using Census
using Census.RSetup
using RCall: reval, rcopy, rparse

@testset "R Setup and Breaks Tests" begin
    # Test R environment setup
    @test setup_r_environment() == true
    @test SETUP_COMPLETE[] == true
    
    # Test get_breaks functionality
    df = DataFrame(
        values = [1, 2, 3, 5, 8, 13, 21, 34, 55]  # Fibonacci-like sequence for clear breaks
    )
    
    breaks = rcopy(get_breaks(df, 1))
    @show typeof(breaks)
    @show keys(breaks)
    
    # Test that we get results for each method
    @test haskey(breaks, :fisher)
    @test haskey(breaks, :jenks)
    @test haskey(breaks, :kmeans)
    @test haskey(breaks, :maximum)
    @test haskey(breaks, :pretty)
    @test haskey(breaks, :quantile)
    @test haskey(breaks, :sd)
    
    # Test that breaks are properly ordered
    for method in [:fisher, :jenks, :kmeans, :maximum, :pretty, :quantile, :sd]
        brks = breaks[method][:brks]
        @test issorted(brks)
        @test length(brks) > 1  # Should have at least 2 break points
        @test first(brks) ≤ minimum(df.values)
        @test last(brks) ≥ maximum(df.values)
    end
end 