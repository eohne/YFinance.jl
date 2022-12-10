push!(LOAD_PATH,"../src/")
using YFinance
using Documenter
makedocs(
         sitename = "YFinance.jl",
         modules  = [YFinance],
         pages=[
                "Home" => "index.md"
               ])
deploydocs(;
    repo="github.com/eohne/YFinance.jl",
)
