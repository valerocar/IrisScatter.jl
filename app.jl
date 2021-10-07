using Pkg
Pkg.activate(".")
using PlotlyJS
using RDatasets
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents

struct Style
    layout::Layout
    global_trace::PlotlyBase.PlotlyAttribute
end

iris = RDatasets.dataset("datasets", "iris")
#
# Creation of Dash App starts here
#

app = dash(external_stylesheets=[dbc_themes.CYBORG])
app.title = "Iris Dataset"

app.layout = html_div(
    [html_center([html_h1("Iris Dataset Scatter Plot")]),html_br(),
    html_center([dcc_graph(id = "graph"),html_div(style=Dict(
        "max-width" => "620px"),[html_br(),html_p("Petal Width Range"),dcc_rangeslider(
            id = "slider",
            min = 0.0,
            max = 2.5,
            step=0.1,
            marks = Dict(0=>"0.0",2.5=>"2.5"),
            value = [0.0,2.5]
        )])]),
    html_br(), 
    
])
callback!(app, Output("graph", "figure"), Input("slider", "value")) do input_value
    low = input_value[1]
    high = input_value[2]
    layout = Layout(;title="",width=600, height=400,xaxis=attr(title="Sepal Width"), yaxis=attr(title="Sepal Length"),template=templates["plotly_dark"])
    mask = (low.<iris."PetalWidth") .& (iris."PetalWidth" .< high)
    scale = 5.0

    dc = Dict("setosa"=>1, "virginica"=>2, "versicolor"=>3)
    cat = [dc[string(f)] for f = iris."Species"]  
    sw = ["Petal Width = $w" for w in iris."PetalWidth"]
    fig = scatter(iris[mask,:], x=:SepalWidth, y=:SepalLength, marker_color=cat, mode="markers", marker_size=scale*iris."PetalLength", text=sw)
    plot(fig, layout)
end

run_server(app, "0.0.0.0", debug=true)

