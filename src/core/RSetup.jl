# SPDX-License-Identifier: MIT

"""
RSetup module - Handles R environment setup and RCall integration
"""
module RSetup

# Mark this submodule as not precompilable
__precompile__(false)

using RCall
using Dates

# Global flags to track environment state
const SETUP_COMPLETE = Ref(false)
const LAST_SETUP_TIME = Ref{Union{DateTime, Nothing}}(nothing)
const SETUP_TIMEOUT = Hour(1)  # Refresh setup after 1 hour

# Required R packages and their versions
const REQUIRED_PACKAGES = Dict(
    "classInt" => "0.4-9",
    "sf" => "1.0-14",
    "units" => "0.8-4"
)

"""
    check_r_package(package::String, version::String) -> Bool

Check if an R package is installed and meets the minimum version requirement.

# Arguments
- `package::String`: The name of the R package
- `version::String`: The minimum required version

# Returns
- `true` if package is installed and meets version requirement, `false` otherwise
"""
function check_r_package(package::String, version::String)
    check_pkg_cmd = """
    check_package <- function(pkg, min_version) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            return(FALSE)
        }
        pkg_version <- as.character(packageVersion(pkg))
        return(package_version(pkg_version) >= package_version(min_version))
    }
    """
    R"$(check_pkg_cmd)"
    return rcopy(R"check_package($(package), $(version))")
end

"""
    install_r_package(package::String, version::String) -> Bool

Install a specific version of an R package.

# Arguments
- `package::String`: The name of the R package
- `version::String`: The version to install

# Returns
- `true` if installation successful, `false` otherwise
"""
function install_r_package(package::String, version::String)
    try
        install_cmd = """
        if (!require("remotes", quietly = TRUE)) {
            install.packages("remotes", repos="https://cloud.r-project.org")
        }
        remotes::install_version($(package), version = $(version), repos = "https://cloud.r-project.org")
        """
        R"$(install_cmd)"
        return true
    catch e
        @warn "Failed to install R package $package version $version" exception=e
        return false
    end
end

"""
    setup_r_environment() -> Bool

Set up the R environment by installing and loading required packages.
"""
function setup_r_environment()
    # Check if setup is still valid
    if SETUP_COMPLETE[] && !isnothing(LAST_SETUP_TIME[])
        time_since_setup = now() - LAST_SETUP_TIME[]
        if time_since_setup < SETUP_TIMEOUT
            return true
        end
    end
    
    try
        # Initialize R
        R"""
        if (!require("classInt")) {
            install.packages("classInt", repos="https://cloud.r-project.org")
        }
        library(classInt)
        """
        
        SETUP_COMPLETE[] = true
        LAST_SETUP_TIME[] = now()
        return true
        
    catch e
        @error "Failed to setup R environment" exception=e
        return false
    end
end

"""
    get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7) -> Dict

Get breaks for population bins using R's classInt package.
"""
function get_breaks(x::Vector{Union{Missing, Int64}}, n::Int=7)
    if !SETUP_COMPLETE[] 
        setup_r_environment()
    end
    
    # Remove missing values
    x = collect(skipmissing(x))
    
    # Convert to R and calculate breaks
    R"""
    x <- $(x)
    breaks <- list(
        kmeans = classInt::classIntervals(x, n = $(n), style = "kmeans"),
        quantile = classInt::classIntervals(x, n = $(n), style = "quantile"),
        jenks = classInt::classIntervals(x, n = $(n), style = "jenks")
    )
    """
    
    return rcopy(R"breaks")
end

# Export the setup function and completion flag
export setup_r_environment, get_breaks, SETUP_COMPLETE

end # module RSetup 