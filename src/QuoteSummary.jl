const _QuoteSummary_Items = [
    "assetProfile",
    "balanceSheetHistory",
    "balanceSheetHistoryQuarterly",
    "calendarEvents",
    "cashflowStatementHistory",
    "cashflowStatementHistoryQuarterly",
    "defaultKeyStatistics",
    "earnings",
    "earningsHistory",
    "earningsTrend",
    "esgScores",
    "financialData",
    "fundOwnership",
    "fundPerformance",
    "fundProfile",
    "incomeStatementHistory",
    "incomeStatementHistoryQuarterly",
    "indexTrend",
    "industryTrend",
    "insiderHolders",
    "insiderTransactions",
    "institutionOwnership",
    "majorDirectHolders",
    "majorHoldersBreakdown",
    "netSharePurchaseActivity",
    "price",
    "quoteType",
    "recommendationTrend",
    "secFilings",
    "sectorTrend",
    "summaryDetail",
    "summaryProfile",
    "topHoldings",
    "upgradeDowngradeHistory"
]

"""
    get_quoteSummary(symbol::String; item=nothing)

Retrievs general information from Yahoo Finance stored in a JSON3 object.

## Arguments

 * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

 * item can either be a string or multiple items as a `Vector` of `Strings`. To see valid items call `_QuoteSummary_Items` (not all items are available for all types of securities)  

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty `JSON3.Object` is returned.

# Examples
```julia-repl
julia> get_quoteSummary("AAPL")

JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 31 entries:
:assetProfile             => {…
:recommendationTrend      => {…
:cashflowStatementHistory => {…

⋮                         => ⋮
julia> get_quoteSummary("AAPL",item = "quoteType")
JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 13 entries:
:exchange               => "NMS"
:quoteType              => "EQUITY"
:symbol                 => "AAPL"
⋮                       => ⋮
```
"""
function get_quoteSummary(symbol::String; item=nothing,throw_error=false)

    # Check if symbol is valid
    old_symbol = symbol
    symbol = get_valid_symbols(symbol)
    if isempty(symbol)
        if throw_error
            error("$old_symbol is not a valid Symbol!")
        else
            @warn "$old_symbol is not a valid Symbol an empy OrderedCollections.OrderedDict was returned!" 
            return JSON3.Object()
        end
    else
        symbol = symbol[1]
    end

    if isequal(item,nothing)
        item = _QuoteSummary_Items
    end

    @assert all(in.(item, (_QuoteSummary_Items,))) "At least one item is not a valid option. To view options please call _QuoteSummary_Items"
    
    if typeof(item) <: AbstractString
        q= Dict("formatted" => "false","modules" => item)
    else
        q= Dict("formatted" => "false","modules" => join(item,","))
    end
    
    res = HTTP.get("https://query2.finance.yahoo.com/v10/finance/quoteSummary/$(symbol)",query =q, proxy=_PROXY_SETTINGS[:proxy],headers=_PROXY_SETTINGS[:auth])    
    res = JSON3.read(res.body)
    if typeof(item) <: AbstractString
        return res.quoteSummary.result[1][Symbol(item)]
    else
        return res.quoteSummary.result[1]
    end
end



#helper Function
function _no_key_missing(x::JSON3.Object,k::Symbol,subitem=nothing,to_date = false,from_int = false)
    if !in(k,keys(x))
        return missing
    end
    if isequal(subitem,nothing)
        if to_date
            return from_int ? unix2datetime(x[k]) : DateTime(x[k])
        else
            return x[k]
        end
    else
        if to_date
            return from_int ? unix2datetime(x[k][subitem]) : DateTime(x[k][subitem])
        else
            return x[k][subitem]
        end
    end

end

function _check_field_quotetype(x)
    d = Dict("ETF" => [:assetProfile,:fundProfile,:summaryDetail,:price,:defaultKeyStatistics,:summaryProfile,:topHoldings,:fundPerformance,:quoteType],
    "MUTUALFUND"=>  [:assetProfile,:fundProfile,:summaryDetail,:price,:esgScores,:defaultKeyStatistics,:summaryProfile,:topHoldings,:fundPerformance,:quoteType],
    "CURRENCY"=> [:summaryDetail,:quoteType,:price],
    "FUTURE"=> [:summaryDetail,:quoteType,:price],
    "EQUITY" => [:assetProfile, :recommendationTrend, :cashflowStatementHistory, :indexTrend, :defaultKeyStatistics, :industryTrend, :quoteType, :incomeStatementHistory, :fundOwnership, :summaryDetail, :insiderHolders, :calendarEvents, :upgradeDowngradeHistory, :price, :balanceSheetHistory, :earningsTrend, :secFilings, :institutionOwnership, :majorHoldersBreakdown, :balanceSheetHistoryQuarterly, :earningsHistory, :majorDirectHolders, :esgScores, :summaryProfile, :netSharePurchaseActivity, :insiderTransactions, :sectorTrend, :incomeStatementHistoryQuarterly, :cashflowStatementHistoryQuarterly, :earnings, :financialData])
    res = String[]
    for (k,v) in d
        if in(x,v)
            push!(res,k)
        end
    end
    return res
