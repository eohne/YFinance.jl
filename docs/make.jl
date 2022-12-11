push!(LOAD_PATH,"../src/")
using YFinance
using Documenter
makedocs(
         sitename = "YFinance.jl",
         modules  = [YFinance],
         pages=[
                "Home" => "index.md",
                "Function Documentation" =>[
                    "Prices" =>"Prices.md",
                    "Fundamental" =>"Fundamental.md",
                    "QuoteSummary" =>"QuoteSummary.md",
                    "Options" =>"Options.md",
                    "ESG" =>"ESG.md",
                    "All Functions" =>"AllFunctions.md",
                ]
               ])
deploydocs(;
    repo="github.com/eohne/YFinance.jl",
)
