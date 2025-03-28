using RCall

# Flag to track if setup has been completed
const SETUP_COMPLETE = Ref(false)

const R_LIBPATH = """
.libPaths(c("/Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library"))
"""

const R_PACKAGES = ["classInt","ggplot2", "tidyr", "dplyr", "tidycensus", "tigris"]

const R_CHECK_CODE = """
pkg_status <- data.frame(
    Package = c($(join(map(x -> "\"$x\"", R_PACKAGES), ", "))),
    Installed = sapply(c($(join(map(x -> "\"$x\"", R_PACKAGES), ", "))),
                      function(x) as.character(require(x, character.only = TRUE)))
)
print(pkg_status)
pkg_status
"""

const R_INSTALL_CODE = """
packages <- c($(join(map(x -> "\"$x\"", R_PACKAGES), ", ")))
for(pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
        message(sprintf("Installing %s...", pkg))
        install.packages(pkg, repos = "https://cran.rstudio.com/")
        if (!require(pkg, character.only = TRUE)) {
            warning(sprintf("Failed to install or load %s", pkg))
        }
    } else {
        message(sprintf("%s is already installed and loaded", pkg))
    }
}
"""

"""
    check_r_packages()

Verifies installation status of required R packages.

# Effects
- Prints a status table of required packages and their installation state
- Uses the R library path defined in `R_LIBPATH`
- Checks for all packages listed in `R_PACKAGES`

# Returns
Returns `nothing`. Outputs package status to console.

# Notes
- If `SETUP_COMPLETE` is true, returns immediately
- Requires RCall to be properly configured
"""
function check_r_packages()
    if SETUP_COMPLETE[]
        return nothing
    end

    R"$(R_LIBPATH)"
    R"$(R_CHECK_CODE)"
end

"""
    install_r_packages()

Installs missing R packages required for Census data analysis.

# Effects
- Attempts to install any missing packages from `R_PACKAGES`
- Uses CRAN mirror "https://cran.rstudio.com/"
- Sets R library path according to `R_LIBPATH`

# Returns
Returns `nothing`. Installation progress is printed to console.

# Notes
- Does not modify `SETUP_COMPLETE` flag
- Will attempt to install even if packages are present
- May require internet connection
"""
function install_r_packages()
    R"$(R_LIBPATH)"
    R"$(R_INSTALL_CODE)"
end

"""
    setup_r_environment()

Initializes the R environment and verifies all required packages.

# Effects
- Checks for required R packages
- Sets `SETUP_COMPLETE` flag if successful
- Issues warning if environment check fails

# Returns
Returns `nothing` if setup succeeds.

# Throws
- Rethrows any exceptions from package verification
- May throw R-related errors if packages cannot be loaded

# Notes
- Safe to call multiple times (subsequent calls return immediately if setup is complete)
- Uses `check_r_packages()` internally
- Does not automatically install missing packages

# Example
```julia
try
    setup_r_environment()
catch e
    @warn "Setup failed, attempting package installation..."
    install_r_packages()
    setup_r_environment()
end
```

See also: [`check_r_packages`](@ref), [`install_r_packages`](@ref), [`RCall`](@ref)
"""
function setup_r_environment()
    if SETUP_COMPLETE[]
        return nothing
    end

    try
        check_r_packages()
        SETUP_COMPLETE[] = true
    catch e
        @warn "R environment check failed. You may need to run install_r_packages()" exception=e
        rethrow(e)
    end
end
