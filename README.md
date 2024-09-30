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

## Precompilation  

### Version 0.1.8 
Precompilation of the `get_prices` function. This has caused precompilation hangs for Julia 1.10 and 1.11 - package typically still precompiles but takes long and gives warnings. One user at least has reported errors. Note precompilation also does not work if you require to set a proxy to access the internet. 

To Install this version enter the package mode by entering `]` in the REPL and run the following command:
```julia
(@v1.10) pkg> add YFinance @v0.1.8
```

### Version 0.1.9 
Does not precompile.  
To Install this version enter the package mode by entering `]` in the REPL and run the following command:
```julia
  (@v1.10) pkg> add YFinance
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

Rolls-Royce daily stock price between 2020-01-01 and 2020-05-30

```julia
using TimeSeries
get_prices(TimeArray,"RR.L",startdt="2020-01-01",enddt="2020-05-30")
```  

```julia
103×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2020-01-02T08:00:00 to 2020-05-29T07:00:00
┌─────────────────────┬─────────┬─────────┬─────────┬─────────┬──────────┬───────────┐
│                     │ open    │ high    │ low     │ close   │ adjclose │ vol       │
├─────────────────────┼─────────┼─────────┼─────────┼─────────┼──────────┼───────────┤
│ 2020-01-02T08:00:00 │ 236.374 │ 238.845 │ 232.874 │ 233.766 │  233.766 │ 1.12197e7 │
│ 2020-01-03T08:00:00 │ 232.668 │ 233.629 │  229.03 │ 232.599 │  232.599 │  1.2363e7 │
│ 2020-01-06T08:00:00 │ 231.295 │ 233.766 │ 228.932 │ 232.325 │  232.325 │ 1.13855e7 │
│ 2020-01-07T08:00:00 │ 234.041 │  234.26 │ 227.658 │ 229.305 │  229.305 │ 9.56679e6 │
│          ⋮          │    ⋮    │    ⋮    │    ⋮    │    ⋮    │    ⋮     │     ⋮     │
│ 2020-05-27T07:00:00 │   110.5 │ 126.904 │  110.06 │ 118.771 │  118.771 │  7.7212e7 │
│ 2020-05-28T07:00:00 │ 109.814 │ 114.035 │ 104.049 │ 109.471 │  109.471 │ 1.33343e8 │
│ 2020-05-29T07:00:00 │ 103.294 │ 103.946 │ 93.2044 │ 93.2044 │  93.2044 │ 1.60135e8 │
└─────────────────────┴─────────┴─────────┴─────────┴─────────┴──────────┴───────────┘
                                                                       96 rows omitted
```

## Sink to TSFrame  
EURO-USD (EURUSD=X) daily price since start of data  

```julia
using TSFrames
tsf = get_prices(TSFrame,"EURUSD=X",startdt=Date(1900,1,1),enddt=today())
```  

```julia
5399×7 TSFrame with DateTime Index
 Index                open     high     low      close    adjclose  vol      ticker   
 DateTime             Float64  Float64  Float64  Float64  Float64   Float64  String
──────────────────────────────────────────────────────────────────────────────────────
 2003-12-01T00:00:00  1.2034   1.20401  1.1944   1.1965    1.1965       0.0  EURUSD=X
 2003-12-02T00:00:00  1.1961   1.2109   1.1946   1.2089    1.2089       0.0  EURUSD=X
 2003-12-03T00:00:00  1.209    1.213    1.2077   1.2123    1.2123       0.0  EURUSD=X
 2003-12-04T00:00:00  1.212    1.2144   1.2044   1.20809   1.20809      0.0  EURUSD=X
          ⋮              ⋮        ⋮        ⋮        ⋮        ⋮         ⋮        ⋮
 2024-08-05T23:00:00  1.0951   1.09631  1.09046  1.0951    1.0951       0.0  EURUSD=X
 2024-08-06T23:00:00  1.09262  1.09364  1.09069  1.09262   1.09262      0.0  EURUSD=X
 2024-08-08T12:41:04  1.09266  1.09481  1.09039  1.09039   1.09039      0.0  EURUSD=X
                                                                     5392 rows omitted
```

### Plot this:
```julia
using Plots
plot(tsf[:,[:Index,:adjclose]])
```  
![EURUSD](docs/src/assets/snp500.svg)

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://eohne.github.io/YFinance.jl/stable/

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://eohne.github.io/YFinance.jl/dev/

## Other Data:

### ESG
```julia
get_ESG("NFLX")["score"] |> DataFrame |> dropmissing
```
```julia
79×6 DataFrame
 Row │ symbol  timestamp            esgScore  governanceScore  environmentScore  socialScore 
     │ String  DateTime             Real      Real             Real              Real
