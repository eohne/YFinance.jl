const _BASE_URL_ = "https://query2.finance.yahoo.com"

# date to unix conversion
_date_to_unix(dt::Date) = Int(floor(datetime2unix(DateTime(dt))))
_date_to_unix(dt::DateTime) = Int(floor(datetime2unix(dt)))
_date_to_unix(dt::AbstractString) = _date_to_unix(Date(dt, dateformat"yyyy-mm-dd"))

function _clean_prices_nothing(x::AbstractVector)
    output = Vector{Float64}(undef, length(x))
    map!(output, x) do val
        if isnothing(val)
            return NaN
        elseif val isa Integer
            return Float64(val)
        else
            return val
        end
    end
    
    return output
end
_clean_prices_nothing(x::AbstractVector{Float64}) = x


"""
    get_prices(symbol::String; range::String="5d", interval::String="1d", startdt::Union{Date,DateTime,AbstractString}="", enddt::Union{Date,DateTime,AbstractString}="", prepost::Bool=false, autoadjust::Bool=true, timeout::Int=10, throw_error::Bool=false, exchange_local_time::Bool=false, divsplits::Bool=false, wait::Float64=0.0)

Retrieves prices from Yahoo Finance.

## Arguments

 * `symbol`: A ticker (e.g., AAPL for Apple Inc., or ^GSPC for the S&P 500)

You can either provide a `range` or both `startdt` and `enddt`.
 * `range`: A string specifying the time range. It can be one of the predefined values ("ytd", "max") or a custom range using the following suffixes:
   - "m" for minutes (e.g., "30m" for 30 minutes)
   - "d" for days (e.g., "7d" for 7 days)
   - "mo" for months (e.g., "3mo" for 3 months)
   - "y" for years (e.g., "1y" for 1 year)

 * `startdt` and `enddt`: Can be of type `Date`, `DateTime`, or a `String` in the format "yyyy-mm-dd". Both must be provided if one is specified.

 * `interval`: The data interval. Valid values are "1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo". Defaults to "1d".

 * `prepost`: Boolean indicating whether pre and post market data should be included. Defaults to `false`.

 * `autoadjust`: Defaults to `true`. Adjusts open, high, low, close prices, and volume by multiplying by the ratio between the close and the adjusted close prices - only available for intervals of 1d and up.

 * `timeout`: The timeout for the HTTP request in seconds. Defaults to 10.

 * `throw_error`: Boolean, defaults to `false`. If set to true, the function raises an error when the ticker is not valid or other issues occur. If false, a warning is given and an empty `OrderedDict` is returned.

 * `exchange_local_time`: Boolean, defaults to `false`. If set to true, the timestamp corresponds to the exchange local time; otherwise, it's in GMT.

 * `divsplits`: Boolean, defaults to `false`. If set to true, dividends and stock split data are also returned. Split data contains the numerator, denominator, and split ratio. The interval needs to be set to "1d" for this to work.

 * `wait`: Float, defaults to 0.0. Specifies the wait time in seconds between consecutive API calls when fetching minute data over extended periods.

## Notes

- For minute data requests over periods longer than 7 days, the function automatically splits the request into multiple 7-day chunks and combines the results.
- When using `startdt` and `enddt`, both must be provided.

## Returns

An `OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}` containing the requested data.

## Examples
```julia
julia> get_prices("AAPL", range="1d", interval="90m")
OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}} with 7 entries:
  "ticker"    => "AAPL"
  "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")]   
  "open"      => [127.99, 129.96, 129.992, 130.035, 129.95, 129.61]
  "high"      => [129.98, 130.481, 130.098, 130.24, 130.22, 129.61]
  "low"       => [127.73, 129.44, 129.325, 129.7, 129.56, 129.61]
  "close"     => [129.954, 129.998, 130.035, 129.95, 129.6, 129.61]
  "vol"       => [2.9101646e7, 1.4058713e7, 9.897737e6, 9.552323e6, 6.308537e6, 0.0]

## Can be easily converted to a DataFrame
julia> using DataFrames
julia> get_prices("AAPL", range="1d", interval="90m") |> DataFrame
6×7 DataFrame
 Row │ ticker  timestamp            open     high     low      close    vol       
     │ String  DateTime             Float64  Float64  Float64  Float64  Float64   
─────┼────────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2022-12-29T14:30:00  127.99   129.98   127.73   129.954  2.9101646e7
   2 │ AAPL    2022-12-29T16:00:00  129.96   130.481  129.44   129.998  1.4058713e7
   3 │ AAPL    2022-12-29T17:30:00  129.992  130.098  129.325  130.035  9.897737e6
   4 │ AAPL    2022-12-29T19:00:00  130.035  130.24   129.7    129.95   9.552323e6
   5 │ AAPL    2022-12-29T20:30:00  129.95   130.22   129.56   129.6    6.308537e6
   6 │ AAPL    2022-12-29T21:00:00  129.61   129.61   129.61   129.61   0.0

## Broadcasting
julia> get_prices.(["AAPL","NFLX"], range="1d", interval="90m")
2-element Vector{OrderedDict{String, Union{String, Vector{DateTime}, Vector{Float64}}}}:
 OrderedDict{String, Union{String, Vector{DateTime}, Vector{Float64}}} with 7 entries:
  "ticker"    => "AAPL"
  "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")]
  "open"      => [127.98999786376953, 129.9600067138672, 129.99240112304688, 130.03500366210938, 129.9499969482422, 129.61000061035156]
  "high"      => [129.97999572753906, 130.4813995361328, 130.09829711914062, 130.24000549316406, 130.22000122070312, 129.61000061035156]
  "low"       => [127.7300033569336, 129.44000244140625, 129.3249969482422, 129.6999969482422, 129.55999755859375, 129.61000061035156]
  "close"     => [129.95419311523438, 129.99830627441406, 130.03500366210938, 129.9499969482422, 129.60000610351562, 129.61000061035156]
  "vol"       => [2.9101646e7, 1.4058713e7, 9.897737e6, 9.552323e6, 6.308537e6, 0.0]
 OrderedDict{String, Union{String, Vector{DateTime}, Vector{Float64}}} with 7 entries:
  "ticker"    => "NFLX"
  "timestamp" => [DateTime("2022-12-29T14:30:00"), DateTime("2022-12-29T16:00:00"), DateTime("2022-12-29T17:30:00"), DateTime("2022-12-29T19:00:00"), DateTime("2022-12-29T20:30:00"), DateTime("2022-12-29T21:00:00")]
  "open"      => [283.17999267578125, 289.5199890136719, 293.4200134277344, 290.05499267578125, 290.760009765625, 291.1199951171875]
  "high"      => [291.8699951171875, 295.4999084472656, 293.5, 291.32000732421875, 292.3299865722656, 291.1199951171875]
  "low"       => [281.010009765625, 289.489990234375, 289.5400085449219, 288.7699890136719, 290.5400085449219, 291.1199951171875]
  "close"     => [289.5199890136719, 293.46990966796875, 290.04998779296875, 290.82000732421875, 291.1199951171875, 291.1199951171875]
  "vol"       => [2.950791e6, 2.458057e6, 1.362915e6, 1.212217e6, 1.121821e6, 0.0]

## Converting it to a DataFrame:
julia> using DataFrames
julia> data = get_prices.(["AAPL","NFLX"], range="1d", interval="90m");
julia> vcat([DataFrame(i) for i in data]...)
12×7 DataFrame
 Row │ ticker  timestamp            open     high     low      close    vol       
     │ String  DateTime             Float64  Float64  Float64  Float64  Float64   
─────┼────────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2022-12-29T14:30:00  127.99   129.98   127.73   129.954  2.9101646e7
   2 │ AAPL    2022-12-29T16:00:00  129.96   130.481  129.44   129.998  1.4058713e7
   3 │ AAPL    2022-12-29T17:30:00  129.992  130.098  129.325  130.035  9.897737e6
   4 │ AAPL    2022-12-29T19:00:00  130.035  130.24   129.7    129.95   9.552323e6
   5 │ AAPL    2022-12-29T20:30:00  129.95   130.22   129.56   129.6    6.308537e6
   6 │ AAPL    2022-12-29T21:00:00  129.61   129.61   129.61   129.61   0.0
   7 │ NFLX    2022-12-29T14:30:00  283.18   291.87   281.01   289.52   2.950791e6
   8 │ NFLX    2022-12-29T16:00:00  289.52   295.5    289.49   293.47   2.458057e6
   9 │ NFLX    2022-12-29T17:30:00  293.42   293.5    289.54   290.05   1.362915e6
  10 │ NFLX    2022-12-29T19:00:00  290.055  291.32   288.77   290.82   1.212217e6
  11 │ NFLX    2022-12-29T20:30:00  290.76   292.33   290.54   291.12   1.121821e6
  12 │ NFLX    2022-12-29T21:00:00  291.12   291.12   291.12   291.12   0.0
```
""" 
function get_prices(symbol::String, startdt::Int, enddt::Int; 
                    interval::String="1d", prepost::Bool=false, 
                    autoadjust::Bool=true, timeout::Int=10, 
                    throw_error::Bool=false, exchange_local_time::Bool=false, 
                    divsplits::Bool=false, wait::Float64=0.0)
    
    validintervals = ("1m","2m","5m","15m","30m","60m","90m","1h","1d","5d","1wk","1mo","3mo")
    @assert interval in validintervals "The chosen interval is not supported. Choose one from: $(join(validintervals, ", "))"

    # Check for minute data limitation
    if interval in ("1m","2m","5m","15m","30m","60m","90m")
        thirty_days_ago = Int(floor(datetime2unix(now() - Day(30))))
        if startdt < thirty_days_ago
            earliest_allowed_date = Date(unix2datetime(thirty_days_ago))
            error_msg = "Minute data is only available for the last 30 days. The earliest allowed start date is $earliest_allowed_date."
            if throw_error
                error(error_msg)
            else
                @warn error_msg
                return OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}()
            end
        end
        
        # Handle minute data for periods longer than 7 days
        if enddt - startdt > 7 * 86400
            return _get_minute_prices(symbol, startdt, enddt, interval; prepost=prepost, autoadjust=autoadjust, 
                                      timeout=timeout, throw_error=throw_error, exchange_local_time=exchange_local_time, 
                                      wait=wait)
        end
    end

    parameters = Dict{String,Union{String,Int,Bool}}(
        "period1" => startdt,
        "period2" => enddt,
        "interval" => interval,
        "includePrePost" => prepost,
        "events" => divsplits ? "div,splits" : ""
    )
    url = "$(_BASE_URL_)/v8/finance/chart/$(uppercase(symbol))"
    try
        res = HTTP.get(url, query=parameters, readtimeout=timeout, proxy=_PROXY_SETTINGS[:proxy], headers=_PROXY_SETTINGS[:auth])
        return _process_response(res.body, symbol, interval, autoadjust, exchange_local_time, divsplits)
    catch e
        msg = if e isa HTTP.ExceptionRequest.StatusError
            if e.status == 404
                "$symbol is not a valid Symbol."
            else
                yahoo_error = JSON3.read(e.response.body)
                if haskey(yahoo_error, :finance)
                    yahoo_error.finance.error.description
                elseif haskey(yahoo_error, :chart) && haskey(yahoo_error.chart, :error)
                    # Parse error dates if available
                    error_description = yahoo_error.chart.error.description
                    date_matches = collect(eachmatch(r"(-)?[0-9]{1,}", error_description))
                    if length(date_matches) >= 2
                        error_dates = unix2datetime.(parse.(Float64, [m.match for m in date_matches[1:2]]))
                        "Data doesn't exist for startDate = $(error_dates[1]), endDate = $(error_dates[2]) for $symbol"
                    else
                        "An unknown error occurred: $(e.status)"
                    end
                end
            end
        else
            "An error occurred: $(sprint(showerror, e))"
        end

        if throw_error
            error(msg)
        else
            @warn msg
            return OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}()
        end
    end
