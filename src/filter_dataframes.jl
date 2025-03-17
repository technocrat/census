# SPDX-License-Identifier: MIT

function filter_dataframes()
    # Get variable names in the current namespace
    df_names = filter(name -> isa(getfield(Main, name), DataFrame), names(Main))
    return df_names
end
