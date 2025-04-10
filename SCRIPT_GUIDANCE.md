# Script Development Guidelines

## Export Policy and Script Requirements

The Census.jl package aims to export all necessary functions and types through a single import (`using Census`), allowing scripts to access all functionality without additional imports. However, due to Julia's module system and type inference limitations with complex reexports, scripts may require direct imports of core packages like DataFrames and DataFramesMeta for reliable operation.

### Recommended Pattern for Scripts

All scripts should follow this import pattern:

```julia
#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta
```

### Creating New Scripts

The recommended way to create a new script is to use the `create_script` function, which will generate a properly configured template:

```julia
# From the Julia REPL
using Census
create_script("my_new_analysis.jl")
```

This will create a new script in the `scripts/` directory with the proper header, imports, and environment settings.

### Understanding the Need for Direct Imports

While it might seem redundant to import packages that are already exported by Census.jl, there are legitimate technical reasons for this pattern:

1. **Type Inference**: Julia's type inference system can sometimes struggle with functions re-exported through multiple layers of modules, particularly for generic functions with complex signatures like those in DataFrames.

2. **Method Dispatch**: Certain functions rely on multiple dispatch with specific type parameters. Re-exported functions may not properly retain all necessary method information.

3. **Namespace Conflicts**: Reexporting everything from large packages can lead to unexpected namespace conflicts.

4. **Practical Stability**: Experience shows that scripts with direct imports are more robust against changes in the Census package's internal structure.

### Manual Fix for Existing Scripts

If you encounter errors like `UndefVarError: subset not defined` or similar, add these lines to your script:

```julia
# Add these environment settings
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Add direct imports
using DataFrames, DataFramesMeta
```

## Script Organization Guidelines

1. All scripts should be in the `scripts/` directory
2. Scripts should be marked with `# SCRIPT` in the header
3. Scripts should use absolute paths where needed
4. All constants should be qualified (e.g., `Census.FLORIDA_GEOIDS`)
5. Function names should be qualified where necessary to avoid ambiguity 