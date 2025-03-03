function get_childbearing_population(df)
    return Float64.(sum(df[4:9, 2]) / 1e3)
end