# Census.jl Package Loading Guide

This guide addresses the "Package Census not found" error that occurs when trying to use the Census package outside its development environment.

## The Issue

When you see an error like this:

```julia
julia> using Census
ERROR: ArgumentError: Package Census not found in current path.
- Run `import Pkg; Pkg.add("Census")` to install the Census package.
```

This happens because Julia cannot find the Census package in your current LOAD_PATH. Since Census.jl is a local package (not registered in the General registry), Julia doesn't know where to find it.

## Solutions

We've created several helper files to make it easier to use Census.jl in your scripts:

### 1. Use the load_census.jl helper

This is the simplest approach - just include this file at the top of your script:

```julia
include("/path/to/Census.jl/load_census.jl")
# Now Census is available
using Census
```

### 2. Add Census.jl to LOAD_PATH manually

You can add the Census.jl directory to your LOAD_PATH:

```julia
# Add Census.jl to LOAD_PATH
push!(LOAD_PATH, "/path/to/Census.jl")
using Census
```

### 3. Run scripts with Census preloaded

From the command line:

```bash
julia -L /path/to/Census.jl/load_census.jl your_script.jl
```

### 4. Use the run_with_census.jl helper

This helper can run a script with Census.jl properly loaded:

```julia
include("/path/to/Census.jl/run_with_census.jl")
run_script("your_script.jl")
```

### 5. Fix package loading issues

If you're encountering more complex loading issues, run:

```julia
include("/path/to/Census.jl/fix_package_loading.jl")
```

This will diagnose and attempt to fix common loading problems.

## Example Scripts

- `example_script.jl`: Shows how to use Census.jl in a script
- `run_with_census.jl`: Helper to run scripts with Census.jl preloaded
- `load_census.jl`: Simple include file to load Census.jl
- `fix_package_loading.jl`: Diagnostic and fix tool for package loading issues

## For Developers

If you're developing Census.jl, you should:

1. Activate the package environment: `julia --project=/path/to/Census.jl`
2. Now you can use Census: `using Census`

For testing scripts outside the package environment, use one of the methods above.

## Common Issues

1. **Missing DataFrames or DataFramesMeta**: Even with Census loaded, you might need to explicitly import these:
   ```julia
   using DataFrames, DataFramesMeta
   ```

2. **Function undefined errors**: Make sure you're referencing functions with proper qualification if needed:
   ```julia
   # If function not found
   Census.init_census_data()
   ```

3. **Path issues**: If using relative paths, make sure they're relative to the correct directory. 