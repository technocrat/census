# SPDX-License-Identifier: MIT

"""
Module for managing R environment setup and package dependencies.

This module handles the configuration of R environment and ensures required packages
are installed for Census data analysis.

# Constants
- `SETUP_COMPLETE::Ref{Bool}`: Flag tracking if R environment is configured
- `R_LIBPATH::String`: R library path configuration
- `R_PACKAGES::Vector{String}`: Required R packages
- `R_CHECK_CODE::String`: R code for package status verification
- `R_INSTALL_CODE::String`: R code for package installation

# Functions
- `setup_r_environment()`: Initialize R environment and verify package installation
- `check_r_packages()`: Verify and install required R packages
"""
module RSetup

using RCall

# Flag to track if setup has been completed
const SETUP_COMPLETE = Ref(false)

# R library path configuration
const R_LIBPATH = """
.libPaths(c("/Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library"))
"""

# Required R packages
const R_PACKAGES = [
    "tidyverse",
    "tidycensus",
    "tigris",
    "sf",
    "ggplot2",
    "dplyr",
    "tidyr",
    "readr",
    "purrr",
    "tibble",
    "stringr",
    "forcats"
]

# R code for package status verification
const R_CHECK_CODE = """
function(packages) {
    installed <- rownames(installed.packages())
    missing <- packages[!packages %in% installed]
    return(list(
        all_installed = length(missing) == 0,
        missing = missing
    ))
}
"""

# R code for package installation
const R_INSTALL_CODE = """
function(packages) {
    install.packages(packages, repos="https://cloud.r-project.org/")
}
"""

"""
    setup_r_environment()

Initialize the R environment and verify package installation.
Returns true if setup is successful, false otherwise.
"""
function setup_r_environment()
    if SETUP_COMPLETE[]
        return true
    end

    try
        # Configure R library path
        R"$R_LIBPATH"
        
        # Check and install required packages
        check_r_packages()
        
        SETUP_COMPLETE[] = true
        return true
    catch e
        @warn "Failed to setup R environment" exception=(e, catch_backtrace())
        return false
    end
end

"""
    check_r_packages()

Verify that all required R packages are installed.
Attempts to install any missing packages.
"""
function check_r_packages()
    try
        # Define R function to check package status
        R"$R_CHECK_CODE"
        
        # Check package status
        result = R"check_packages($R_PACKAGES)"
        
        if !result["all_installed"]
            missing = result["missing"]
            @warn "Missing R packages: $missing"
            
            # Define R function to install packages
            R"$R_INSTALL_CODE"
            
            # Install missing packages
            R"install_packages($missing)"
        end
    catch e
        @warn "Failed to check/install R packages" exception=(e, catch_backtrace())
        rethrow(e)
    end
end

export setup_r_environment, check_r_packages

end # module 