end



# function to deal with minute prices when more than 7 days of data is requested
function _get_minute_prices(symbol::String, startdt::Int, enddt::Int, interval::String; wait::Float64=0.0, kwargs...)
    chunk_size = 7 * 86400  # 7 days in seconds
    chunks = [(t, min(t + chunk_size - 1, enddt)) for t in startdt:chunk_size:enddt]
    
    results = OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}()
    
    for (i, (chunk_start, chunk_end)) in enumerate(chunks)
        if i > 1
            sleep(wait)  # Wait before making consecutive API calls
        end
        chunk_result = get_prices(symbol, chunk_start, chunk_end; interval=interval, kwargs...)
        if !isempty(chunk_result)
            if isempty(results)
                results = chunk_result
            else
                for (key, value) in chunk_result
                    if key != "ticker" && value isa Vector
                        append!(results[key], value)
                    end
                end
            end
        end
    end
    
    return results
end


function _process_response(response_body, symbol, interval, autoadjust, exchange_local_time, divsplits)
    res = JSON3.read(response_body).chart.result[1]
    time_offset = exchange_local_time ? res.meta.gmtoffset : 0

    haskey(res, "timestamp") ? timestamps = res.timestamp : error("No historical data for this timeperiod of $symbo")
    
    idx = length(timestamps) - length(unique(timestamps)) == 1 ? (1:length(timestamps)-1) : eachindex(timestamps)

    d = OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}(
        "ticker" => symbol,
        "timestamp" => Dates.unix2datetime.(view(timestamps, idx) .+ time_offset)
    )

    quote_data = res.indicators.quote[1]
    for field in (:open, :high, :low, :close)
        d[string(field)] = _clean_prices_nothing(getproperty(quote_data, field)[idx])
    end
    

    if !in(interval, ("1m","2m","5m","15m","30m","60m","90m"))
        d["adjclose"] = _clean_prices_nothing(res.indicators.adjclose[1].adjclose[idx])
        d["vol"] = _clean_prices_nothing(quote_data.volume[idx])
        if autoadjust
            ratio = d["adjclose"] ./ d["close"]
            for field in ("open", "high", "low", "vol")
                d[field] .*= ratio
            end
        end
    else
        d["vol"] = _clean_prices_nothing(quote_data.volume[idx])
    end

    if divsplits && interval == "1d" && haskey(res, :events)
        d["div"] = zeros(Float64, length(idx))
        d["split_numerator"] = ones(Float64, length(idx))
        d["split_denominator"] = ones(Float64, length(idx))
        
        first_timestamp = minimum(d["timestamp"])
        
        if haskey(res.events, :dividends)
            for v in values(res.events.dividends)
                div_date = unix2datetime(v.date + time_offset)
                div_date < first_timestamp && continue
                d["div"][d["timestamp"] .== div_date] .= v.amount
            end
        end
        
        if haskey(res.events, :splits)
            for v in values(res.events.splits)
                split_date = unix2datetime(v.date + time_offset)
                split_date < first_timestamp && continue
                d["split_numerator"][d["timestamp"] .== split_date] .= v.numerator
                d["split_denominator"][d["timestamp"] .== split_date] .= v.denominator
            end
        end
        
        d["split_ratio"] = d["split_numerator"] ./ d["split_denominator"]
    elseif divsplits && interval != "1d"
        @warn "Dividends and splits will not be returned. Please set the interval to 1d!"
    end

    return d