end
_quote_type(quoteSummary::JSON3.Object) = quoteSummary.quoteType.quoteType




"""
    get_calendar_events(quoteSummary::JSON3.Object)

Retrievs calendar events from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_calendar_events
OrderedDict{String, Any} with 3 entries:
  "dividend_date"   => DateTime("2022-11-10T00:00:00")
  "earnings_dates"  => [DateTime("2023-01-25T10:59:00"), DateTime("2023-01-30T12:00:00")]
  "exdividend_date" => DateTime("2022-11-04T00:00:00")

julia> get_calendar_events("AAPL")
OrderedDict{String, Any} with 3 entries:
  "dividend_date"   => DateTime("2022-11-10T00:00:00")
  "earnings_dates"  => [DateTime("2023-01-25T10:59:00"), DateTime("2023-01-30T12:00:00")]
  "exdividend_date" => DateTime("2022-11-04T00:00:00")

julia> using DataFrames
julia> get_calendar_events("AAPL") |> DataFrame
2×3 DataFrame
 Row │ dividend_date        earnings_dates       exdividend_date     
     │ DateTime             DateTime             DateTime
─────┼───────────────────────────────────────────────────────────────
   1 │ 2022-11-10T00:00:00  2023-01-25T10:59:00  2022-11-04T00:00:00
   2 │ 2022-11-10T00:00:00  2023-01-30T12:00:00  2022-11-04T00:00:00
```
"""
function get_calendar_events(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:calendarEvents)
    @assert in(quote_type,field_types) """Calendar Events dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:calendarEvents, keys(quoteSummary)) "There are no calendar Events for this item."
    res = OrderedCollections.OrderedDict("dividend_date" => unix2datetime(quoteSummary[:calendarEvents].dividendDate),
                "earnings_dates" => unix2datetime.(quoteSummary[:calendarEvents].earnings.earningsDate),
                "exdividend_date" =>unix2datetime(quoteSummary[:calendarEvents].exDividendDate))
    return res
end
get_calendar_events(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_calendar_events




"""
    get_earnings_estimates(quoteSummary::JSON3.Object)

Retrievs the earnings estimates from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_earnings_estimates
OrderedDict{String, Vector} with 3 entries:
  "quarter"  => ["4Q2021", "1Q2022", "2Q2022", "3Q2022", "4Q2022"]
  "estimate" => [1.89, 1.43, 1.16, 1.27, 1.98]
  "actual"   => Union{Missing, Float64}[2.1, 1.52, 1.2, 1.29, missing]

julia> get_earnings_estimates("AAPL")
OrderedDict{String, Vector} with 3 entries:
  "quarter"  => ["4Q2021", "1Q2022", "2Q2022", "3Q2022", "4Q2022"]
  "estimate" => [1.89, 1.43, 1.16, 1.27, 1.98]
  "actual"   => Union{Missing, Float64}[2.1, 1.52, 1.2, 1.29, missing]

julia> using DataFrames
julia> get_earnings_estimates("AAPL") |> DataFrame
5×3 DataFrame
 Row │ quarter  estimate  actual     
     │ String   Float64   Float64?   
─────┼───────────────────────────────
   1 │ 4Q2021       1.89        2.1
   2 │ 1Q2022       1.43        1.52
   3 │ 2Q2022       1.16        1.2
   4 │ 3Q2022       1.27        1.29
   5 │ 4Q2022       1.98  missing   
