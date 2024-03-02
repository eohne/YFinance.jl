const _BASE_URL_ = "https://query2.finance.yahoo.com";

function _clean_prices_nothing(x::AbstractArray{<:Any})
    res = Array{Float64}(undef, size(x,1))
    for i in eachindex(x)
        if isnothing.(view(x,i))
            res[i] = NaN
        elseif isinteger.(view(x,i))
            res[i]= Float64(x[i]) 
        else
            res[i] = x[i]
        end
    end
    return res #convert.(Float64, res)
end
function _clean_prices_nothing(x::AbstractArray{Float64})
    return x
end

"""
    get_prices(symbol::AbstractString; range::AbstractString="1mo", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false,exchange_local_time=false)

Retrievs prices from Yahoo Finance.

## Arguments

 * `Smybol` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)

You can either provide a `range` or a `startdt` and an `enddt`.
 * `range` takes the following values: "1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max". Note: when range is selected rather than `startdt` or `enddt` the specified interval may not be observed by Yahoo! Therefore, it is recommended to use `startdt` and `enddt` instead. To get max simply set `startdt = "1900-01-01"`

 * `startdt` and `enddt` take the following types: `::Date`,`::DateTime`, or a `String` of the following form `yyyy-mm-dd`

 * `prepost` is a boolean indicating whether pre and post periods should be included. Defaults to `false`

 * `autoadjust` defaults to `true`. It adjusts open, high, low, close prices, and volume by multiplying by the ratio between the close and the adjusted close prices - only available for intervals of 1d and up. 

 *  `throw_error::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty `OrderedCollections.OrderedDict` is returned.

 * `exchange_local _time::Bool` defaults to `false`. If set to true the timestamp corresponds to the exchange local time else to GMT.

# Examples
```julia-repl
julia> get_prices("AAPL",range="1d",interval="90m")
OrderedDict{String, Any} with 7 entries:
  "ticker"    => "AAPL"
  "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")]   
  "open"      => [127.99, 129.96, 129.992, 130.035, 129.95, 129.61]
  "high"      => [129.98, 130.481, 130.098, 130.24, 130.22, 129.61]
  "low"       => [127.73, 129.44, 129.325, 129.7, 129.56, 129.61]
  "close"     => [129.954, 129.998, 130.035, 129.95, 129.6, 129.61]
  "vol"       => [29101646, 14058713, 9897737, 9552323, 6308537, 0]
```
## Can be easily converted to a DataFrame
```julia-repl
julia> using DataFrames
julia> get_prices("AAPL",range="1d",interval="90m") |> DataFrame
6×7 DataFrame
 Row │ ticker  timestamp            open     high     low      close    vol      
     │ String  DateTime             Float64  Float64  Float64  Float64  Int64    
─────┼───────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2022-12-29T14:30:00  127.99   129.98   127.73   129.954  29101646 
   2 │ AAPL    2022-12-29T16:00:00  129.96   130.481  129.44   129.998  14058713 
   3 │ AAPL    2022-12-29T17:30:00  129.992  130.098  129.325  130.035   9897737 
   4 │ AAPL    2022-12-29T19:00:00  130.035  130.24   129.7    129.95    9552323 
   5 │ AAPL    2022-12-29T20:30:00  129.95   130.22   129.56   129.6     6308537 
   6 │ AAPL    2022-12-29T21:00:00  129.61   129.61   129.61   129.61          0 
```

## Broadcasting
```julia-repl
julia> get_prices.(["AAPL","NFLX"],range="1d",interval="90m")
OrderedDict("ticker" => "AAPL",
    "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")], 
    "open" => [127.98999786376953, 129.9600067138672, 129.99240112304688, 130.03500366210938, 129.9499969482422, 129.61000061035156], 
    "high" => [129.97999572753906, 130.4813995361328, 130.09829711914062, 130.24000549316406, 130.22000122070312, 129.61000061035156], 
    "low" => [127.7300033569336, 129.44000244140625, 129.3249969482422, 129.6999969482422, 129.55999755859375, 129.61000061035156], 
    "close" => [129.95419311523438, 129.99830627441406, 130.03500366210938, 129.9499969482422, 129.60000610351562, 129.61000061035156], 
    "vol" => [29101646, 14058713, 9897737, 9552323, 6308537, 0])
OrderedDict("ticker" => "NFLX",
    "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")],
    "open" => [283.17999267578125, 289.5199890136719, 293.4200134277344, 290.05499267578125, 290.760009765625, 291.1199951171875],
    "high" => [291.8699951171875, 295.4999084472656, 293.5, 291.32000732421875, 292.3299865722656, 291.1199951171875],
    "low" => [281.010009765625, 289.489990234375, 289.5400085449219, 288.7699890136719, 290.5400085449219, 291.1199951171875],
    "close" => [289.5199890136719, 293.46990966796875, 290.04998779296875, 290.82000732421875, 291.1199951171875, 291.1199951171875],
    "vol" => [2950791, 2458057, 1362915, 1212217, 1121821, 0]) 
```

## Converting it to a DataFrame:
```julia-repl
julia> using DataFrames
julia> data = get_prices.(["AAPL","NFLX"],range="1d",interval="90m");
julia> vcat([DataFrame(i) for i in data]...)
12×7 DataFrame
 Row │ ticker  timestamp            open     high     low      close    vol      
     │ String  DateTime             Float64  Float64  Float64  Float64  Int64    
─────┼───────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2022-12-29T14:30:00  127.99   129.98   127.73   129.954  29101646
   2 │ AAPL    2022-12-29T16:00:00  129.96   130.481  129.44   129.998  14058713
   3 │ AAPL    2022-12-29T17:30:00  129.992  130.098  129.325  130.035   9897737
   4 │ AAPL    2022-12-29T19:00:00  130.035  130.24   129.7    129.95    9552323
   5 │ AAPL    2022-12-29T20:30:00  129.95   130.22   129.56   129.6     6308537
   6 │ AAPL    2022-12-29T21:00:00  129.61   129.61   129.61   129.61          0
   7 │ NFLX    2022-12-29T14:30:00  283.18   291.87   281.01   289.52    2950791
   8 │ NFLX    2022-12-29T16:00:00  289.52   295.5    289.49   293.47    2458057
   9 │ NFLX    2022-12-29T17:30:00  293.42   293.5    289.54   290.05    1362915
  10 │ NFLX    2022-12-29T19:00:00  290.055  291.32   288.77   290.82    1212217
  11 │ NFLX    2022-12-29T20:30:00  290.76   292.33   290.54   291.12    1121821
  12 │ NFLX    2022-12-29T21:00:00  291.12   291.12   291.12   291.12          0
```
"""
function get_prices(symbol::AbstractString; range::AbstractString="5d", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10,throw_error=false,exchange_local_time=false)
    validranges = ["1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"]
    validintervals = ["1m","2m","5m","15m","30m","60m","90m","1h","1d","5d","1wk","1mo","3mo"]
    @assert in(range,validranges) "The chosen range is not supported choose one from:\n 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max"
    @assert in(interval,validintervals) "The chosen interval is not supported choose one from:\n 1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo"



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

    res = try
        HTTP.get(url,query=parameters,readtimeout = timeout, proxy=_PROXY_SETTINGS[:proxy],headers=_PROXY_SETTINGS[:auth])
    catch e 
        e
    end #end try
    if isequal(res.status,404)
        if throw_error
            error("$symbol is not a valid Symbol! $(JSON3.read(res.response.body).chart.error.description)")
        else
            @warn "$symbol is not a valid Symbol. $(JSON3.read(res.response.body).chart.error.description). An empy OrderedCollections.OrderedDict was returned!" 
            return OrderedCollections.OrderedDict()
        end
        elseif isequal(res.status, 400)
            if throw_error
                error("$(JSON3.read(res.response.body).finance.error.description).")
            else
                @warn "$(JSON3.read(res.response.body).finance.error.description). An empy OrderedCollections.OrderedDict was returned!" 
                return OrderedCollections.OrderedDict()
            end 
    end

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
        d =     OrderedCollections.OrderedDict(
                "ticker" => symbol,
                "timestamp" => Dates.unix2datetime.(res.timestamp[idx] .+ time_offset),
                "open" => res.indicators.quote[1].open[idx] |> _clean_prices_nothing,
                "high" => res.indicators.quote[1].high[idx] |> _clean_prices_nothing,
                "low"  => res.indicators.quote[1].low[idx] |> _clean_prices_nothing,
                "close" => res.indicators.quote[1].close[idx] |> _clean_prices_nothing,
                "vol" => res.indicators.quote[1].volume[idx] |> _clean_prices_nothing) 
    else   
        d =     OrderedCollections.OrderedDict(
            "ticker" => symbol,
            "timestamp" => Dates.unix2datetime.(res.timestamp[idx].+ time_offset) ,
            "open" => res.indicators.quote[1].open[idx] |> _clean_prices_nothing,
            "high" => res.indicators.quote[1].high[idx] |> _clean_prices_nothing,
            "low"  => res.indicators.quote[1].low[idx] |> _clean_prices_nothing,
            "close" => res.indicators.quote[1].close[idx] |> _clean_prices_nothing,
            "adjclose" => res.indicators.adjclose[1].adjclose[idx] |> _clean_prices_nothing,
            "vol" => res.indicators.quote[1].volume[idx] |> _clean_prices_nothing) 
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