end




# Helper function to handle range-based requests
function _get_prices_by_range(symbol::String, range::String; interval::String="1d", kwargs...)
    end_unix = Int(floor(datetime2unix(now())))
    start_unix = if range == "max"
        0  # Unix start
    elseif range == "ytd"
        _date_to_unix(Date(year(today()), 1, 1))
    else
        duration = if endswith(range, "m")
            Minute(parse(Int, range[1:end-1]))
        elseif endswith(range, "d")
            Day(parse(Int, range[1:end-1]))
        elseif endswith(range, "mo")
            Month(parse(Int, range[1:end-2]))
        elseif endswith(range, "y")
            Year(parse(Int, range[1:end-1]))
        else
            error("Invalid range format. Use 'm' for minutes, 'd' for days, 'mo' for months, or 'y' for years.")
        end
        _date_to_unix(now() - duration)
    end
    return get_prices(symbol, start_unix, end_unix; interval=interval, kwargs...)
end

# Convenient Method
function get_prices(symbol::String; 
                    startdt::Union{Date,DateTime,AbstractString}="", 
                    enddt::Union{Date,DateTime,AbstractString}="", 
                    range::String="5d", 
                    interval::String="1d", 
                    kwargs...)
    if startdt == "" && enddt == ""
        return _get_prices_by_range(symbol, range; interval=interval, kwargs...)
    else
        if startdt == "" || enddt == ""
            error("Both startdt and enddt must be provided if one is specified.")
        end
        start_unix = _date_to_unix(startdt)
        end_unix = _date_to_unix(enddt)
        return get_prices(symbol, start_unix, end_unix; interval=interval, kwargs...)
    end
