const _BASE_URL_ = "https://query2.finance.yahoo.com";

"""
    get_prices(symbol::AbstractString; range::AbstractString="1mo", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false)

Retrievs prices from Yahoo Finance.

## Arguments

 * `Smybol` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)

You can either provide a `range` or a `startdt` and an `enddt`.
 * `range` takes the following values: "1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"

 * `startdt` and `enddt` take the following types: `::Date`,`::DateTime`, or a `String` of the following form `yyyy-mm-dd`

 * `prepost` is a boolean indicating whether pre and post periods should be included. Defaults to `false`

 * `autoadjust` defaults to `true`. It adjusts open, high, low, close prices, and volume by multiplying by the ratio between the close and the adjusted close prices - only available for intervals of 1d and up. 

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty dictionary is returned.

 * exchange_local_time`::Bool` defaults to `false`. If set to true the timestamp corresponds to the exchange local time else to GMT.

# Examples
```julia-repl
julia> get_prices("AAPL",range="1d",interval="90m")
Dict{String, Any} with 7 entries:
"vol"    => [10452686, 0]
"ticker" => "AAPL"
"high"   => [142.55, 142.045]
"open"   => [142.34, 142.045]
"timestamp"     => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:08:33")]
"low"    => [140.9, 142.045]
"close"  => [142.28, 142.045]
```
## Can be easily converted to a DataFrame
```julia-repl
julia> using DataFrames
julia> get_prices("AAPL",range="1d",interval="90m") |> DataFrame
2×7 DataFrame
Row │ close    timestamp            high     low      open     ticker  vol      
    │ Float64  DateTime             Float64  Float64  Float64  String  Int64    
────┼───────────────────────────────────────────────────────────────────────────
  1 │  142.28  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    10452686
  2 │  142.19  2022-12-09T15:08:03   142.19   142.19   142.19  AAPL           0
```

## Broadcasting
```julia-repl
julia> get_prices.(["AAPL","NFLX"],range="1d",interval="90m")
2-element Vector{Dict{String, Any}}:
Dict(
    "vol" => [11085386, 0], 
    "ticker" => "AAPL", 
    "high" => [142.5500030517578, 142.2949981689453], 
    "open" => [142.33999633789062, 142.2949981689453], 
    "timestamp" => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:15:34")], 
    "low" => [140.89999389648438, 142.2949981689453], 
    "close" => [142.27000427246094, 142.2949981689453])
Dict(
    "vol" => [4435651, 0], 
    "ticker" => "NFLX", 
    "high" => [326.29998779296875, 325.30999755859375], 
    "open" => [321.45001220703125, 325.30999755859375], 
    "timestamp" => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:15:35")], 
    "low" => [319.5199890136719, 325.30999755859375], 
    "close" => [325.79998779296875, 325.30999755859375])
```

## Converting it to a DataFrame:
```julia-repl
julia> using DataFrames
julia> data = get_prices.(["AAPL","NFLX"],range="1d",interval="90m");
julia> vcat([DataFrame(i) for i in data]...)
4×7 DataFrame
Row │ close    timestamp            high     low      open     ticker  vol      
    │ Float64  DateTime             Float64  Float64  Float64  String  Int64    
────┼───────────────────────────────────────────────────────────────────────────
  1 │  142.21  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    11111223
  2 │  142.16  2022-12-09T15:12:20   142.16   142.16   142.16  AAPL           0
  3 │  324.51  2022-12-09T14:30:00   326.3    319.52   321.45  NFLX     4407336
  4 │  324.65  2022-12-09T15:12:20   324.65   324.65   324.65  NFLX           0
```
"""
function get_prices(symbol::AbstractString; range::AbstractString="5d", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false,exchange_local_time=false)
    validranges = ["1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"]
    validintervals = ["1m","2m","5m","15m","30m","60m","90m","1h","1d","5d","1wk","1mo","3mo"]
    @assert in(range,validranges) "The chosen range is not supported choose one from:\n 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max"
    @assert in(interval,validintervals) "The chosen interval is not supported choose one from:\n 1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo"


    # Check if symbol is valid
    old_symbol = symbol
    symbol = get_valid_symbols(symbol)
    if isempty(symbol)
        if throw_error
            error("$old_symbol is not a valid Symbol!")
        else
            @warn "$old_symbol is not a valid Symbol an empy Dictionary was returned!" 
            return Dict()
        end
    else
        symbol = symbol[1]
    end
    

    if !isequal(startdt,"") || !isequal(enddt,"")
        range = ""
        if typeof(startdt) <: Date
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(startdt))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(enddt))))
        elseif typeof(startdt) <:DateTime
            startdt = Int(round(Dates.datetime2unix(startdt)))
            enddt = Int(round(Dates.datetime2unix(enddt)))
        elseif typeof(startdt) <: AbstractString
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(startdt,Dates.DateFormat("yyyy-mm-dd"))))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(enddt,Dates.DateFormat("yyyy-mm-dd"))))))
        else
            error("Startdt and Enddt must be either a Date, a DateTime, or a string of the following format yyyy-mm-dd!")
        end
    end

    #Check if minute data and longer than 7 days! This allows to in the future if this is the case loop over calls to get 1month of data.
    if isequal(interval,"1m") & in(range, ["1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"])
        error("The range for 1m interval data needs to be lower than 1 week.")
    end
    if !isequal(startdt,"") && isequal(interval,"1m") & (Date(unix2datetime(enddt)) - Date(unix2datetime(startdt)) > Day(7))
        error("The range for 1m interval data needs to be less than or equal to 7 days.")
    end


    parameters = Dict(
        "period1"=>startdt,
        "period2"=>enddt,
        "range"=>range,
        "interval"=>interval,
        "includePrePost"=>prepost,
        "events" => "div,splits"
    )
    url = "$(_BASE_URL_)/v8/finance/chart/$(uppercase(symbol))"
    res = HTTP.get(url,query=parameters,readtimeout = timeout)
    res = JSON3.read(res.body).chart.result[1]

    #check for duplicate values at the end (common error by yahoo)
    if length(res.timestamp) - length(unique(res.timestamp)) ==1
        idx = 1:(length(res.timestamp)-1)
    else
        idx = 1:length(res.timestamp)
    end

    #Exchange time offset:
    if exchange_local_time
        time_offset = res.meta.gmtoffset
    else
        time_offset = 0
    end

    # if interval in ["1m","2m","5m","15m","30m","60m","90m"] there is no adjusted close!
    if in(interval, ["1m","2m","5m","15m","30m","60m","90m"])
        d =     Dict(
                "ticker" => symbol,
                "timestamp" => Dates.unix2datetime.(res.timestamp[idx] .+ time_offset),
                "open" => res.indicators.quote[1].open[idx],
                "high" => res.indicators.quote[1].high[idx],
                "low"  => res.indicators.quote[1].low[idx],
                "close" => res.indicators.quote[1].close[idx],
                "vol" => res.indicators.quote[1].volume[idx]) 
    else   
        d =     Dict(
            "ticker" => symbol,
            "timestamp" => Dates.unix2datetime.(res.timestamp[idx].+ time_offset) ,
            "open" => res.indicators.quote[1].open[idx],
            "high" => res.indicators.quote[1].high[idx],
            "low"  => res.indicators.quote[1].low[idx],
            "close" => res.indicators.quote[1].close[idx],
            "adjclose" => res.indicators.adjclose[1].adjclose[idx],
            "vol" => res.indicators.quote[1].volume[idx]) 
        if autoadjust
            ratio = d["adjclose"] ./ d["close"]
            d["open"] = d["open"] .* ratio
            d["high"] = d["high"] .* ratio
            d["low"] = d["low"] .* ratio
            d["vol"] = d["vol"] .* ratio
        end
    end
    return d
end