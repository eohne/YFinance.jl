module YFinance_TSFrames

using TSFrames, OrderedCollections, YFinance, Dates

"""
    sink_prices_to(::Type{TSFrame}, x::OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}})

Converts an existing OrderedDict output from get_prices to a TSFrame
"""
function YFinance.sink_prices_to(::Type{TSFrame}, x::OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}})
    y = copy(x)
    symbol = x["ticker"]
    delete!(y, "ticker")
    tick = OrderedDict("ticker" => fill(symbol, length(x["timestamp"])))
    return TSFrame(merge(y, tick))
end

"""
    get_prices(::Type{TSFrame}, symbol::String; kwargs...)

Retrieves prices from Yahoo Finance and stores them in a TSFrame

## Arguments

 * `::Type{TSFrame}`: Specifies that the output should be a TSFrame

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

A TSFrame containing the requested price data
"""
function YFinance.get_prices(::Type{TSFrame}, symbol::String; kwargs...)
    x = YFinance.get_prices(symbol; kwargs...)
    return YFinance.sink_prices_to(TSFrame, x)
end

end # module