end

# Specialized Convenient Method
get_prices(symbol::String, startdt::T, enddt::T; kwargs...) where T <: Union{Date,DateTime,AbstractString} = 
    get_prices(symbol; startdt=startdt, enddt=enddt, kwargs...)








"""
    get_splits(symbol::String; startdt::Union{Date,DateTime,AbstractString}="", enddt::Union{Date,DateTime,AbstractString}="", timeout::Int=10, throw_error::Bool=false, exchange_local_time::Bool=false)

Retrieves stock split data from Yahoo Finance.

## Arguments

 * `symbol`: A ticker (e.g., AAPL for Apple Inc., or ^GSPC for the S&P 500)

 * `startdt` and `enddt`: Optional. Can be of type `Date`, `DateTime`, or a `String` in the format "yyyy-mm-dd". If not provided, `startdt` defaults to the earliest available data and `enddt` to the current date.

 * `timeout`: Integer, defaults to 10. The timeout for the HTTP request in seconds.

 * `throw_error`: Boolean, defaults to `false`. If set to true, the function raises an error when the ticker is not valid or other issues occur. If false, a warning is given and an empty `OrderedDict` is returned.

 * `exchange_local_time`: Boolean, defaults to `false`. If set to true, the timestamp corresponds to the exchange local time; otherwise, it's in GMT.

## Returns

An `OrderedDict{String, Union{String,Vector{DateTime},Vector{Int},Vector{Float64}}}` containing the requested split data.

# Examples
```julia
julia> get_splits("AAPL", startdt = "2000-01-01", enddt = "2020-01-01")
OrderedDict{String, Union{String,Vector{DateTime},Vector{Int},Vector{Float64}}} with 5 entries:
  "ticker"      => "AAPL"
  "timestamp"   => [DateTime("2000-06-21T13:30:00"), DateTime("2005-02-28T14:30:00"), DateTime("2014-06-09T13:30:00")]
  "numerator"   => [2, 2, 7]
  "denominator" => [1, 1, 1]
  "ratio"       => [2.0, 2.0, 7.0]

## Can be easily converted to a DataFrame
julia> using DataFrames
julia> get_splits("AAPL", startdt = "2000-01-01", enddt = "2020-01-01") |> DataFrame
3×5 DataFrame
 Row │ ticker  timestamp            numerator  denominator  ratio   
     │ String  DateTime             Int64      Int64        Float64 
─────┼──────────────────────────────────────────────────────────────
   1 │ AAPL    2000-06-21T13:30:00          2            1      2.0
   2 │ AAPL    2005-02-28T14:30:00          2            1      2.0
   3 │ AAPL    2014-06-09T13:30:00          7            1      7.0

## Broadcasting
julia> get_splits.(["AAPL", "F"], startdt = "2000-01-01", enddt = "2020-01-01")
2-element Vector{OrderedDict{String, Union{String,Vector{DateTime},Vector{Int},Vector{Float64}}}}:
 OrderedDict("ticker" => "AAPL", "timestamp" => [DateTime("2000-06-21T13:30:00"), DateTime("2005-02-28T14:30:00"), DateTime("2014-06-09T13:30:00")], "numerator" => [2, 2, 7], "denominator" => [1, 1, 1], "ratio" => [2.0, 2.0, 7.0])
 OrderedDict("ticker" => "F", "timestamp" => [DateTime("2000-06-29T13:30:00"), DateTime("2000-08-03T13:30:00")], "numerator" => [10000, 1748175], "denominator" => [9607, 1000000], "ratio" => [1.0409076714895389, 1.748175])

## Converting it to a DataFrame:
julia> using DataFrames
julia> data = get_splits.(["AAPL", "F"], startdt = "2000-01-01", enddt = "2020-01-01");

julia> vcat([DataFrame(i) for i in data]...)
5×5 DataFrame
 Row │ ticker  timestamp            numerator  denominator  ratio   
     │ String  DateTime             Int64      Int64        Float64 
─────┼──────────────────────────────────────────────────────────────
   1 │ AAPL    2000-06-21T13:30:00          2            1  2.0
   2 │ AAPL    2005-02-28T14:30:00          2            1  2.0
   3 │ AAPL    2014-06-09T13:30:00          7            1  7.0
   4 │ F       2000-06-29T13:30:00      10000         9607  1.04091
   5 │ F       2000-08-03T13:30:00    1748175      1000000  1.74818
```
"""
function get_splits(symbol::String; 
                    startdt::Union{Date,DateTime,AbstractString}="", 
                    enddt::Union{Date,DateTime,AbstractString}="",
                    timeout::Int=10,
                    throw_error::Bool=false,
                    exchange_local_time::Bool=false)

    start_unix = isempty(startdt) ? 0 : _date_to_unix(startdt)
    end_unix = isempty(enddt) ? Int(floor(datetime2unix(now()))) : _date_to_unix(enddt)

    parameters = Dict{String,Union{String,Int}}(
        "period1" => start_unix,
        "period2" => end_unix,
        "interval" => "1d",
        "events" => "splits"
    )
    url = "$(_BASE_URL_)/v8/finance/chart/$(uppercase(symbol))"

    try
        res = HTTP.get(url, query=parameters, readtimeout=timeout, proxy=_PROXY_SETTINGS[:proxy], headers=_PROXY_SETTINGS[:auth])
        return _process_splits_response(res.body, symbol, exchange_local_time)
    catch e
        msg = if e isa HTTP.ExceptionRequest.StatusError
            if e.status == 404
                "$(symbol) is not a valid Symbol."
            else
                yahoo_error = JSON3.read(e.response.body)
                if haskey(yahoo_error, :chart) && haskey(yahoo_error.chart, :error)
                    error_description = yahoo_error.chart.error.description
                    date_matches = collect(eachmatch(r"(-)?[0-9]{1,}", error_description))
                    if length(date_matches) >= 2
                        error_dates = unix2datetime.(parse.(Float64, [m.match for m in date_matches[1:2]]))
                        "Data doesn't exist for startDate = $(error_dates[1]), endDate = $(error_dates[2]) for $symbol"
                    else
                        error_description
                    end
                elseif haskey(yahoo_error, :finance)
                    yahoo_error.finance.error.description
                else
                    "An unknown error occurred: $(e.status)"
                end
            end
        else
            "An error occurred: $(sprint(showerror, e))"
        end

        if throw_error
            error(msg)
        else
            @warn msg
            return _empty_splits_dict(symbol)
        end
    end
