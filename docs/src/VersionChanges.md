!!! info "v1.0.2"
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
