#!/usr/bin/env julia

"""
check_rcall_integration.jl

This script checks Julia files in the project for proper RCall integration patterns.
It identifies files that might need to be updated to avoid REPL integration issues.

Usage:
    julia check_rcall_integration.jl [directory]
"""

# Function to check if a file contains proper RCall usage patterns
function check_file(filepath)
    issues = String[]
    content = read(filepath, String)
    
    # Check if file uses RCall
    if occursin("using RCall", content) || occursin("import RCall", content)
        # Check if REPL integration is disabled
        if !occursin("ENV[\"RCALL_ENABLE_REPL\"]", content) && !occursin("ENV['RCALL_ENABLE_REPL']", content)
            push!(issues, "Does not explicitly disable RCALL_ENABLE_REPL")
        end
        
        # Check if it imports all of RCall instead of specific functions
        if (occursin("using RCall\n", content) || 
            occursin("using RCall;", content) || 
            occursin("using RCall ", content)) && 
           !occursin("using RCall:", content)
            push!(issues, "Imports all of RCall instead of specific functions")
        end
        
        # Check for actual R string macro usage (not in comments or documentation)
        lines = split(content, '\n')
        for (i, line) in enumerate(lines)
            # Skip comments and strings discussing R"..." syntax
            if occursin("R\"", line) && 
               !startswith(strip(line), "#") && 
               !occursin("instead of R\"", line) && 
               !occursin("comment about R\"", line) && 
               !occursin("avoid R\"", line) && 
               !occursin("replace R\"", line)
                # Found a potential R string macro usage
                context = "$(lines[max(1, i-1)])\n$(line)\n$(lines[min(length(lines), i+1)])"
                if !occursin("reval(rparse(", context)
                    push!(issues, "Uses R string macros instead of reval/rparse")
                    break
                end
            end
        end
    end
    
    return issues
end

# Main function
function main()
    directory = length(ARGS) > 0 ? ARGS[1] : "."
    
    julia_files = String[]
    for (root, dirs, files) in walkdir(directory)
        for file in files
            if endswith(file, ".jl")
                push!(julia_files, joinpath(root, file))
            end
        end
    end
    
    problem_files = Dict{String, Vector{String}}()
    
    for file in julia_files
        issues = check_file(file)
        if !isempty(issues)
            problem_files[file] = issues
        end
    end
    
    if isempty(problem_files)
        println("✅ All files check out! No RCall integration issues found.")
        return 0
    else
        println("⚠️ Found $(length(problem_files)) files with potential RCall integration issues:")
        for (file, issues) in problem_files
            println("\n  📄 $(file):")
            for issue in issues
                println("    • $(issue)")
            end
        end
        
        println("\nRecommendations:")
        println("1. Ensure all files using RCall set ENV[\"RCALL_ENABLE_REPL\"] = \"false\"")
        println("2. Replace R string macros with reval(rparse(...))")
        println("3. Import only specific functions: using RCall: reval, rcopy, rparse")
        
        return 1
    end
end

exit(main()) 