```
"""
function get_earnings_estimates(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:earnings)
    @assert in(quote_type,field_types) """Earnings dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:earnings, keys(quoteSummary)) "There are no earnings for this item."
    if isempty(quoteSummary[:earnings].earningsChart.quarterly)
        return OrderedCollections.OrderedDict()
    end

    quarter = String[]
    actual = Union{Missing,Float64}[]
    estimate = Float64[]
    for i in quoteSummary[:earnings].earningsChart.quarterly
        push!(quarter,i.date)
        push!(actual,i.actual)
        push!(estimate,i.estimate)
    end
    quoteSummary[:earnings].earningsChart
    push!(quarter,string(quoteSummary[:earnings].earningsChart.currentQuarterEstimateDate,quoteSummary[:earnings].earningsChart.currentQuarterEstimateYear))
    push!(actual,missing)
    push!(estimate, quoteSummary[:earnings].earningsChart.currentQuarterEstimate)
    return OrderedCollections.OrderedDict(["quarter","estimate","actual"] .=> [quarter,estimate,actual])
end
get_earnings_estimates(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_earnings_estimates


"""
    get_eps(quoteSummary::JSON3.Object)

Retrievs the earnings per share from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_eps
OrderedDict{String, Vector} with 4 entries:
  "quarter"  => [DateTime("2021-12-31T00:00:00"), DateTime("2022-03-31T00:00:00"), DateTime("2022-06-30T00:00:00"), DateTime("2022-09-30T00:00:00")]
  "estimate" => [1.89, 1.43, 1.16, 1.27]
  "actual"   => [2.1, 1.52, 1.2, 1.29]
  "surprise" => [0.111, 0.063, 0.034, 0.016]

julia> get_eps("AAPL")
OrderedDict{String, Vector} with 4 entries:
  "quarter"  => [DateTime("2021-12-31T00:00:00"), DateTime("2022-03-31T00:00:00"), DateTime("2022-06-30T00:00:00"), DateTime("2022-09-30T00:00:00")]
  "estimate" => [1.89, 1.43, 1.16, 1.27]
  "actual"   => [2.1, 1.52, 1.2, 1.29]
  "surprise" => [0.111, 0.063, 0.034, 0.016]

julia> using DataFrames
julia> get_eps("AAPL") |> DataFrame
4×4 DataFrame
 Row │ quarter              estimate  actual   surprise 
     │ DateTime             Float64   Float64  Float64  
─────┼──────────────────────────────────────────────────
   1 │ 2021-12-31T00:00:00      1.89     2.1      0.111
   2 │ 2022-03-31T00:00:00      1.43     1.52     0.063
   3 │ 2022-06-30T00:00:00      1.16     1.2      0.034
   4 │ 2022-09-30T00:00:00      1.27     1.29     0.016
```
"""
function get_eps(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:earningsHistory)
    @assert in(quote_type,field_types) """EPS do not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:earningsHistory, keys(quoteSummary)) "There are no earnings per share for this item."
    if isempty(quoteSummary[:earningsHistory].history)
        return OrderedCollections.OrderedDict()
    end

    quarter = DateTime[]
    actual = Float64[]
    estimate = Float64[]
    surprise = Float64[]
    for i in quoteSummary[:earningsHistory].history
        push!(quarter,DateTime(i.quarter.fmt))
        push!(actual,i.epsActual.raw)
        push!(estimate,i.epsEstimate.raw)
        push!(surprise,i.surprisePercent.raw)
    end
    return OrderedCollections.OrderedDict(["quarter","estimate","actual","surprise"] .=> [quarter,estimate,actual,surprise])