─────┼───────────────────────────────────────────────────────────────────────────────────────
   1 │ NFLX    2014-09-01T00:00:00     43               57                37           39
   2 │ NFLX    2014-10-01T00:00:00     43               57                37           39
   3 │ NFLX    2014-11-01T00:00:00     43               57                37           39
   4 │ NFLX    2014-12-01T00:00:00     43               57                37           39
  ⋮  │   ⋮              ⋮              ⋮             ⋮                ⋮               ⋮
  77 │ NFLX    2022-05-01T00:00:00     15.78             8.87              0.09         6.83
  78 │ NFLX    2022-08-01T00:00:00     16.25             9.34              0.09         6.83
  79 │ NFLX    2023-09-01T00:00:00     16.41             9.01              0.09         7.31
                                                                              72 rows omitted
```

### Get Valuations of NFLX
```julia
get_Fundamental("NFLX", "valuation","annual",today()-Year(3) , today()) |> DataFrame
```  

```julia
3×10 DataFrame
 Row │ timestamp            PegRatio  ForwardPeRatio  MarketCap     PeRatio  EnterprisesValueRevenueRatio  PbRatio  EnterprisesValueEBITDARatio  PsRatio  EnterpriseValue 
     │ DateTime             Any       Any             Any           Any      Any                           Any      Any                          Any      Any
─────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2021-12-31T00:00:00  1.4751    46.5116         267461134181  54.3228  9.6192                        17.4644  14.914                       9.57841  275427617181
   2 │ 2022-12-31T00:00:00  2.1982    27.027          131227643270  26.3993  4.4166                        6.39726  6.7377                       4.238    139002027270
   3 │ 2023-12-31T00:00:00  1.951     30.6748         213097477242  48.5908  6.7047                        9.53074  10.686                       6.71235  219530399242
```

### Get Income Statement:
```julia
is=get_Fundamental("AMD", "income_statement","annual",today()-Year(1) , today()) |> DataFrame 
stack(is, Not(:timestamp))
```  
```julia
49×3 DataFrame
 Row │ timestamp            variable                           value       
     │ DateTime             String                             Any
─────┼─────────────────────────────────────────────────────────────────────
   1 │ 2023-12-31T00:00:00  InterestExpenseNonOperating        106000000
   2 │ 2023-12-31T00:00:00  CostOfRevenue                      12220000000
   3 │ 2023-12-31T00:00:00  TotalRevenue                       22680000000
   4 │ 2023-12-31T00:00:00  EarningsFromEquityInterestNetOfT…  16000000
  ⋮  │          ⋮                           ⋮                       ⋮
  47 │ 2023-12-31T00:00:00  NormalizedIncome                   854000000
  48 │ 2023-12-31T00:00:00  EBIT                               598000000
  49 │ 2023-12-31T00:00:00  TotalUnusualItems                  0
                                                            42 rows omitted
```

### Options

```julia
op = get_Options("AMD")
```  
```julia
OrderedCollections.OrderedDict{String, OrderedCollections.OrderedDict{String, Vector{Any}}} with 2 entries:
  "calls" => OrderedDict("contractSymbol"=>["AMD240809C00075000", "AMD240809C00080000", "AMD240809C00085000", "AMD240809C0…
  "puts"  => OrderedDict("contractSymbol"=>["AMD240809P00075000", "AMD240809P00080000", "AMD240809P00085000", "AMD240809P0…
```

```julia
DataFrame(op["calls"])
```
```julia
65×16 DataFrame
 Row │ contractSymbol      strike  currency  lastPrice  change  percentChange  volume  openInterest  bid  ask  contractSi ⋯
     │ Any                 Any     Any       Any        Any     Any            Any     Any           Any  Any  Any        ⋯
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ AMD240809C00075000  75      USD       59.65      0       0              1       26            0    0    REGULAR    ⋯
   2 │ AMD240809C00080000  80      USD       52.61      0       0              1       11            0    0    REGULAR     
   3 │ AMD240809C00085000  85      USD       49.69      0       0              2       0             0    0    REGULAR     
   4 │ AMD240809C00090000  90      USD       44.54      0       0              3       12            0    0    REGULAR     
  ⋮  │         ⋮             ⋮        ⋮          ⋮        ⋮           ⋮          ⋮          ⋮         ⋮    ⋮        ⋮     ⋱
  63 │ AMD240809C00285000  285     USD       0.01       0       0              15      16            0    0    REGULAR    ⋯
  64 │ AMD240809C00290000  290     USD       0.08       0       0              7       10            0    0    REGULAR     
  65 │ AMD240809C00295000  295     USD       0.01       0       0              1       19            0    0    REGULAR     
                                                                                              6 columns and 58 rows omitted
```
## \*\*\* This is only a small subset of functions and data items for a full set please see the documentation. \*\*\*