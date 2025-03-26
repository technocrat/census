using Test
using Census

# You can organize tests into testsets
@testset "Census.jl" begin
    # Basic functionality tests
    @testset "Core Functions" begin
        # Test a specific function
        @test function1(1, 2) == expected_result
        
        # Test error conditions
        @test_throws ArgumentError function1(-1, 2)
        
        # Test approximate equality for floating point
        @test function2(3.0) ≈ 3.14159 atol=1e-5
    end
    
    # You can create nested testsets for different components
    @testset "Component A" begin
        # Setup code if needed
        data = [1, 2, 3]
        
        @test component_function(data) == [2, 4, 6]
    end
    
    @testset "Component B" begin
        # More tests...
    end
end