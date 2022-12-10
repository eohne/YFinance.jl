# YFinance.jl
*Download price, fundamental, and option data from Yahoo Finance*  
This is a side project and my first package so do not expect too much. 
## \*\*\* LEGAL DISCLAIMER \*\*\*
**Yahoo!, Y!Finance, and Yahoo! finance are registered trademarks of
Yahoo, Inc.**

YFinance.jl is not affiliated with Yahoo, Inc. in any way. The data retreived can only be used for personal use. 
Please see Yahoo's terms of use:
 - [Here](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm)
 - [Here](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html)
 - [Here](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)

## What you can download
- Price data (including intraday)
- Fundamental data
- Option Data
- ESG Data
- quoteSummary data (this is a JSON3.object that contains a multitude of different information)

## Function Documentation
````@docs
get_prices

get_quoteSummary

get_Fundamental

get_Options

get_ESG
````