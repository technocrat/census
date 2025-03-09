"""
  format_with_commas(df::DataFrame) -> DataFrame

Convert numeric columns in a DataFrame to strings with comma separators for thousands.
Returns a new DataFrame with the formatted values, leaving non-numeric columns unchanged.

The function:
- Preserves missing values, converting them to the string "missing"
- Adds commas every three digits for readability
- Creates a copy of the input DataFrame to avoid modifying the original
- Only processes columns of type Number or Union{Missing, Number}

Example:
```julia
df = DataFrame(a = [1234, 567, missing], b = ["x", "y", "z"])
formatted_df = format_with_commas(df)
# Result:
# 3×2 DataFrame
#  Row │ a         b      
#      │ String    String 
# ─────┼─────────────────
#    1 │ 1,234    x
#    2 │ 567      y
#    3 │ missing  z
"""
function format_with_commas(df::DataFrame)
  formatted_df = copy(df)
  
  for col in names(formatted_df)
    if eltype(df[!, col]) <: Union{Missing, Number}
      formatted_df[!, col] = map(formatted_df[!, col]) do x
        if ismissing(x)
          "missing"
        elseif abs(x) <= 99  # Only format numbers > 99 or < -99 with commas
          string(x)
        else
          sign_str      = x < 0 ? "-" : ""  # Extract sign for negative numbers
          num_str       = reverse(string(abs(x)))  # Convert number to string and reverse
          chunks        = [num_str[i:min(i+2, end)] for i in 1:3:length(num_str)]
          formatted_num = reverse(join(chunks, ","))  # Add commas and reverse back
          sign_str * formatted_num  # Prepend sign if negative
        end
      end
    end
  end
  
  return formatted_df
end
