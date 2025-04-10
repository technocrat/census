using ClassInt
using Test
using Statistics

@testset "ClassInt.jl" begin
    # Test data
    test_values = [1, 3, 5, 7, 9, 11, 13, 22, 35, 51, 65, 80, 90, 100]
    
    # Test with missing values
    test_with_missing = Union{Missing, Float64}[1, 3, 5, missing, 9, 11, missing, 22, 35, 51, 65, 80, 90, 100]
    
    @testset "get_breaks basic functionality" begin
        # Test each method returns correct format
        jenks_breaks = get_breaks(test_values, 5, style=:jenks)
        kmeans_breaks = get_breaks(test_values, 5, style=:kmeans)
        quantile_breaks = get_breaks(test_values, 5, style=:quantile)
        equal_breaks = get_breaks(test_values, 5, style=:equal)
        
        # Each should return n+1 breaks (or fewer if there are duplicates)
        @test length(jenks_breaks) <= 6
        @test length(kmeans_breaks) <= 6
        @test length(quantile_breaks) <= 6
        @test length(equal_breaks) == 6
        
        # First and last breaks should match min and max
        @test jenks_breaks[1] == minimum(test_values)
        @test jenks_breaks[end] == maximum(test_values)
        
        @test kmeans_breaks[1] == minimum(test_values)
        @test kmeans_breaks[end] == maximum(test_values)
        
        @test quantile_breaks[1] == minimum(test_values)
        @test quantile_breaks[end] == maximum(test_values)
        
        @test equal_breaks[1] == minimum(test_values)
        @test equal_breaks[end] == maximum(test_values)
        
        # Breaks should be sorted
        @test issorted(jenks_breaks)
        @test issorted(kmeans_breaks)
        @test issorted(quantile_breaks)
        @test issorted(equal_breaks)
    end
    
    @testset "get_breaks with missing values" begin
        # Test with missing values
        jenks_breaks = get_breaks(test_with_missing, 5, style=:jenks)
        
        # Should handle missing values without error
        @test length(jenks_breaks) <= 6
        @test jenks_breaks[1] == minimum(skipmissing(test_with_missing))
        @test jenks_breaks[end] == maximum(skipmissing(test_with_missing))
    end
    
    @testset "get_breaks error cases" begin
        # Test with invalid number of classes
        @test_throws ErrorException get_breaks(test_values, 0)
        @test_throws ErrorException get_breaks(test_values, 1)
        
        # Test with invalid style
        @test_throws ErrorException get_breaks(test_values, 5, style=:invalid)
        
        # Test with empty array
        @test_throws ErrorException get_breaks(Float64[], 5)
        
        # Test with fewer unique values than classes
        @test_logs (:warn, r"Number of unique values.*") get_breaks([1, 1, 1, 2, 2], 5)
    end
    
    @testset "natural_breaks (jenks)" begin
        jenks_breaks = natural_breaks(test_values, 5)
        
        # Basic functionality checks
        @test length(jenks_breaks) <= 6
        @test jenks_breaks[1] == minimum(test_values)
        @test jenks_breaks[end] == maximum(test_values)
        @test issorted(jenks_breaks)
        
        # Verify breaks are reasonable - should have larger gaps where data is sparse
        diffs = diff(jenks_breaks)
        @test length(unique(diffs)) > 1  # Not equal interval
    end
    
    @testset "kmeans_breaks" begin
        kmeans_result = kmeans_breaks(test_values, 5)
        
        # Basic functionality checks
        @test length(kmeans_result) <= 6
        @test kmeans_result[1] == minimum(test_values)
        @test kmeans_result[end] == maximum(test_values)
        @test issorted(kmeans_result)
    end
    
    @testset "quantile_breaks" begin
        quantile_result = quantile_breaks(test_values, 5)
        
        # Basic functionality checks
        @test length(quantile_result) <= 6
        @test quantile_result[1] == minimum(test_values)
        @test quantile_result[end] == maximum(test_values)
        @test issorted(quantile_result)
        
        # Check distribution - should approximately divide data into equal groups
        n = length(test_values)
        expected_per_bin = n / 5
        
        # Count items in each bin
        sorted_values = sort(test_values)
        bin_counts = zeros(Int, 5)
        bin_idx = 1
        
        for val in sorted_values
            while bin_idx < 5 && val > quantile_result[bin_idx+1]
                bin_idx += 1
            end
            bin_counts[bin_idx] += 1
        end
        
        # Allow some variation due to ties and rounding
        @test all(bin_counts .>= expected_per_bin * 0.5)
    end
    
    @testset "equal_interval_breaks" begin
        equal_result = equal_interval_breaks(test_values, 5)
        
        # Basic functionality checks
        @test length(equal_result) == 6
        @test equal_result[1] == minimum(test_values)
        @test equal_result[end] == maximum(test_values)
        @test issorted(equal_result)
        
        # Check equal spacing
        diffs = diff(equal_result)
        for i in 2:length(diffs)
            @test diffs[i] ≈ diffs[1] atol=1e-10
        end
    end
    
    @testset "get_breaks_dict" begin
        result = get_breaks_dict(test_values, 5)
        
        # Check structure
        @test haskey(result, :jenks)
        @test haskey(result, :kmeans)
        @test haskey(result, :quantile)
        @test haskey(result, :equal)
        
        # Check each result has appropriate format
        @test length(result[:jenks]) <= 6
        @test length(result[:kmeans]) <= 6
        @test length(result[:quantile]) <= 6
        @test length(result[:equal]) == 6
        
        # Each should have the same min/max
        @test result[:jenks][1] == minimum(test_values)
        @test result[:jenks][end] == maximum(test_values)
    end
end 