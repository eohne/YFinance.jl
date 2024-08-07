module YFinance_TimeSeries

using TimeSeries, YFiance


"""
    sink_prices_to(::Type{TimeArray},x::OrderedDict{String,Any})

Converts an exisitng OrderedDict output from get_prices to a TSFrame
"""
function YFinance.sink_prices_to(::Type{TimeArray},x::OrderedDict{String,Any})
    ks = [keys(x)...][2:end] # only get the keys that are not ticker
    nt = NamedTuple( Symbol(k) => x[k] for k in ks) # convert the dictionary to a named tuple
    ta = TimeArray(nt, timestamp = :timestamp,meta = x["ticker"]) # create the timeseries array
    return ta
end


"""
    get_prices(::Type{TimeArray},symbol::AbstractString; range::AbstractString="1mo", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false,exchange_local_time=false,divsplits=false)

Retrievs prices from Yahoo Finance and stores them in a TimeArray

## Arguments

 * ::Type{TSFrame} 

 * `Smybol` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)

You can either provide a `range` or a `startdt` and an `enddt`.
 * `range` takes the following values: "1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max". Note: when range is selected rather than `startdt` or `enddt` the specified interval may not be observed by Yahoo! Therefore, it is recommended to use `startdt` and `enddt` instead. To get max simply set `startdt = "1900-01-01"`

 * `startdt` and `enddt` take the following types: `::Date`,`::DateTime`, or a `String` of the following form `yyyy-mm-dd`

 * `prepost` is a boolean indicating whether pre and post periods should be included. Defaults to `false`

 * `autoadjust` defaults to `true`. It adjusts open, high, low, close prices, and volume by multiplying by the ratio between the close and the adjusted close prices - only available for intervals of 1d and up. 

 *  `throw_error::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty `OrderedCollections.OrderedDict` is returned.

 * `exchange_local _time::Bool` defaults to `false`. If set to true the timestamp corresponds to the exchange local time else to GMT.

 * `divsplits::Bool` defaults to `false`. If set to true dividends and stock split data is also returned. Split data contains the numerator, denominator, and split ratio. The interval needs to be set to "1d" for this to work.
```
"""
function YFinance.get_prices(::Type{TSFrame},symbol::AbstractString; range::AbstractString="5d", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false,exchange_local_time=false,divsplits=false)
    x = YFinance.get_prices(symbol; range=range, interval=interval,startdt=startdt, enddt=enddt,prepost=prepost,autoadjust=autoadjust,timeout = timeout,throw_error=throw_error,exchange_local_time=exchange_local_time,divsplits=divsplits)
    return YFinance.sink_prices_to(TimeArray,x)
end

end