# YFinance.jl
[![codecov](https://codecov.io/github/eohne/YFinance.jl/graph/badge.svg?token=MYY3JY9HBH)](https://codecov.io/github/eohne/YFinance.jl)
[![Build Status](https://github.com/eohne/YFinance.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/eohne/YFinance.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Package Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Ftotal_downloads%2FYFinance&query=total_requests&label=Downloads)](http://juliapkgstats.com/pkg/YFinance)
[![][docs-stable-img]][docs-stable-url]  
[![][docs-dev-img]][docs-dev-url]  

*Download price, fundamental, option, currency, futures, ETF, mutual fund, and various other data from Yahoo Finance*  


## \*\*\* LEGAL DISCLAIMER \*\*\*
**Yahoo!, Y!Finance, and Yahoo! finance are registered trademarks of
Yahoo, Inc.**

YFinance.jl is not endorsed or in anyway affiliated with Yahoo, Inc. The data retreived can only be used for personal use. 
Please see Yahoo's terms of use to ensure that you can use the data:
 - [Yahoo Developer API Terms of Use](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm)
 - [Yahoo Terms of Service](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html)
 - [Yahoo Terms](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)


## \*\*\* No decryption issues \*\*\*
The implementation of `YFinance.jl` is similar to the python package `yahooquery` in that it accesses data through API endpoints. Therefore, **`YFinance.jl` does not experience the same decryption issues** that python’s `yfinance` faces at the moment.


## Installation

The package is registered in the [`General`](https://github.com/JuliaRegistries/General) registry and so can be installed at the REPL with `] add YFinance` or by running:
```julia 
    using Pkg 
    Pkg.add("YFinance")
```

# Examples:

There are more examples in the Docs.

## Get Prices:  
Apple monthly stock price over the past 5 years, with dividend and stock split information in local user time.  

```julia
using YFinance

get_prices("AAPL",range="5y",interval="1mo",divsplits=true,exchange_local_time=false)
```
```julia
OrderedCollections.OrderedDict{String, Any} with 8 entries:
  "ticker"    => "AAPL"
  "timestamp" => [DateTime("2019-09-01T04:00:00"), DateTime("2019-10-01T04:00:00"), DateTime("2019-11-01T04:00:00"), DateT…
  "open"      => [49.9955, 54.5099, 60.4363, 64.9247, 71.9621, 73.92, 68.7337, 60.0214, 69.7003, 77.5799  …  189.83, 186.6…
  "high"      => [54.8369, 60.4872, 64.9072, 71.4106, 79.6407, 79.4877, 74.0224, 71.7165, 78.9507, 90.918  …  199.096, 195…
  "low"       => [49.4603, 52.1026, 60.3443, 62.2575, 71.1143, 62.2769, 51.7694, 57.6839, 69.6029, 77.448  …  186.958, 179…
  "close"     => [55.9925, 62.19, 66.8125, 73.4125, 77.3775, 68.34, 63.5725, 73.45, 79.485, 91.2  …  192.53, 184.4, 180.75…
  "adjclose"  => [54.2435, 60.2474, 64.7255, 71.3329, 75.1856, 66.4041, 61.9183, 71.5387, 77.4167, 89.0673  …  192.024, 18…
  "vol"       => [2.10248e9, 2.35721e9, 1.73731e9, 2.32113e9, 2.85125e9, 2.93375e9, 6.11666e9, 3.18033e9, 2.73292e9, 3.167…
```  


## Convert to DataFrame  
Bitcoin USD, 5 minute data points for an entire day.  

```julia
DataFrame(get_prices("BTC-USD",range="1d",interval="5m",exchange_local_time=true))
```
```julia
147×7 DataFrame
 Row │ ticker   timestamp            open     high     low      close    vol       
     │ String   DateTime             Float64  Float64  Float64  Float64  Float64
─────┼─────────────────────────────────────────────────────────────────────────────
   1 │ BTC-USD  2024-08-08T00:00:00  55139.5  55254.3  55139.5  55254.3  7.3769e6
   2 │ BTC-USD  2024-08-08T00:05:00  55229.6  55355.9  55229.6  55355.9  0.0
   3 │ BTC-USD  2024-08-08T00:10:00  55273.2  55273.2  55121.3  55121.3  1.9198e7
   4 │ BTC-USD  2024-08-08T00:15:00  55099.8  55272.9  55099.8  55232.8  0.0
  ⋮  │    ⋮              ⋮              ⋮        ⋮        ⋮        ⋮         ⋮
 145 │ BTC-USD  2024-08-08T12:00:00  57346.1  57406.9  57346.1  57406.9  0.0
 146 │ BTC-USD  2024-08-08T12:05:00  57384.4  57384.4  57364.8  57364.8  0.0
 147 │ BTC-USD  2024-08-08T12:08:00  57330.2  57330.2  57330.2  57330.2  0.0
                                                                   140 rows omitted
```

## Sink to TimeArray  

TSLA daily stock price between 2020-01-01 and 2020-05-30 without adjustments for dividends and splits  

```julia
using TimeSeries
get_prices(TimeArray,"TSLA",startdt="2020-01-01",enddt="2020-05-30")
```  

```julia
103×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2020-01-02T14:30:00 to 2020-05-29T13:30:00
┌─────────────────────┬─────────┬─────────┬─────────┬─────────┬──────────┬───────────┐
│                     │ open    │ high    │ low     │ close   │ adjclose │ vol       │
├─────────────────────┼─────────┼─────────┼─────────┼─────────┼──────────┼───────────┤
│ 2020-01-02T14:30:00 │    28.3 │ 28.7133 │  28.114 │  28.684 │   28.684 │ 1.42982e8 │
│ 2020-01-03T14:30:00 │ 29.3667 │ 30.2667 │  29.128 │  29.534 │   29.534 │ 2.66678e8 │
│ 2020-01-06T14:30:00 │ 29.3647 │  30.104 │ 29.3333 │ 30.1027 │  30.1027 │ 1.51995e8 │
│ 2020-01-07T14:30:00 │   30.76 │  31.442 │  30.224 │ 31.2707 │  31.2707 │ 2.68232e8 │
│          ⋮          │    ⋮    │    ⋮    │    ⋮    │    ⋮    │    ⋮     │     ⋮     │
│ 2020-05-27T13:30:00 │  54.724 │ 55.1807 │ 52.3333 │  54.682 │   54.682 │ 1.73242e8 │
│ 2020-05-28T13:30:00 │  54.234 │ 54.9833 │  53.446 │ 53.7207 │  53.7207 │ 1.08834e8 │
│ 2020-05-29T13:30:00 │ 53.9167 │ 55.6667 │  53.614 │ 55.6667 │  55.6667 │ 1.76468e8 │
└─────────────────────┴─────────┴─────────┴─────────┴─────────┴──────────┴───────────┘
                                                                       96 rows omitted
```

## Sink to TSFrame  
S&P500 (^GSPC) daily price since start of data  

```julia
using TSFrames
tsf = get_prices(TSFrame,"^GSPC",startdt=Date(1900,1,1),enddt=today())
```  

```julia
24266×7 TSFrame with DateTime Index
 Index                open     high     low      close    adjclose  vol        ticker 
 DateTime             Float64  Float64  Float64  Float64  Float64   Float64    String
──────────────────────────────────────────────────────────────────────────────────────
 1927-12-30T14:30:00    17.66    17.66    17.66    17.66     17.66  0.0        ^GSPC
 1928-01-03T14:30:00    17.76    17.76    17.76    17.76     17.76  0.0        ^GSPC
 1928-01-04T14:30:00    17.72    17.72    17.72    17.72     17.72  0.0        ^GSPC
 1928-01-05T14:30:00    17.55    17.55    17.55    17.55     17.55  0.0        ^GSPC
          ⋮              ⋮        ⋮        ⋮        ⋮        ⋮          ⋮        ⋮
 2024-08-05T13:30:00  5151.14  5250.89  5119.26  5186.33   5186.33  5.33325e9  ^GSPC
 2024-08-06T13:30:00  5206.42  5312.34  5193.56  5240.03   5240.03  4.69019e9  ^GSPC
 2024-08-07T13:30:00  5293.13  5330.64  5195.54  5199.5    5199.5   4.55826e9  ^GSPC
                                                                    24259 rows omitted
```

### Plot this:
```julia
using Plots
plot(tsf[:,[:Index,:adjclose]])
```  
![S&P500](docs/src/assets/CompWI.svg)

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://eohne.github.io/YFinance.jl/stable/

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://eohne.github.io/YFinance.jl/dev/

