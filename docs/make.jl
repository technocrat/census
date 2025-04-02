using Documenter
using Census

makedocs(
    sitename = "Census.jl",
    format = Documenter.HTML(),
    modules = [Census],
    pages = [
        "Home" => "index.md",
        "API Reference" => [
            "Main Functions" => "api/main.md",
            "Types" => "api/types.md",
            "Helper Functions" => "api/helpers.md"
        ],
        "Tutorials" => [
            "Getting Started" => "tutorials/getting_started.md",
            "Working with Variables" => "tutorials/variables.md",
            "Geographic Data" => "tutorials/geography.md",
            "Mapping" => "tutorials/mapping.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/username/Census.jl.git",
    devbranch = "main"
) 