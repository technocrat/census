<!-- Generated by SpecStory -->

# Correcting Julia Function Signature (2025-03-20 03:10:01)

_**User**_

Correct function signature for default


---

_**Assistant**_

I'll help fix the function signature for the `output_map` function. The current signature has an issue with the default argument `df` and the non-default argument `title` ordering. In Julia, non-default arguments must come before default arguments.

Here's the corrected version:

```julia:scripts/adj_factor.jl
// ... existing code ...
function output_map(title::String, df::DataFrame=df)
   fig = Figure(size=(1200, 800), fontsize=22)
   title = Label(fig[0, 2], title, fontsize=20)
   ga1 = ga(1, 1, "Population")
   poly1 = map_poly(df,ga1, "pop")
   add_labels!(df, ga1, :geoid, fontsize=6)
   display(fig)
end
```

The change swaps the order of the parameters so that `title` (which has no default) comes before `df` (which has a default value). This follows Julia's requirement that all parameters with default values must come after parameters without default values.

---



---

