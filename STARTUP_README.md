# Census.jl Startup Integration

This directory contains scripts to automatically load Census.jl when starting Julia. These scripts help solve the "Package Census not found" error by automatically configuring your Julia environment.

## Key Features

- **Automatic Loading**: Census.jl is loaded automatically when you start Julia
- **Common Dependencies**: DataFrames and DataFramesMeta are automatically loaded
- **Script Templates**: Generate new scripts with proper imports using `create_script.jl`

## Quick Setup

For the fastest setup, run:

```bash
julia install_startup.jl
```

This will install the startup script that automatically loads Census.jl and DataFrames/DataFramesMeta when you start Julia.

## Available Scripts

### Regular Julia REPL

- `startup.jl` - Automatically adds Census.jl to your LOAD_PATH and loads the module with dependencies
- `install_startup.jl` - Installs the startup script to `~/.julia/config/startup.jl`

### Jupyter Notebooks

- `jupyter_kernel_startup.jl` - Automatically loads Census.jl in Jupyter notebooks
- `install_jupyter_startup.jl` - Configures your Jupyter kernel to use the startup script

### Script Creation

- `create_script.jl` - Generate new scripts with proper imports and templates
  ```bash
  julia create_script.jl my_analysis.jl
  julia create_script.jl map_visualization.jl map
  ```

## No More Manual Imports

With these startup scripts, you no longer need to manually add these imports to your scripts:

```julia
using DataFrames, DataFramesMeta  # Now handled automatically
```

Simply use:

```julia
using Census  # This now includes DataFrames and DataFramesMeta
```

## Manual Installation

### Julia REPL

1. Copy `startup.jl` to `~/.julia/config/startup.jl`
2. Edit the path in the script if Census.jl is not in `~/projects/Census.jl`

### Jupyter Notebooks

1. Find your Julia kernel directory (run `IJulia.find_jupyter_kernel("julia")`)
2. Copy `jupyter_kernel_startup.jl` to that directory as `kernel_startup.jl`
3. Edit your `kernel.json` to include `--load=/path/to/kernel_startup.jl`

## How It Works

The startup scripts perform the following actions:

1. Add the Census.jl directory to Julia's LOAD_PATH
2. Load DataFrames and DataFramesMeta packages
3. Load the Census module
4. Display confirmation messages

This ensures Census.jl and its dependencies are available in your Julia sessions without having to manually add imports to each script.

## Troubleshooting

If you encounter issues:

1. Make sure the path to Census.jl is correct in the startup script
2. Try running `include("/path/to/Census.jl/fix_package_loading.jl")` for diagnostics
3. Verify you can load Census.jl manually: `push!(LOAD_PATH, "/path/to/Census.jl"); using Census`

If all else fails, refer to the full [Census.jl Package Loading Guide](./CENSUS_LOADING.md). 