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
                    "Proxy" => "Proxies.md",
                    "All Functions" =>"AllFunctions.md",
                ],
                "Example Usage" => [
                    "Convert to DataFrames, TimeArrays, TSFrames" => "DataFramesetc.md",
                    "Plotting Data with PlotlyJS" => "Plotting_Example.md"
                ],
                "Version Change Log" => "VersionChanges.md"
               ])
deploydocs(;
    repo="github.com/eohne/YFinance.jl",
)