end
get_eps(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_eps



"""
    get_insider_holders(quoteSummary::JSON3.Object)

Retrievs the insiders holdings from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_insider_holders
OrderedDict{String, Vector} with 8 entries:
    "name"                 => ["ADAMS KATHERINE L", "BELL JAMES A", "JUNG ANDREA", "KONDO C…
    "relation"             => Union{Missing, String}["General Counsel", "Director", "Direct…  
    "description"          => Union{Missing, String}["Sale", "Stock Gift", "Conversion of E…  
    "lastestTransDate"     => Union{Missing, DateTime}[DateTime("2022-10-03T00:00:00"), Dat…  
    "positionDirect"       => Union{Missing, Int64}[427334, 34990, 139594, 31505, 4588720, …  
    "positionDirectDate"   => Union{Missing, DateTime}[DateTime("2022-10-03T00:00:00"), Dat…  
    "positionIndirect"     => Union{Missing, Int64}[missing, missing, missing, missing, mis…  
    "positionIndirectDate" => Union{Missing, DateTime}[missing, missing, missing, missing, …

julia> get_insider_holders("AAPL")
OrderedDict{String, Vector} with 8 entries:
    "name"                 => ["ADAMS KATHERINE L", "BELL JAMES A", "JUNG ANDREA", "KONDO C…
    "relation"             => Union{Missing, String}["General Counsel", "Director", "Direct…  
    "description"          => Union{Missing, String}["Sale", "Stock Gift", "Conversion of E…  
    "lastestTransDate"     => Union{Missing, DateTime}[DateTime("2022-10-03T00:00:00"), Dat…  
    "positionDirect"       => Union{Missing, Int64}[427334, 34990, 139594, 31505, 4588720, …  
    "positionDirectDate"   => Union{Missing, DateTime}[DateTime("2022-10-03T00:00:00"), Dat…  
    "positionIndirect"     => Union{Missing, Int64}[missing, missing, missing, missing, mis…  
    "positionIndirectDate" => Union{Missing, DateTime}[missing, missing, missing, missing, …


julia> using DataFrames
julia> get_insider_holders("AAPL") |> DataFrame
10×8 DataFrame
 Row │ name                relation                 description                        l ⋯
     │ String              String?                  String?                            D ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ ADAMS KATHERINE L   General Counsel          Sale                               2 ⋯
   2 │ BELL JAMES A        Director                 Stock Gift                         2  
   3 │ JUNG ANDREA         Director                 Conversion of Exercise of deriva…  2  
   4 │ KONDO CHRISTOPHER   Officer                  Sale                               2  
   5 │ LEVINSON ARTHUR D   Director                 Sale                               2 ⋯
   6 │ MAESTRI LUCA        Chief Financial Officer  Sale                               2  
   7 │ O'BRIEN DEIRDRE     Officer                  Sale                               2  
   8 │ SUGAR RONALD D      Director                 Conversion of Exercise of deriva…  2  
   9 │ WAGNER SUSAN L      Director                 Conversion of Exercise of deriva…  2 ⋯
  10 │ WILLIAMS JEFFREY E  Chief Operating Officer  Conversion of Exercise of deriva…  2  
                                                                         5 columns omitted
```
"""
function get_insider_holders(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:insiderHolders)
    @assert in(quote_type,field_types) """Insider Holdings dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:insiderHolders, keys(quoteSummary)) "There are is no insiderHolders item."
    if isempty(quoteSummary[:insiderHolders].holders)
        return OrderedCollections.OrderedDict()
    end

    name = String[]
    relation = Union{Missing,String}[]
    des = Union{Missing,String}[]
    lasttrandt = Union{Missing,DateTime}[]
    direct = Union{Missing,Int}[]
    direct_dt = Union{Missing,DateTime}[]
    indirect = Union{Missing,Int}[]
    indirect_dt = Union{Missing,DateTime}[]
    for i in quoteSummary[:insiderHolders].holders
        push!(name, i.name)
        push!(relation, _no_key_missing(i,:relation))
        push!(des, _no_key_missing(i,:transactionDescription))
        push!(lasttrandt, _no_key_missing(i,:latestTransDate,:fmt,true))
        push!(direct, _no_key_missing(i,:positionDirect,:raw))
        push!(direct_dt,_no_key_missing(i,:positionDirectDate,:fmt,true))
        push!(indirect,_no_key_missing(i,:positionIndirect,:raw))
        push!(indirect_dt, _no_key_missing(i,:positionIndirectDate,:fmt,true))
    end
    res = OrderedCollections.OrderedDict(["name","relation","description","lastestTransDate","positionDirect",
                "positionDirectDate","positionIndirect","positionIndirectDate"] .=> 
               [name, relation,des,lasttrandt,direct,direct_dt,indirect,indirect_dt])
    return res
end
get_insider_holders(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_insider_holders



"""
    get_insider_transactions(quoteSummary::JSON3.Object)

Retrievs the insider transactions from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_insider_transactions
OrderedDict{String, Vector} with 7 entries:
  "filerName"       => ["KONDO CHRISTOPHER", "MAESTRI LUCA", "O'BRIEN DEIRDRE", "KONDO CH…  
  "filerRelation"   => Union{Missing, String}["Officer", "Chief Financial Officer", "Offi…  
  "transactionText" => Union{Missing, String}["Sale at price 148.72 per share.", "Sale at…  
  "date"            => Union{Missing, DateTime}[DateTime("2022-11-22T00:00:00"), DateTime…  
  "ownership"       => Union{Missing, String}["D", "D", "D", "D", "D", "D", "D", "D", "I"…  
  "shares"          => Union{Missing, Int64}[20200, 176299, 8053, 13136, 16612, 181139, 1…  
  "value"           => Union{Missing, Int64}[3004144, 27493275, 1147150, missing, missing…

julia> get_insider_transactions("AAPL")
OrderedDict{String, Vector} with 7 entries:
  "filerName"       => ["KONDO CHRISTOPHER", "MAESTRI LUCA", "O'BRIEN DEIRDRE", "KONDO CH…  
  "filerRelation"   => Union{Missing, String}["Officer", "Chief Financial Officer", "Offi…  
  "transactionText" => Union{Missing, String}["Sale at price 148.72 per share.", "Sale at…  
  "date"            => Union{Missing, DateTime}[DateTime("2022-11-22T00:00:00"), DateTime…  
  "ownership"       => Union{Missing, String}["D", "D", "D", "D", "D", "D", "D", "D", "I"…  
  "shares"          => Union{Missing, Int64}[20200, 176299, 8053, 13136, 16612, 181139, 1…  
  "value"           => Union{Missing, Int64}[3004144, 27493275, 1147150, missing, missing…

julia> using DataFrames
julia> get_insider_transactions("AAPL") |> DataFrame
75×7 DataFrame
 Row │ filerName           filerRelation            transactionText                    d ⋯
     │ String              String?                  String?                            D ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ KONDO CHRISTOPHER   Officer                  Sale at price 148.72 per share.    2 ⋯
   2 │ MAESTRI LUCA        Chief Financial Officer  Sale at price 154.70 - 157.20 pe…  2  
   3 │ O'BRIEN DEIRDRE     Officer                  Sale at price 142.45 per share.    2  
   4 │ KONDO CHRISTOPHER   Officer                                                     2  
   5 │ O'BRIEN DEIRDRE     Officer                                                     2 ⋯   
   6 │ ADAMS KATHERINE L   General Counsel          Sale at price 138.44 - 142.93 pe…  2  
   7 │ O'BRIEN DEIRDRE     Officer                  Sale at price 141.09 - 142.83 pe…  2  
  ⋮  │         ⋮                      ⋮                             ⋮                    ⋱
  70 │ WAGNER SUSAN L      Director                                                    2  
  71 │ JUNG ANDREA         Director                                                    2 ⋯
  72 │ BELL JAMES A        Director                                                    2  
  73 │ LOZANO MONICA C.    Director                                                    2  
  74 │ GORE ALBERT A JR    Director                                                    2  
  75 │ ADAMS KATHERINE L   General Counsel          Sale at price 131.79 - 134.56 pe…  2 ⋯
                                                             4 columns and 62 rows omitted
```
"""
function get_insider_transactions(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:insiderTransactions)
    @assert in(quote_type,field_types) """Insider Transactions dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:insiderTransactions, keys(quoteSummary)) "There are is no insiderTransactions item."
    if isempty(quoteSummary[:insiderTransactions].transactions)
        return OrderedCollections.OrderedDict()
    end

    name = String[]
    relation = Union{Missing,String}[]
    text = Union{Missing,String}[]
    date = Union{Missing,DateTime}[]
    ownership = Union{Missing,String}[]
    shares = Union{Missing,Int}[]
    value = Union{Missing,Int}[]
    for i in quoteSummary[:insiderTransactions].transactions
        push!(name, i.filerName)
        push!(relation, _no_key_missing(i,:filerRelation))
        push!(text, _no_key_missing(i,:transactionText))
        push!(date, _no_key_missing(i,:startDate,:fmt,true))
        push!(ownership, _no_key_missing(i,:ownership))
        push!(shares,_no_key_missing(i,:shares,:raw))
        push!(value,_no_key_missing(i,:value,:raw))
    end
    res = OrderedCollections.OrderedDict(["filerName","filerRelation","transactionText","date","ownership",
                "shares","value"] .=> 
               [name, relation,text,date,ownership,shares,value])
    return res
end
get_insider_transactions(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_insider_transactions


"""
    get_institutional_ownership(quoteSummary::JSON3.Object)

Retrievs the institutional ownership from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_institutional_ownership
OrderedDict{String, Vector} with 6 entries:
  "organization" => ["Vanguard Group, Inc. (The)", "Blackrock Inc.", "Berkshire Hathaway,…  
  "reportDate"   => Union{Missing, DateTime}[DateTime("2022-09-30T00:00:00"), DateTime("2…  
  "pctHeld"      => Union{Missing, Float64}[0.08, 0.0641, 0.0562, 0.0372, 0.0221, 0.0176,…  
  "position"     => Union{Missing, Int64}[1272378901, 1020245185, 894802319, 591543874, 3…  
  "value"        => Union{Missing, Int64}[164913030135, 132233979050, 115975329111, 76670…  
  "pctChange"    => Union{Missing, Float64}[-0.0039, -0.0082, 0.0, -0.0111, 0.0191, 0.005…

julia> get_institutional_ownership("AAPL")
OrderedDict{String, Vector} with 6 entries:
  "organization" => ["Vanguard Group, Inc. (The)", "Blackrock Inc.", "Berkshire Hathaway,…  
  "reportDate"   => Union{Missing, DateTime}[DateTime("2022-09-30T00:00:00"), DateTime("2…  
  "pctHeld"      => Union{Missing, Float64}[0.08, 0.0641, 0.0562, 0.0372, 0.0221, 0.0176,…  
  "position"     => Union{Missing, Int64}[1272378901, 1020245185, 894802319, 591543874, 3…  
  "value"        => Union{Missing, Int64}[164913030135, 132233979050, 115975329111, 76670…  
  "pctChange"    => Union{Missing, Float64}[-0.0039, -0.0082, 0.0, -0.0111, 0.0191, 0.005…

julia> using DataFrames
julia> get_institutional_ownership("AAPL") |> DataFrame
10×6 DataFrame
 Row │ organization                   reportDate           pctHeld   position    value   ⋯
     │ String                         DateTime?            Float64?  Int64?      Int64?  ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ Vanguard Group, Inc. (The)     2022-09-30T00:00:00    0.08    1272378901  1649130 ⋯
   2 │ Blackrock Inc.                 2022-09-30T00:00:00    0.0641  1020245185  1322339  
   3 │ Berkshire Hathaway, Inc        2022-09-30T00:00:00    0.0562   894802319  1159753  
   4 │ State Street Corporation       2022-09-30T00:00:00    0.0372   591543874   766700  
   5 │ FMR, LLC                       2022-09-30T00:00:00    0.0221   350900116   454801 ⋯
   6 │ Geode Capital Management, LLC  2022-09-30T00:00:00    0.0176   279758518   362595  
   7 │ Price (T.Rowe) Associates Inc  2022-09-30T00:00:00    0.0141   224863541   291445  
   8 │ Morgan Stanley                 2022-09-30T00:00:00    0.0115   182728771   236834  
   9 │ Northern Trust Corporation     2022-09-30T00:00:00    0.0111   176084862   228223 ⋯
  10 │ Bank of America Corporation    2022-09-30T00:00:00    0.0089   142260591   184383  
                                                                         2 columns omitted
```
"""
function get_institutional_ownership(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:institutionOwnership)
    @assert in(quote_type,field_types) """Institutional Ownership does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:institutionOwnership, keys(quoteSummary)) "There are is no institutionOwnership item."
    if isempty(quoteSummary[:institutionOwnership].ownershipList)
        return OrderedCollections.OrderedDict()
    end

    organization = String[]
    reportDate = Union{Missing,DateTime}[]
    pctHeld = Union{Missing,Float64}[]
    position = Union{Missing,Int}[]
    value = Union{Missing,Int}[]
    pctChange = Union{Missing,Float64}[]
    for i in quoteSummary[:institutionOwnership].ownershipList
        push!(organization, i.organization)
        push!(reportDate, _no_key_missing(i,:reportDate,:fmt,true))
        push!(pctHeld, _no_key_missing(i,:pctHeld,:raw))
        push!(position, _no_key_missing(i,:position,:raw))
        push!(value, _no_key_missing(i,:value,:raw))
        push!(pctChange,_no_key_missing(i,:pctChange,:raw))
    end
    res = OrderedCollections.OrderedDict(["organization","reportDate","pctHeld","position","value",
                "pctChange"] .=> 
               [organization,reportDate,pctHeld,position,value,pctChange])
    return res
end
get_institutional_ownership(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_institutional_ownership


"""
    get_major_holders_breakdown(quoteSummary::JSON3.Object)

Retrievs the breakdown of the major holders from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_major_holders_breakdown
OrderedDict{String, Real} with 4 entries:  
  "insidersPercentHeld"          => 0.00072
  "institutionsPercentHeld"      => 0.60915
  "institutionsFloatPercentHeld" => 0.60959
  "institutionsCount"            => 5526  

julia> get_major_holders_breakdown("AAPL")
OrderedDict{String, Real} with 4 entries:  
  "insidersPercentHeld"          => 0.00072
  "institutionsPercentHeld"      => 0.60915
  "institutionsFloatPercentHeld" => 0.60959
  "institutionsCount"            => 5526
```
"""
function get_major_holders_breakdown(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:majorHoldersBreakdown)
    @assert in(quote_type,field_types) """The breadkown of major holders does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:majorHoldersBreakdown, keys(quoteSummary)) "There are is no majorHoldersBreakdown item."
    result = OrderedCollections.OrderedDict(String(k) => v for (k , v) in quoteSummary.majorHoldersBreakdown)
    delete!(result,"maxAge")
    return result    
end
get_major_holders_breakdown(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_major_holders_breakdown



"""
    get_recommendation_trend(quoteSummary::JSON3.Object)

Retrievs the recommendation trend from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_recommendation_trend
OrderedDict{String, Vector} with 6 entries:
  "period"     => ["0m", "-1m", "-2m", "-3m"]
  "strongbuy"  => [11, 11, 11, 13]
  "buy"        => [21, 25, 26, 20]
  "hold"       => [6, 6, 5, 8]
  "sell"       => [0, 1, 1, 0]
  "strongsell" => [0, 0, 0, 0]

julia> get_recommendation_trend("AAPL")
OrderedDict{String, Vector} with 6 entries:
  "period"     => ["0m", "-1m", "-2m", "-3m"]
  "strongbuy"  => [11, 11, 11, 13]
  "buy"        => [21, 25, 26, 20]
  "hold"       => [6, 6, 5, 8]
  "sell"       => [0, 1, 1, 0]
  "strongsell" => [0, 0, 0, 0]
  
julia> using DataFrames
julia> get_recommendation_trend("AAPL") |> DataFrame
4×6 DataFrame
 Row │ period  strongbuy  buy    hold   sell   strongsell 
     │ String  Int64      Int64  Int64  Int64  Int64      
─────┼────────────────────────────────────────────────────
   1 │ 0m             11     21      6      0           0
   2 │ -1m            11     25      6      1           0
   3 │ -2m            11     26      5      1           0
   4 │ -3m            13     20      8      0           0
```
"""
function get_recommendation_trend(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:recommendationTrend)
    @assert in(quote_type,field_types) """The recommendation trend does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:recommendationTrend, keys(quoteSummary)) "There are is no recommendationTrend item."
    if isempty(quoteSummary[:recommendationTrend].trend)
        return OrderedCollections.OrderedDict()
    end

    period = String[]
    strongbuy = Int[]
    buy = Int[]
    hold = Int[]
    sell = Int[]
    strongsell = Int[]
    for i in quoteSummary[:recommendationTrend].trend
        push!(period, i.period)
        push!(strongbuy, i.strongBuy)
        push!(buy, i.buy)
        push!(hold, i.hold)
        push!(sell, i.sell)
        push!(strongsell, i.strongSell)
    end
    res = OrderedCollections.OrderedDict(["period","strongbuy","buy","hold","sell",
                "strongsell"] .=> 
               [period,strongbuy,buy,hold,sell,strongsell])
    return res
end
get_recommendation_trend(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_recommendation_trend



"""
    get_summary_detail(quoteSummary::JSON3.Object)

Retrievs the summaryDetail Item from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_summary_detail
OrderedDict{String, Any} with 41 entries:
  "priceHint"                  => 2
  "previousClose"              => 126.04
  "open"                       => 127.99
  "dayLow"                     => 127.815
  "dayHigh"                    => 130.48
  "regularMarketPreviousClose" => 126.04
  "regularMarketOpen"          => 127.99
  "regularMarketDayLow"        => 127.815
  "regularMarketDayHigh"       => 130.48
  "dividendRate"               => 0.92
  "dividendYield"              => 0.0073
  "exDividendDate"             => 1667520000
  "payoutRatio"                => 0.1473
  "fiveYearAvgDividendYield"   => 0.99
  "beta"                       => 1.21947
  "trailingPE"                 => 21.2128
  "forwardPE"                  => 19.1448
  ⋮                            => ⋮

julia> get_summary_detail("AAPL")
OrderedDict{String, Any} with 41 entries:
  "priceHint"                  => 2
  "previousClose"              => 126.04
  "open"                       => 127.99
  "dayLow"                     => 127.815
  "dayHigh"                    => 130.48
  "regularMarketPreviousClose" => 126.04
  "regularMarketOpen"          => 127.99
  "regularMarketDayLow"        => 127.815
  "regularMarketDayHigh"       => 130.48
  "dividendRate"               => 0.92
  "dividendYield"              => 0.0073
  "exDividendDate"             => 1667520000
  "payoutRatio"                => 0.1473
  "fiveYearAvgDividendYield"   => 0.99
  "beta"                       => 1.21947
  "trailingPE"                 => 21.2128
  "forwardPE"                  => 19.1448
  ⋮                            => ⋮
```
"""
function get_summary_detail(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:summaryDetail)
    @assert in(quote_type,field_types) """Summary details dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:summaryDetail, keys(quoteSummary)) "There are is no summaryDetail item."
    result = OrderedCollections.OrderedDict(String(k) => v for (k , v) in quoteSummary.summaryDetail)
    delete!(result,"maxAge")
    return result    
end
get_summary_detail(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_summary_detail



"""
    get_sector_industry(quoteSummary::JSON3.Object)

Retrievs the Sector and Industry from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_sector_industry
OrderedDict{String, String} with 2 entries:
  "sector"   => "Technology"
  "industry" => "Consumer Electronics"

julia> get_sector_industry("AAPL")
OrderedDict{String, String} with 2 entries:
  "sector"   => "Technology"
  "industry" => "Consumer Electronics"
```
"""
function get_sector_industry(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:summaryProfile)
    @assert in(quote_type,field_types) """The summary profile does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    result = OrderedCollections.OrderedDict("sector" =>quoteSummary.summaryProfile.sector, "industry"=>quoteSummary.summaryProfile.industry)
    return result
end
get_sector_industry(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_sector_industry


"""
    get_upgrade_downgrade_history(quoteSummary::JSON3.Object)

Retrievs the upgrade and downgrade history from the quote summary.

## Arguments

Can be either a `JSON3.Object` returned from `get_quoteSummary(symbol::String; item=nothing,throw_error=false)` or a ticker symbol of type `AbstractString`
If a ticker symbol is provided `get_quoteSummary(symbol::String)` is called first. 

# Examples
```julia-repl
julia> get_quoteSummary("AAPL") |> get_upgrade_downgrade_history
OrderedDict{String, Vector} with 5 entries:
  "firm"      => ["JP Morgan", "UBS", "Morgan Stanley", "B of A Securities", "Barclays", …  
  "date"      => Union{Missing, DateTime}[DateTime("2022-12-20T11:47:33"), DateTime("2022…  
  "toGrade"   => Union{Missing, String}["Overweight", "Buy", "Overweight", "Neutral", "Eq…  
  "fromGrade" => Union{Missing, String}["", "", "", "", "", "", "", "", "", ""  …  "", ""…  
  "action"    => Union{Missing, String}["main", "main", "main", "main", "main", "main", "…

julia> get_upgrade_downgrade_history("AAPL")
OrderedDict{String, Vector} with 5 entries:
  "firm"      => ["JP Morgan", "UBS", "Morgan Stanley", "B of A Securities", "Barclays", …  
  "date"      => Union{Missing, DateTime}[DateTime("2022-12-20T11:47:33"), DateTime("2022…  
  "toGrade"   => Union{Missing, String}["Overweight", "Buy", "Overweight", "Neutral", "Eq…  
  "fromGrade" => Union{Missing, String}["", "", "", "", "", "", "", "", "", ""  …  "", ""…  
  "action"    => Union{Missing, String}["main", "main", "main", "main", "main", "main", "…
  
julia> using DataFrames
julia> get_upgrade_downgrade_history("AAPL") |> DataFrame
872×5 DataFrame
 Row │ firm               date                 toGrade       fromGrade  action  
     │ String             DateTime?            String?       String?    String? 
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ JP Morgan          2022-12-20T11:47:33  Overweight               main
   2 │ UBS                2022-11-08T12:17:03  Buy                      main
   3 │ Morgan Stanley     2022-11-08T12:14:23  Overweight               main
   4 │ B of A Securities  2022-11-07T13:08:30  Neutral                  main
   5 │ Barclays           2022-11-07T12:39:27  Equal-Weight             main
   6 │ Wedbush            2022-10-28T13:19:17  Outperform               main
   7 │ Credit Suisse      2022-10-28T11:59:30  Outperform               main
  ⋮  │         ⋮                   ⋮                ⋮            ⋮         ⋮
 867 │ Oxen Group         2012-03-14T15:25:00  Buy                      init
 868 │ Canaccord Genuity  2012-03-14T08:21:00  Buy                      main
 869 │ Morgan Stanley     2012-03-14T06:13:00  Overweight               main
 870 │ Jefferies          2012-03-13T06:08:00  Buy                      main
 871 │ FBN Securities     2012-03-08T07:33:00  Outperform               main
 872 │ Canaccord Genuity  2012-02-09T08:17:00  Buy                      main
                                                                859 rows omitted
```
"""
function get_upgrade_downgrade_history(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:upgradeDowngradeHistory)
    @assert in(quote_type,field_types) """The history of up- and downgrades does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:upgradeDowngradeHistory, keys(quoteSummary)) "There are is no upgradeDowngradeHistory item."
    if isempty(quoteSummary[:upgradeDowngradeHistory].history)
        return OrderedCollections.OrderedDict()
    end

    firm = String[]
    date = Union{Missing,DateTime}[]
    toGrade = Union{Missing,String}[]
    fromGrade = Union{Missing,String}[]
    action = Union{Missing,String}[]
    for i in quoteSummary[:upgradeDowngradeHistory].history
        push!(firm, i.firm)
        push!(date, _no_key_missing(i,:epochGradeDate,nothing,true,true))
        push!(toGrade, _no_key_missing(i,:toGrade))
        push!(fromGrade, _no_key_missing(i,:fromGrade))
        push!(action, _no_key_missing(i,:action))
    end
    res = OrderedCollections.OrderedDict(["firm","date","toGrade","fromGrade","action"] .=> 
               [firm,date,toGrade,fromGrade,action])
    return res
end
get_upgrade_downgrade_history(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_upgrade_downgrade_history