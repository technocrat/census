# SPDX-License-Identifier: MIT
function ga(dest::String, row::Int64, col::Int64, title::String, fig::Figure)
    GeoAxis(
        fig[row, col],
        source="+proj=longlat +datum=WGS84",
        dest=dest,
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