end

function _process_splits_response(response_body, symbol, exchange_local_time)
    res = JSON3.read(response_body).chart.result[1]
    time_offset = exchange_local_time ? res.meta.gmtoffset : 0

    d = _empty_splits_dict(symbol)

    if haskey(res, :events) && haskey(res.events, :splits)
        for v in values(res.events.splits)
            push!(d["timestamp"], unix2datetime(v.date + time_offset))
            push!(d["numerator"], v.numerator)
            push!(d["denominator"], v.denominator)
        end
        d["ratio"] = d["numerator"] ./ d["denominator"]
    end

    return d
end

function _empty_splits_dict(symbol)
    OrderedDict{String,Union{String,Vector{DateTime},Vector{Int},Vector{Float64}}}(
        "ticker" => symbol,
        "timestamp" => DateTime[],
        "numerator" => Int[],
        "denominator" => Int[],
        "ratio" => Float64[]
    )
end













"""
    get_dividends(symbol::String; startdt::Union{Date,DateTime,AbstractString}="", enddt::Union{Date,DateTime,AbstractString}="", timeout::Int=10, throw_error::Bool=false, exchange_local_time::Bool=false)

Retrieves dividend data from Yahoo Finance.

## Arguments

 * `symbol`: A ticker (e.g., AAPL for Apple Inc., or ^GSPC for the S&P 500)

 * `startdt` and `enddt`: Optional. Can be of type `Date`, `DateTime`, or a `String` in the format "yyyy-mm-dd". If not provided, `startdt` defaults to the earliest available data and `enddt` to the current date.

 * `timeout`: Integer, defaults to 10. The timeout for the HTTP request in seconds.

 * `throw_error`: Boolean, defaults to `false`. If set to true, the function raises an error when the ticker is not valid or other issues occur. If false, a warning is given and an empty `OrderedDict` is returned.

 * `exchange_local_time`: Boolean, defaults to `false`. If set to true, the timestamp corresponds to the exchange local time; otherwise, it's in GMT.

## Returns

An `OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}` containing the following keys:
 * ticker
 * timestamp
 * div

# Examples
```julia
julia> get_dividends("AAPL", startdt = "2021-01-01", enddt="2022-01-01")
OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}} with 3 entries:
  "ticker"    => "AAPL"
  "timestamp" => [DateTime("2021-02-05T14:30:00"), DateTime("2021-05-07T13:30:00"), DateTime("2021-08-06T13:30:00"), DateTime("2021-11-05T13:30:00")]
  "div"       => [0.205, 0.22, 0.22, 0.22]

## Can be easily converted to a DataFrame
julia> using DataFrames
julia> get_dividends("AAPL", startdt = "2021-01-01", enddt="2022-01-01") |> DataFrame
4×3 DataFrame
 Row │ ticker  timestamp            div     
     │ String  DateTime             Float64 
─────┼───────────────────────────────────────
   1 │ AAPL    2021-02-05T14:30:00    0.205
   2 │ AAPL    2021-05-07T13:30:00    0.22
   3 │ AAPL    2021-08-06T13:30:00    0.22
   4 │ AAPL    2021-11-05T13:30:00    0.22

## Broadcasting
julia> get_dividends.(["AAPL", "F"], startdt = "2021-01-01", enddt="2022-01-01")
2-element Vector{OrderedDict{String, Union{String,Vector{DateTime},Vector{Float64}}}}:
 OrderedDict("ticker" => "AAPL", "timestamp" => [DateTime("2021-02-05T14:30:00"), DateTime("2021-05-07T13:30:00"), DateTime("2021-08-06T13:30:00"), DateTime("2021-11-05T13:30:00")], "div" => [0.205, 0.22, 0.22, 0.22])
 OrderedDict("ticker" => "F", "timestamp" => [DateTime("2021-11-18T14:30:00")], "div" => [0.1])

## Converting it to a DataFrame:
julia> using DataFrames
julia> data = get_dividends.(["AAPL", "F"], startdt = "2021-01-01", enddt="2022-01-01");

julia> vcat([DataFrame(i) for i in data]...)
5×3 DataFrame
 Row │ ticker  timestamp            div     
     │ String  DateTime             Float64 
─────┼───────────────────────────────────────
   1 │ AAPL    2021-02-05T14:30:00    0.205
   2 │ AAPL    2021-05-07T13:30:00    0.22
   3 │ AAPL    2021-08-06T13:30:00    0.22
   4 │ AAPL    2021-11-05T13:30:00    0.22
   5 │ F       2021-11-18T14:30:00    0.1
```
"""
function get_dividends(symbol::String; 
                       startdt::Union{Date,DateTime,AbstractString}="", 
                       enddt::Union{Date,DateTime,AbstractString}="",
                       timeout::Int=10,
                       throw_error::Bool=false,
                       exchange_local_time::Bool=false)

    start_unix = isempty(startdt) ? 0 : _date_to_unix(startdt)
    end_unix = isempty(enddt) ? Int(floor(datetime2unix(now()))) : _date_to_unix(enddt)

    parameters = Dict{String,Union{String,Int}}(
        "period1" => start_unix,
        "period2" => end_unix,
        "interval" => "1d",
        "events" => "div"
    )
    url = "$(_BASE_URL_)/v8/finance/chart/$(uppercase(symbol))"

    try
        res = HTTP.get(url, query=parameters, readtimeout=timeout, proxy=_PROXY_SETTINGS[:proxy], headers=_PROXY_SETTINGS[:auth])
        return _process_dividends_response(res.body, symbol, exchange_local_time)
    catch e
        msg = if e isa HTTP.ExceptionRequest.StatusError
            if e.status == 404
                "$(symbol) is not a valid Symbol."
            else
                yahoo_error = JSON3.read(e.response.body)
                if haskey(yahoo_error, :chart) && haskey(yahoo_error.chart, :error)
                    error_description = yahoo_error.chart.error.description
                    date_matches = collect(eachmatch(r"(-)?[0-9]{1,}", error_description))
                    if length(date_matches) >= 2
                        error_dates = unix2datetime.(parse.(Float64, [m.match for m in date_matches[1:2]]))
                        "Data doesn't exist for startDate = $(error_dates[1]), endDate = $(error_dates[2]) for $symbol"
                    else
                        error_description
                    end
                elseif haskey(yahoo_error, :finance)
                    yahoo_error.finance.error.description
                else
                    "An unknown error occurred: $(e.status)"
                end
            end
        else
            "An error occurred: $(sprint(showerror, e))"
        end

        if throw_error
            error(msg)
        else
            @warn msg
            return _empty_dividends_dict(symbol)
        end
    end
end

function _process_dividends_response(response_body, symbol, exchange_local_time)
    res = JSON3.read(response_body).chart.result[1]
    time_offset = exchange_local_time ? res.meta.gmtoffset : 0

    d = _empty_dividends_dict(symbol)

    if haskey(res, :events) && haskey(res.events, :dividends)
        for v in values(res.events.dividends)
            push!(d["timestamp"], unix2datetime(v.date + time_offset))
            push!(d["div"], v.amount)
        end
    end

    return d
end

function _empty_dividends_dict(symbol)
    OrderedDict{String,Union{String,Vector{DateTime},Vector{Float64}}}(
        "ticker" => symbol,
        "timestamp" => DateTime[],
        "div" => Float64[]
    )
end





"""
    sink_prices_to(::Type{OrderedDict},x::OrderedDict{String,Any})

Converts an exisitng OrderedDict output from get_prices to an OrderedDict
If TimeSeries.jl or TSFrames.jl are loaded this function is extended to allow sinking into these types.

"""
function sink_prices_to(::Type{OrderedDict},x::OrderedDict{String,Union{String,Vector{DateTime},Vector{Float64}}})
    return x
end
