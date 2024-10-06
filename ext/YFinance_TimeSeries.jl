module YFinance_TimeSeries

using TimeSeries, OrderedCollections, YFinance

"""
    sink_prices_to(::Type{TimeArray}, x::OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}})

Converts an existing OrderedDict output from get_prices to a TimeArray
"""
function YFinance.sink_prices_to(::Type{TimeArray}, x::OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}})
    ks = setdiff(keys(x), ["ticker"])  # get all keys except "ticker"
    nt = NamedTuple(Symbol(k) => x[k] for k in ks)  # convert the dictionary to a named tuple
    ta = TimeArray(nt, timestamp = :timestamp, meta = x["ticker"])  # create the TimeArray
    return ta
end

"""
    get_prices(::Type{TimeArray}, symbol::String; kwargs...)

Retrieves prices from Yahoo Finance and stores them in a TimeArray

## Arguments

 * `::Type{TimeArray}`: Specifies that the output should be a TimeArray

 * `symbol`: A ticker (e.g., AAPL for Apple Inc., or ^GSPC for the S&P 500)

 * `kwargs...`: Additional keyword arguments passed to YFinance.get_prices

    These can include:
    - `range`: A string specifying the time range (e.g., "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max")
    - `interval`: The data interval (e.g., "1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo")
    - `startdt` and `enddt`: Start and end dates (Date, DateTime, or String in "yyyy-mm-dd" format)
    - `prepost`: Boolean for including pre and post market data
    - `autoadjust`: Boolean for adjusting prices
    - `timeout`: HTTP request timeout in seconds
    - `throw_error`: Boolean for error handling behavior
    - `exchange_local_time`: Boolean for timestamp localization
    - `divsplits`: Boolean for including dividends and stock split data
    - `wait`: Float for specifying wait time between API calls

For detailed information on these parameters, refer to the YFinance.get_prices documentation.

## Returns

A TimeArray containing the requested price data
"""
function YFinance.get_prices(::Type{TimeArray}, symbol::String; kwargs...)
    x = YFinance.get_prices(symbol; kwargs...)
    return YFinance.sink_prices_to(TimeArray, x)
end

end # module