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

## \*\*\* No decryption issues \*\*\*
The implementation of `YFinance.jl` is similar to the python package `yahooquery` in that it accesses data through API endpoints. Therefore, **`YFinance.jl` does not experience the same decryption issues** that python’s `yfinance` faces at the moment.

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
] add YFinance 
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

## Precompilation across different versions

### Version 0.1.10 
Precompiles only the response processing part of the `get_prices` function and not the HTTP request. Most of the compilation time lies unfortunately with the request itself.  
To Install this version enter the package mode by entering `]` in the REPL and run the following command:
```julia
  (@v1.10) pkg> add YFinance
```

### Version 0.1.9 
Does not precompile.  
To Install this version enter the package mode by entering `]` in the REPL and run the following command:
```julia
  (@v1.10) pkg> add YFinance @v0.1.9
```

### Version 0.1.8 
Precompilation of the `get_prices` function. This has caused precompilation hangs for Julia 1.10 and 1.11 - package typically still precompiles but takes long and gives warnings. One user at least has reported errors. Note precompilation also does not work if you require to set a proxy to access the internet. 

To Install this version enter the package mode by entering `]` in the REPL and run the following command:
```julia
(@v1.10) pkg> add YFinance @v0.1.8
```