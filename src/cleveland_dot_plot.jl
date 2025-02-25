"""
    cleveland_dot_plot(df::DataFrame, value_col::Symbol, label_col::Symbol; 
                      xlabel::String="", title::String="Cleveland Dot Plot")

Create a Cleveland dot plot with polynomial trend line and reference features.

# Arguments
- `df::DataFrame`: Input DataFrame containing the data
- `value_col::Symbol`: Column name for the values to be plotted on x-axis
- `label_col::Symbol`: Column name for the labels to be shown on y-axis
- `xlabel::String`: Label for x-axis (default: "")
- `title::String`: Title for the plot (default: "Cleveland Dot Plot")

# Features
- Sorts data by value in descending order
- Adds a 3rd-degree polynomial trend line
- Shows 80% threshold line
- Includes reference lines to y-axis
- Formats x-axis labels in thousands (K)

# Returns
- A Plots.Plot object

# Example
p = cleveland_dot_plot(ne_pop, :total_population, :name, 
                      xlabel="Population", 
                      title="Population of New England Counties")
"""
function cleveland_dot_plot(df::DataFrame, 
                          value_col::Symbol, 
                          label_col::Symbol;  
                          xlabel::String="",
                          title::String="Cleveland Dot Plot")
    
    # Drop any rows with missing values and sort
    df_clean  = dropmissing(df, [value_col, label_col])
    df_sorted = sort(df_clean, value_col, rev=true)
    
    # Calculate 80% threshold using non-missing values
    value_threshold = sum(skipmissing(df_clean[:, value_col])) * 0.8
    
    # Create positions array for curve fitting
    positions = 1:nrow(df_sorted)
    values    = collect(df_sorted[:, value_col])
    
    # Fit polynomial curve
    poly_fit  = Polynomials.fit(positions, Float64.(values), 3)
    
    # Create interpolated points for smoother curve
    x_smooth  = range(1, nrow(df_sorted), length=100)
    y_smooth  = poly_fit.(x_smooth)
    
    # Fixed x-axis limits
    x_min = 0
    x_max = 1_600_000
    
    p = Plots.plot(
        values,
        positions,
        seriestype = :scatter,
        marker     = (:circle, 8),
        color      = :blue,
        legend     = false,
        xlabel     = xlabel,
        title      = title,
        yticks     = (1:nrow(df_sorted), df_sorted[:, label_col]),
        yflip      = true,
        grid       = (:x, :gray, 0.2),
        size       = (1000, max(400, 20 * nrow(df_sorted))),
        margin     = 25mm,
        xlims      = (x_min, x_max),
        xticks     = 0:200_000:1_600_000,
        formatter  = :plain,
        xformatter = x -> string(round(Int, x/1000), "K")
    )
    
    # Add the fitted curve
    Plots.plot!(y_smooth, x_smooth, 
        color     = :red, 
        linewidth = 2, 
        alpha     = 0.6,
        label     = "Trend"
    )
    
    # Add vertical line at 80% threshold
    Plots.vline!([value_threshold], 
        color     = :green, 
        linewidth = 2, 
        linestyle = :dash,
        label     = "80% of Total"
    )
    
    # Add reference lines connecting to y-axis
    for i in 1:nrow(df_sorted)
        Plots.plot!(
            [0, values[i]], 
            [i, i], 
            color     = :gray, 
            alpha     = 0.3,
            linewidth = 0.5
        )
    end
    
    return p
end