# YFinance.jl
GitHub Repo: [https://github.com/eohne/YFinance.jl](https://github.com/eohne/YFinance.jl)

*Download price, fundamental, and option data from Yahoo Finance*  
This is a side project and my first package so do not expect too much. 
## \*\*\* LEGAL DISCLAIMER \*\*\*
**Yahoo!, Y!Finance, and Yahoo! finance are registered trademarks of
Yahoo, Inc.**

YFinance.jl is not endorsed or in anyway affiliated with Yahoo, Inc. The data retreived can only be used for personal use. 
Please see Yahoo's terms of use to ensure that you can use the data:
 - [Yahoo Developer API Terms of Use](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm)
 - [Yahoo Terms of Service](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html)
 - [Yahoo Terms](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)

## What you can download
- Price data (including intraday)
- Fundamental data
- Option Data
- ESG Data
- quoteSummary data (this is a JSON3.object that contains a multitude of different information)

## Installation

The package is registered in the [`General`](https://github.com/JuliaRegistries/General) registry

You can install the YFinance package by entering the package manager and typing:
```julia
] add CSV 
```
You could also install the package by first calling `using Pkg`:
```julia
using Pkg
Pkg.add("YFinance") 
```

To load the package simply type the following:
```julia
using YFinance
```