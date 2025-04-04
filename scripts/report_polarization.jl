using Census

# Define paths relative to project root
const PROJECT_ROOT = dirname(dirname(@__FILE__))
const PARTIALS_DIR = joinpath(PROJECT_ROOT, "_layout", "partials")

function report_polarization(recently::DataFrame, historical::DataFrame, 
                           nations::Vector{Vector{String}} = nations, 
                           titles::Vector{String} = Titles,    
                           base_path::String=PARTIALS_DIR)
    for nation in Titles
        grab = filter(:nation => (x -> x == nation), recently)
        recent_html = "<p>Politcal polarization of " * grab[1,1] * ", as measured by the " *
            "margin between votes for the two major party political nominees, was " *
            grab[1,7] * " in the 2024 election. "
            
        grab = filter(:nation => (x -> x == nation), historical)
        historical_html = "<p>Politcal polarization of " * grab[1,1] * ", as measured by the " *
            "margin between votes for the two major party political nominees, was " *
            grab[1,7] * " over the elections from 1968-2020.</p>"
            
        # Combine the HTML content
        modified_html = recent_html * historical_html
        
        # Create the output file path
        output_file = joinpath(base_path, "$(nation)_polarization_sentence.html")
        
        # Write to file
        open(output_file, "w") do f
            write(f, modified_html)
        end
    end
end