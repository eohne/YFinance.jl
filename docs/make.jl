push!(LOAD_PATH,"../src/")
using YFin
using DataFrames
using Documenter
makedocs(
         sitename = "YFin.jl",
         modules  = [YFin],
         pages=[
                "Home" => "index.md"
               ])
deploydocs(;
    repo="github.com/eohne/YFin.jl",
)
