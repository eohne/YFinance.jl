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

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://eohne.github.io/YFinance.jl/stable/

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://eohne.github.io/YFinance.jl/dev/

