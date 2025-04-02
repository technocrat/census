# SPDX-License-Identifier: MIT

using Test
using Census
using DataFrames
using GeoInterface
using HTTP

# Mock API responses for testing
function mock_census_response()
    return """
    {
        "0": ["GEO_ID","NAME","B01003_001E","B01003_001M"],
        "1": ["1000000US360610001001","Census Tract 1, New York County, New York","5000","250"],
        "2": ["1000000US360610001002","Census Tract 2, New York County, New York","7500","300"]
    }
    """
end

function mock_variables_response()
    return """
    {
        "variables": {
            "B01003_001E": {
                "label": "Total Population",
                "concept": "TOTAL POPULATION",
                "predicateType": "int"
            },
            "B01003_001M": {
                "label": "Margin of Error for Total Population",
                "concept": "TOTAL POPULATION",
                "predicateType": "int"
            }
        }
    }
    """
end

@testset "Census.jl" begin
    @testset "CensusQuery Construction" begin
        # Test valid query construction
        query = CensusQuery(
            year = 2022,
            acs_period = 5,
            variables = ["B01003_001"],
            geography = "tract",
            api_key = "test-key"
        )
        @test query.year == 2022
        @test query.acs_period == 5
        @test query.variables == ["B01003_001"]
        @test query.geography == "tract"
        @test query.api_key == "test-key"

        # Test invalid year
        @test_throws ArgumentError CensusQuery(
            year = 2000,
            acs_period = 5,
            variables = ["B01003_001"],
            geography = "tract",
            api_key = "test-key"
        )

        # Test invalid ACS period
        @test_throws ArgumentError CensusQuery(
            year = 2022,
            acs_period = 2,
            variables = ["B01003_001"],
            geography = "tract",
            api_key = "test-key"
        )

        # Test invalid geography
        @test_throws ArgumentError CensusQuery(
            year = 2022,
            acs_period = 5,
            variables = ["B01003_001"],
            geography = "invalid",
            api_key = "test-key"
        )
    end

    @testset "URL Construction" begin
        query = CensusQuery(
            year = 2022,
            acs_period = 5,
            variables = ["B01003_001"],
            geography = "tract",
            state = "36",
            county = "061",
            api_key = "test-key"
        )
        url = build_census_query(query)
        @test occursin("https://api.census.gov/data/2022/acs/acs5", url)
        @test occursin("get=B01003_001", url)
        @test occursin("for=tract:*", url)
        @test occursin("in=state:36+county:061", url)
        @test occursin("key=test-key", url)
    end

    @testset "Data Fetching and Processing" begin
        # Mock HTTP.get to return our test data
        HTTP.get(url::String) = HTTP.Response(200, mock_census_response())

        query = CensusQuery(
            year = 2022,
            acs_period = 5,
            variables = ["B01003_001"],
            geography = "tract",
            state = "36",
            county = "061",
            api_key = "test-key"
        )

        df = fetch_census_data(query)
        @test df isa DataFrame
        @test nrow(df) == 2
        @test ncol(df) >= 4  # GEOID, NAME, estimate, moe
        @test all(names(df) .∈ Ref(["GEOID", "NAME", "estimate", "moe"]))
        @test eltype(df.estimate) <: Number
        @test eltype(df.moe) <: Number
    end

    @testset "Variable Loading" begin
        # Mock HTTP.get for variables
        HTTP.get(url::String) = HTTP.Response(200, mock_variables_response())

        vars_df = load_variables(2022, "acs5", cache=false)
        @test vars_df isa DataFrame
        @test nrow(vars_df) == 1  # One variable in our mock data
        @test all(names(vars_df) .∈ Ref(["name", "label", "concept"]))
        @test vars_df[1, :name] == "B01003_001"
        @test vars_df[1, :concept] == "TOTAL POPULATION"
    end

    @testset "Margin of Error Calculations" begin
        @test get_moe_factor(90) ≈ 1.645
        @test get_moe_factor(95) ≈ 1.960
        @test get_moe_factor(99) ≈ 2.576
        @test_throws ArgumentError get_moe_factor(92)
    end

    @testset "get_acs Function" begin
        # Test basic functionality
        df = get_acs(
            geography = "tract",
            variables = ["B01003_001"],
            state = "36",
            county = "061",
            year = 2022,
            survey = "acs5",
            api_key = "test-key"
        )
        @test df isa DataFrame
        @test nrow(df) == 2
        @test all(names(df) .∈ Ref(["GEOID", "NAME", "estimate", "moe"]))

        # Test table parameter
        df = get_acs(
            geography = "tract",
            table = "B01003",
            state = "36",
            county = "061",
            year = 2022,
            survey = "acs5",
            api_key = "test-key"
        )
        @test df isa DataFrame
        @test nrow(df) == 2

        # Test geometry
        df = get_acs(
            geography = "tract",
            variables = ["B01003_001"],
            state = "36",
            county = "061",
            year = 2022,
            survey = "acs5",
            geometry = true,
            api_key = "test-key"
        )
        @test df isa DataFrame
        @test :geometry ∈ propertynames(df)
        @test all(GeoInterface.isgeometry.(df.geometry))
    end
end