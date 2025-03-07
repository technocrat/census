function ga(row::Int64, col::Int64, title::String)
    GeoAxis(
        fig[row, col],
        source="+proj=longlat +datum=WGS84",
        dest="+proj=lcc +lon_0=-71 +lat_1=41 +lat_2=45",
        title=title,
        xlabel="",
        ylabel="",
        xgridvisible=false,
        ygridvisible=false,
        xticksvisible=false,
        yticksvisible=false,
        xticklabelsvisible=false,
        yticklabelsvisible=false,
    )
end
