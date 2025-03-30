# SPDX-License-Identifier: MIT

"""
    RSetup

A submodule for managing R environment setup and integration with the Census package.
Handles installation and loading of required R packages, particularly the classInt package
used for data classification methods.
"""
module RSetup

using RCall

"""
Global flag to track if R environment has been set up
"""
const SETUP_COMPLETE = Ref(false)

"""
    setup_r_environment() -> Bool

Set up the R environment by installing and loading required packages.

# Returns
- `Bool`: `true` if setup completes successfully, `false` otherwise

# Notes
- Installs required R packages if not already installed
- Sets up RCall configuration
- Required packages: classInt
"""
function setup_r_environment()
    try
        # Check if classInt is installed
        R"""
        if (!require("classInt")) {
            install.packages("classInt", repos="https://cloud.r-project.org")
        }
        """
        
        # Load the package
        R"""
        library(classInt)
        """
        
        SETUP_COMPLETE[] = true
        return true
    catch e
        @warn "Failed to set up R environment: $e"
        return false
    end
end

# Export the setup function and completion flag
export setup_r_environment, SETUP_COMPLETE

end # module 