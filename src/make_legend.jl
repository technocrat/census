"""
   make_legend(values)

Create a legend showing ranges between consecutive values, with the first entry showing
"< lowest_value". Numbers are formatted with comma separators.

Example:
   julia> make_legend([10000, 90000, 190000])
   3-element Vector{String}:
    "< 10,000"
    "10,000 - 90,000" 
    "90,000 - 190,000"
"""
function make_legend(values)
   sorted = sort(unique(values))
   legend = String[]
   push!(legend, "< $(format_number(sorted[1]))")
   for i in 1:length(sorted)-1
       push!(legend, "$(format_number(sorted[i])) - $(format_number(sorted[i+1]))")
   end
   legend
end

function format_number(n)
   return replace(string(n), r"(?<=[0-9])(?=(?:[0-9]{3})+(?![0-9]))" => ",")
end
