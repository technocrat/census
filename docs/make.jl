using Documenter
using Census

makedocs(
    sitename = "Census",
    format = Documenter.HTML(),
    modules = [Census],
    pages = [
        "Home" => "index.md",
        "API Reference" => [
            "Core Functions" => "api/core.md",
            "Data Processing" => "api/data_processing.md",
            "Visualization" => "api/visualization.md"
        ],
        "Tutorials" => [
            "Getting Started" => "tutorials/getting_started.md",
            "Population Analysis" => "tutorials/population.md",
            "Economic Analysis" => "tutorials/economics.md"
        ]
    ],
    doctest = true,
    clean = true,
    checkdocs = :none  # Temporarily disable checking for missing docstrings
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/USERNAME/Census.jl.git"  # Update this with your actual repository
) 