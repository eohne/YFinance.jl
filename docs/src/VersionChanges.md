!!! info "v0.1.10"
    ## Improvements
    * `get_prices` now supports retrieving minute data for periods longer than 7 days by sending multiple requests of length equal to 7 days and stitching the responses together (minute data still needs to be within the last 30 days - this is a limit set by Yahoo)
    * `get_prices` now allows `startdt` and `enddt` to be of different types (e.g., `startdt="2024-01-01", enddt=today()` is now valid)
    * The `range` argument in `get_prices` has been reworked to convert to `startdt` and `enddt`. Previously, this parameter was simply passed to the Yahoo API. The new way prings multiple improvements:
      - more flexible range inputs
      - specified intervals are now observed
    * Significant code refactoring for improved maintainability and readability of the `get_prices` function
    * An `OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}` is now returned by get_prices rather than `OrderedDict{String,Any}`
    * Added precompilation for the response processing part of the `get_prices` function only


!!! info "v0.1.9"
    ## Bug Fix
    * Getting rid of precompilation. Precompilation hangs and also doesn't work if a proxy is required ([#23](https://github.com/eohne/YFinance.jl/issues/23))


!!! info "v0.1.8"
    ## Bug Fix
    * `get_prices` fixes indexing error when divsplits=true ([#22](https://github.com/eohne/YFinance.jl/issues/22))

!!! info "v0.1.7"
    ## Bug Fix
    * `get_prices`, `get_splits`, `get_dividends` now error more nicely when there is no data for the selected date range. ([#19](https://github.com/eohne/YFinance.jl/issues/19))

!!! info "v0.1.6"
    ## Improvements
    * `get_prices` can now return dividends and splits ([#11](https://github.com/eohne/YFinance.jl/issues/11), [#18](https://github.com/eohne/YFinance.jl/issues/18))
    * `get_prices` can now directly return TimeArrays (TimeSeries.jl) and TSFrame (TSFrames.jl). Julia 1.9 is required and the respective packages need to be loaded
    * added some precompilation for `get_prices` (this will require a valid internet connection when the package is loaded first/installed)

    ## New Functionality
    * `get_splits` returns stock split information
    * `get_dividends` returns dividend information
    * `sink_prices_to` allows for easy conversion to TimeArrays (TimeSeries.jl) and TSFrame (TSFrames.jl). Julia 1.9 is required and the respective packages need to be loaded

!!! info "v0.1.5"
    ## Bug Fix
    * Implemented Cookies and Crumbs to fix get_quoteSummary() and all functions depending on it ([#14](https://github.com/eohne/YFinance.jl/issues/14)) 
    

!!! info "v0.1.4"
    ## Bug Fix
    * get_prices now returns dictionaries containing price vectors of type Array{Float64} rather than Array{ Union{Nothing,Float64}} ([#7](https://github.com/eohne/YFinance.jl/issues/7)) 
    
    ## Improvements
    * get_prices now runs faster than before.

    ## New Functionality
    * `get_symbols` allows the user to search for yahoo finance symbols from (partial) company/security names
    * `get_all_symbols` exposes all tickers from the NASDAQ, AMEX, and NYSE exchanges ([#8](https://github.com/eohne/YFinance.jl/issues/8))
    * `search_news` now allows for news searches

    ## Docs
    * Added documentation for the new functionality
    * Added a clarification statement in the Readme.md and Docs that YFinance uses API endpoints to access data and does not suffer from decryption issues ([#6](https://github.com/eohne/YFinance.jl/issues/6))


!!! info "v0.1.3"
    ## Bug Fix
    * get_prices would error when `autoadjust=true` for some tickers when Yahoo returns nothing for some observations in the price time series. The update now does not error in this cases and returns `NaN` for the missing datapoints. `NaN` is used instead of `Missing` because of performance improvements and the ability to integrate `YFinance.jl` with `TimeSeries.jl`. ([#5](https://github.com/eohne/YFinance.jl/issues/5)) 
       - Thank you [RaSi96](https://github.com/RaSi96) for reporting this bug and helping me sort it out!

    ## Docs
    * Improved documentation for get_prices ([#5](https://github.com/eohne/YFinance.jl/issues/5))
       - When the `range` keyword is used instead of `startdt` and `enddt` the specified interval is not observed by Yahoo at longer ranges. To enforce the specified `interval` use `startdt` and `enddt` instead. 
       - Data points that yahoo returns as `nothing` are returned as `NaN`. It seems like Yahoo thinks it should have price information for these timestamps but does not have them and thus returns `nothing`.

    ## Other
    * Added a test case for the stock "ADANIENT.NS". The time series of the stock prices contains the `nothing` values mentioned in the `Bug Fix`. ([#5](https://github.com/eohne/YFinance.jl/issues/5))


!!! info "v0.1.2"
    ## Changes
    * Return `OrderedDict` from `OrderedCollections.jl` instead of `Dict`
      - Should be non breaking as all functions that work for `Base.Dict` also work for `OrderedCollections.OrderedDict`
    * Allow the setting of HTTP proxies (through `HTTP.jl`). Also allows for secured HTTP proxies with a username and password
      - Default is no proxy so change is non breaking
      
    ## Fixes:
    * `get_Fundamentals()` does now return a timestamp

    ## Docs
    * Added Documentation for the proxy settings
    * Added an Example Section:
      - Some quick code to convert Price data to a `DataFrame`, `TimeSeries.TimeArray`, `TSFrames.TSFrame`
      - Gave some examples of plotting some data exposed by `YFinance.jl` with `PlotlyJS.jl`
    * Added this version change log

    ## New Dependencies
    * `Base64`
      - Needed for http proxy authentication
    * `OrderedCollections.jl`
      - Provides Ordered Dictionaries. Eases workflow with data because column order is not arbitrary and changing between calls.
