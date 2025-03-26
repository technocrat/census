using CSV
using Colors
using DataFrames
using Graphs
using GraphPlot
using PretyTables

include("src/cons.jl")

postals = STATES
df = CSV.read("data/la_migra_filtered.csv",DataFrame)
push!(postals,"PR")
df.spusps = postals
ne_flows =  filter(:spusps => x -> x in NE,df)
ne_flows =  ne_flows[:,(names(ne_flows) .∈ [NE])]
ne_flows.stusps = names(ne_flows)[1:6]
row_totals = combine(ne_flows, 
    AsTable([:CT, :ME, :MA, :NH, :RI, :VT]) => 
        ByRow(x -> sum(skipmissing(x))) => :outflow_total)
# Column totals
col_totals = combine(ne_flows, 
    [:CT, :ME, :MA, :NH, :RI, :VT] .=> (x -> sum(skipmissing(x)) .=> 
    Symbol.([:CT, :ME, :MA, :NH, :RI, :VT], "_total")))
outies = row_totals[:,1]
ne_flows.Outflows = outies
# Create the new row with explicit typing
# Create the new row with explicit typing
inflow_row = (
    CT = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.CT))),
    ME = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.ME))),
    MA = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.MA))),
    NH = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.NH))),
    RI = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.RI))),
    VT = convert(Union{Missing, Int64}, sum(skipmissing(ne_flows.VT))),
    stusps = "Inflows",
    Outflows = sum(ne_flows.Outflows)  # Changed from 'out' to 'Outflows'
)

# Add the row to the dataframe
push!(ne_flows, inflow_row)
include("src/format_with_commas.jl")
ne_flows = format_with_commas(ne_flows)
for col in names(ne_flows)
    ne_flows[!, col] = replace.(ne_flows[!, col], "missing" => "—")  
end
ne_flows=ne_flows[:,[:stusps,:CT,:ME,:MA,:NH,:RI,:VT,:Outflows]]
rename!(ne_flows,:stusps=> "State")
pretty_table(ne_flows, backend = Val(:text), show_subheader = false) 
net_internal_migration = sum(skipmissing(Matrix(select(ne_flows, [:CT, :ME, :MA, :NH, :RI, :VT]))))

# Create net flows, but only store in one direction
net_flows = zeros(Float64, 6, 6)
threshold = 100

for i in 1:6
    for j in i+1:6  # Only process each pair once
        if i != j
            flow_i_to_j = ismissing(ne_flows[i,j]) ? 0.0 : Float64(ne_flows[i,j])
            flow_j_to_i = ismissing(ne_flows[j,i]) ? 0.0 : Float64(ne_flows[j,i])
            net_flow = flow_i_to_j - flow_j_to_i
            if abs(net_flow) > threshold
                if net_flow > 0
                    net_flows[i,j] = net_flow
                else
                    net_flows[j,i] = -net_flow
                end
            end
        end
    end
end

# Create directed graph
G_net = SimpleDiGraph(6)
edge_weights_net = Float64[]

# Add edges for non-zero flows
for i in 1:6
    for j in 1:6
        if net_flows[i,j] > 0
            add_edge!(G_net, i, j)
            push!(edge_weights_net, net_flows[i,j])
        end
    end
end

# Modified scaling: use sqrt instead of log to maintain better visibility of small flows
edge_weights_net = sqrt.(edge_weights_net)

# Normalize and scale with minimum thickness
min_weight = minimum(edge_weights_net)
max_weight = maximum(edge_weights_net)
edge_weights_net = (edge_weights_net .- min_weight) ./ (max_weight - min_weight)
edge_weights_net = 1.0 .+ edge_weights_net .* 14.0  # Minimum thickness of 1.0

# Generate layout
n = nv(G_net)
locs_x = Float64[]
locs_y = Float64[]
for i in 1:n
    angle = 2π * (i-1) / n
    push!(locs_x, cos(angle))
    push!(locs_y, sin(angle))
end

# Create visualization
p = gplot(G_net, locs_x, locs_y,
    nodelabel=states,
    edgelinewidth=edge_weights_net,
    nodesize=0.2,
    arrowlengthfrac=0.1,
    arrowangleoffset=π/12
)

# Save as SVG
draw(SVG("internal_flows.svg", 16cm, 16cm), p)

# Print net flows for verification (only positive direction)
println("\nSignificant net flows (>$threshold):")
for i in 1:6
    for j in 1:6
        if net_flows[i,j] > 0
            println("$(states[i]) → $(states[j]): $(round(Int, net_flows[i,j]))")
        end
    end
end