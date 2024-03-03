push!(LOAD_PATH,"../src/")
using YFinance
using Documenter
makedocs(
         sitename = "YFinance.jl",
         format = Documenter.HTML(
            analytics = "G-LFRFQ0X1VF",
            canonical = "https://eohne.github.io/YFinance.jl/dev/"
            # description = "Fetch stock market data from Yahoo Finance in Julia. Exposes stock, commodity, futures, currency (FX), mutual fund, and ETF prices, stock fundamental, summary data , and options data."
            ),
         modules  = [YFinance],
         pages=[
                "Home" => "index.md",
                "Function Documentation" =>[
                    "Prices" =>"Prices.md",
                    "Dividends & Splits" =>"div_split.md",
                    "Fundamental" =>"Fundamental.md",
                    "QuoteSummary" =>"QuoteSummary.md",
                    "Options" =>"Options.md",
                    "ESG" =>"ESG.md",
                    "Search for Symbol"=>"Search Symbols.md",
                    "Get News" => "News Search.md",
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
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#", "dev" => "dev"]
)