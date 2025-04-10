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

function update_pop_bins!(df::DataFrame, to_gl::Vector)
    # Loop through each row in the DataFrame
    for i in 1:nrow(df)
        # Check if the geoid is in the to_gl list
        if df[i, :geoid] in to_gl
            # Update the pop_bins value to 7
            df[i, :pop_bins] = 7
        end
    end
    return df
end

# Example usage:
# to_gl = ["36001", "36005", "36047", "36061", "36081", "36085"] # Example geoid list
update_pop_bins!(df, to_gl)
