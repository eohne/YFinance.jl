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
            @warn "$old_symbol is not a valid Symbol an empy Dictionary was returned!" 
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
    
    res = HTTP.get("https://query2.finance.yahoo.com/v10/finance/quoteSummary/$(symbol)",query =q )    
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
Dict{String, Any} with 3 entries:
  "earnings_dates"  => [DateTime("2023-01-25T10:59:00"), DateTime("2023-01-30T12:00:00")]
  "dividend_date"   => DateTime("2022-11-10T00:00:00")
  "exdividend_date" => DateTime("2022-11-04T00:00:00")

julia> get_calendar_events("AAPL")
Dict{String, Any} with 3 entries:
  "earnings_dates"  => [DateTime("2023-01-25T10:59:00"), DateTime("2023-01-30T12:00:00")]
  "dividend_date"   => DateTime("2022-11-10T00:00:00")
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
    res = Dict( "earnings_dates" => unix2datetime.(quoteSummary[:calendarEvents].earnings.earningsDate),
                "dividend_date" => unix2datetime(quoteSummary[:calendarEvents].dividendDate),
                "exdividend_date" =>unix2datetime(quoteSummary[:calendarEvents].exDividendDate)
    )
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
Dict{String, Vector} with 3 entries:
  "quarter"  => ["4Q2021", "1Q2022", "2Q2022", "3Q2022", "4Q2022"]
  "estimate" => [1.89, 1.43, 1.16, 1.27, 2.01]
  "actual"   => Union{Missing, Float64}[2.1, 1.52, 1.2, 1.29, missing]

julia> get_earnings_estimates("AAPL")
Dict{String, Vector} with 3 entries:
  "quarter"  => ["4Q2021", "1Q2022", "2Q2022", "3Q2022", "4Q2022"]
  "estimate" => [1.89, 1.43, 1.16, 1.27, 2.01]
  "actual"   => Union{Missing, Float64}[2.1, 1.52, 1.2, 1.29, missing]

julia> using DataFrames
julia> get_earnings_estimates("AAPL") |> DataFrame
5×3 DataFrame
 Row │ actual      estimate  quarter 
     │ Float64?    Float64   String  
─────┼───────────────────────────────
   1 │       2.1       1.89  4Q2021
   2 │       1.52      1.43  1Q2022
   3 │       1.2       1.16  2Q2022
   4 │       1.29      1.27  3Q2022
   5 │ missing         2.01  4Q2022
```
"""
function get_earnings_estimates(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:earnings)
    @assert in(quote_type,field_types) """Earnings dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:earnings, keys(quoteSummary)) "There are no earnings for this item."
    if isempty(quoteSummary[:earnings].earningsChart.quarterly)
        return Dict()
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
    return Dict(["quarter","estimate","actual"] .=> [quarter,estimate,actual])
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
Dict{String, Vector} with 4 entries:
  "surprise" => [0.111, 0.063, 0.034, 0.016]
  "quarter"  => [DateTime("2021-12-31T00:00:00"), DateTime("2022-03-31T00:00:00"), DateTime("2022-06-30T00:00:00"), DateTime("2022-09-30T00:00:00")]
  "estimate" => [1.89, 1.43, 1.16, 1.27]
  "actual"   => [2.1, 1.52, 1.2, 1.29]

julia> get_eps("AAPL")
Dict{String, Vector} with 4 entries:
  "surprise" => [0.111, 0.063, 0.034, 0.016]
  "quarter"  => [DateTime("2021-12-31T00:00:00"), DateTime("2022-03-31T00:00:00"), DateTime("2022-06-30T00:00:00"), DateTime("2022-09-30T00:00:00")]
  "estimate" => [1.89, 1.43, 1.16, 1.27]
  "actual"   => [2.1, 1.52, 1.2, 1.29]

julia> using DataFrames
julia> get_eps("AAPL") |> DataFrame
4×4 DataFrame
 Row │ actual   estimate  quarter              surprise 
     │ Float64  Float64   DateTime             Float64  
─────┼──────────────────────────────────────────────────
   1 │    2.1       1.89  2021-12-31T00:00:00     0.111
   2 │    1.52      1.43  2022-03-31T00:00:00     0.063
   3 │    1.2       1.16  2022-06-30T00:00:00     0.034
   4 │    1.29      1.27  2022-09-30T00:00:00     0.016
```
"""
function get_eps(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:earningsHistory)
    @assert in(quote_type,field_types) """EPS do not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:earningsHistory, keys(quoteSummary)) "There are no earnings per share for this item."
    if isempty(quoteSummary[:earningsHistory].history)
        return Dict()
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
    return Dict(["quarter","estimate","actual","surprise"] .=> [quarter,estimate,actual,surprise])
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
Dict{String, Vector} with 8 entries:
  "name"                 => ["ADAMS KATHERINE L", "BELL JAMES A", "JUNG AND…
  "lastestTransDate"     => Union{Missing, DateTime}[DateTime("2022-10-03T0…
  "positionDirect"       => Union{Missing, Int64}[427334, 34990, 139594, 31…
  "relation"             => Union{Missing, String}["General Counsel", "Dire…
  "positionIndirect"     => Union{Missing, Int64}[missing, missing, missing…
  "description"          => Union{Missing, String}["Sale", "Stock Gift", "C…
  "positionDirectDate"   => Union{Missing, DateTime}[DateTime("2022-10-03T0…
  "positionIndirectDate" => Union{Missing, DateTime}[missing, missing, miss…

julia> get_insider_holders("AAPL")
Dict{String, Vector} with 8 entries:
  "name"                 => ["ADAMS KATHERINE L", "BELL JAMES A", "JUNG AND…
   "lastestTransDate"     => Union{Missing, DateTime}[DateTime("2022-10-03T0…
   "positionDirect"       => Union{Missing, Int64}[427334, 34990, 139594, 31…
   "relation"             => Union{Missing, String}["General Counsel", "Dire…
   "positionIndirect"     => Union{Missing, Int64}[missing, missing, missing…
   "description"          => Union{Missing, String}["Sale", "Stock Gift", "C…
   "positionDirectDate"   => Union{Missing, DateTime}[DateTime("2022-10-03T0…
   "positionIndirectDate" => Union{Missing, DateTime}[missing, missing, miss…

julia> using DataFrames
julia> get_insider_holders("AAPL") |> DataFrame
10×8 DataFrame
 Row │ description                        lastestTransDate     name        ⋯
     │ String?                            DateTime?            String      ⋯
─────┼──────────────────────────────────────────────────────────────────────
   1 │ Sale                               2022-10-03T00:00:00  ADAMS KATHE ⋯
   2 │ Stock Gift                         2022-05-06T00:00:00  BELL JAMES   
   3 │ Conversion of Exercise of deriva…  2022-02-01T00:00:00  JUNG ANDREA  
   4 │ Sale                               2022-11-22T00:00:00  KONDO CHRIS  
   5 │ Sale                               2022-02-01T00:00:00  LEVINSON AR ⋯
   6 │ Sale                               2022-10-28T00:00:00  MAESTRI LUC  
   7 │ Sale                               2022-10-17T00:00:00  O'BRIEN DEI  
   8 │ Conversion of Exercise of deriva…  2022-02-01T00:00:00  SUGAR RONAL  
   9 │ Conversion of Exercise of deriva…  2022-02-01T00:00:00  WAGNER SUSA ⋯
  10 │ Conversion of Exercise of deriva…  2022-09-30T00:00:00  WILLIAMS JE  
                                                           6 columns omitted
```
"""
function get_insider_holders(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:insiderHolders)
    @assert in(quote_type,field_types) """Insider Holdings dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:insiderHolders, keys(quoteSummary)) "There are is no insiderHolders item."
    if isempty(quoteSummary[:insiderHolders].holders)
        return Dict()
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
    res = Dict(["name","relation","description","lastestTransDate","positionDirect",
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
Dict{String, Vector} with 7 entries:
  "shares"          => Union{Missing, Int64}[20200, 176299, 8053, 13136, 16…
  "filerRelation"   => Union{Missing, String}["Officer", "Chief Financial O…
  "transactionText" => Union{Missing, String}["Sale at price 148.72 per sha…
  "filerName"       => ["KONDO CHRISTOPHER", "MAESTRI LUCA", "O'BRIEN DEIRD…
  "ownership"       => Union{Missing, String}["D", "D", "D", "D", "D", "D",…
  "date"            => Union{Missing, DateTime}[DateTime("2022-11-22T00:00:…
  "value"           => Union{Missing, Int64}[3004144, 27493275, 1147150, mi…

julia> get_insider_transactions("AAPL")
Dict{String, Vector} with 7 entries:
  "shares"          => Union{Missing, Int64}[20200, 176299, 8053, 13136, 16…
  "filerRelation"   => Union{Missing, String}["Officer", "Chief Financial O…
  "transactionText" => Union{Missing, String}["Sale at price 148.72 per sha…
  "filerName"       => ["KONDO CHRISTOPHER", "MAESTRI LUCA", "O'BRIEN DEIRD…
  "ownership"       => Union{Missing, String}["D", "D", "D", "D", "D", "D",…
  "date"            => Union{Missing, DateTime}[DateTime("2022-11-22T00:00:…
  "value"           => Union{Missing, Int64}[3004144, 27493275, 1147150, mi…

julia> using DataFrames
julia> get_insider_transactions("AAPL") |> DataFrame
75×7 DataFrame
 Row │ date                 filerName          filerRelation            ⋯
     │ DateTime?            String             String?                  ⋯
─────┼───────────────────────────────────────────────────────────────────
   1 │ 2022-11-22T00:00:00  KONDO CHRISTOPHER  Officer                  ⋯
   2 │ 2022-10-28T00:00:00  MAESTRI LUCA       Chief Financial Officer   
   3 │ 2022-10-17T00:00:00  O'BRIEN DEIRDRE    Officer
  ⋮  │          ⋮                   ⋮                     ⋮             ⋱
  73 │ 2021-02-01T00:00:00  LOZANO MONICA C.   Director
  74 │ 2021-02-01T00:00:00  GORE ALBERT A JR   Director                 ⋯
  75 │ 2021-02-01T00:00:00  ADAMS KATHERINE L  General Counsel
                                            4 columns and 69 rows omitted
```
"""
function get_insider_transactions(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:insiderTransactions)
    @assert in(quote_type,field_types) """Insider Transactions dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:insiderTransactions, keys(quoteSummary)) "There are is no insiderTransactions item."
    if isempty(quoteSummary[:insiderTransactions].transactions)
        return Dict()
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
    res = Dict(["filerName","filerRelation","transactionText","date","ownership",
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
Dict{String, Vector} with 6 entries:
  "organization" => ["Vanguard Group, Inc. (The)", "Blackrock Inc.", "Be…
  "pctChange"    => Union{Missing, Float64}[-0.0039, -0.0082, 0.0, -0.01…
  "pctHeld"      => Union{Missing, Float64}[0.08, 0.0641, 0.0562, 0.0372…
  "position"     => Union{Missing, Int64}[1272378901, 1020245185, 894802…
  "value"        => Union{Missing, Int64}[180881389225, 145038059235, 12…
  "reportDate"   => Union{Missing, DateTime}[DateTime("2022-09-30T00:00:…

julia> get_institutional_ownership("AAPL")
Dict{String, Vector} with 6 entries:
  "organization" => ["Vanguard Group, Inc. (The)", "Blackrock Inc.", "Be…
  "pctChange"    => Union{Missing, Float64}[-0.0039, -0.0082, 0.0, -0.01…
  "pctHeld"      => Union{Missing, Float64}[0.08, 0.0641, 0.0562, 0.0372…
  "position"     => Union{Missing, Int64}[1272378901, 1020245185, 894802…
  "value"        => Union{Missing, Int64}[180881389225, 145038059235, 12…
  "reportDate"   => Union{Missing, DateTime}[DateTime("2022-09-30T00:00:…

julia> using DataFrames
julia> get_institutional_ownership("AAPL") |> DataFrame
10×6 DataFrame
 Row │ organization                   pctChange  pctHeld   position     ⋯
     │ String                         Float64?   Float64?  Int64?       ⋯
─────┼───────────────────────────────────────────────────────────────────
   1 │ Vanguard Group, Inc. (The)       -0.0039    0.08    1272378901   ⋯
   2 │ Blackrock Inc.                   -0.0082    0.0641  1020245185    
   3 │ Berkshire Hathaway, Inc           0.0       0.0562   894802319    
  ⋮  │               ⋮                    ⋮         ⋮          ⋮        ⋱
   8 │ Morgan Stanley                    0.0015    0.0115   182728771    
   9 │ Northern Trust Corporation       -0.0208    0.0111   176084862   ⋯
  10 │ Bank of America Corporation      -0.0461    0.0089   142260591    
                                             2 columns and 4 rows omitted
```
"""
function get_institutional_ownership(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:institutionOwnership)
    @assert in(quote_type,field_types) """Institutional Ownership does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:institutionOwnership, keys(quoteSummary)) "There are is no institutionOwnership item."
    if isempty(quoteSummary[:institutionOwnership].ownershipList)
        return Dict()
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
    res = Dict(["organization","reportDate","pctHeld","position","value",
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
Dict{String, Real} with 4 entries:
  "institutionsCount"            => 5525
  "insidersPercentHeld"          => 0.00072
  "institutionsFloatPercentHeld" => 0.60065
  "institutionsPercentHeld"      => 0.60021

julia> get_major_holders_breakdown("AAPL")
Dict{String, Real} with 4 entries:
  "institutionsCount"            => 5525
  "insidersPercentHeld"          => 0.00072
  "institutionsFloatPercentHeld" => 0.60065
  "institutionsPercentHeld"      => 0.60021
```
"""
function get_major_holders_breakdown(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:majorHoldersBreakdown)
    @assert in(quote_type,field_types) """The breadkown of major holders does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:majorHoldersBreakdown, keys(quoteSummary)) "There are is no majorHoldersBreakdown item."
    result = Dict(String(k) => v for (k , v) in quoteSummary.majorHoldersBreakdown)
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
Dict{String, Vector} with 6 entries:
  "strongbuy"  => [11, 11, 13, 13]
  "sell"       => [0, 1, 1, 0]
  "buy"        => [21, 26, 25, 20]
  "period"     => ["0m", "-1m", "-2m", "-3m"]
  "hold"       => [6, 5, 6, 8]
  "strongsell" => [0, 0, 0, 0]

julia> get_recommendation_trend("AAPL")
Dict{String, Vector} with 6 entries:
  "strongbuy"  => [11, 11, 13, 13]
  "sell"       => [0, 1, 1, 0]
  "buy"        => [21, 26, 25, 20]
  "period"     => ["0m", "-1m", "-2m", "-3m"]
  "hold"       => [6, 5, 6, 8]
  "strongsell" => [0, 0, 0, 0]
  
julia> using DataFrames
julia> get_recommendation_trend("AAPL") |> DataFrame
4×6 DataFrame
 Row │ buy    hold   period  sell   strongbuy  strongsell 
     │ Int64  Int64  String  Int64  Int64      Int64      
─────┼────────────────────────────────────────────────────
   1 │    21      6  0m          0         11           0
   2 │    26      5  -1m         1         11           0
   3 │    25      6  -2m         1         13           0
   4 │    20      8  -3m         0         13           0
```
"""
function get_recommendation_trend(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:recommendationTrend)
    @assert in(quote_type,field_types) """The recommendation trend does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:recommendationTrend, keys(quoteSummary)) "There are is no recommendationTrend item."
    if isempty(quoteSummary[:recommendationTrend].trend)
        return Dict()
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
    res = Dict(["period","strongbuy","buy","hold","sell",
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
Dict{String, Any} with 41 entries:
  "tradeable"                  => false
  "dayLow"                     => 140.91
  "coinMarketCapLink"          => nothing
  "priceHint"                  => 2
  "regularMarketPreviousClose" => 142.65
  "askSize"                    => 900
  ⋮                            => ⋮

julia> get_summary_detail("AAPL")
Dict{String, Any} with 41 entries:
  "tradeable"                  => false
  "dayLow"                     => 140.91
  "coinMarketCapLink"          => nothing
  "priceHint"                  => 2
  "regularMarketPreviousClose" => 142.65
  "askSize"                    => 900
  ⋮                            => ⋮
```
"""
function get_summary_detail(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:summaryDetail)
    @assert in(quote_type,field_types) """Summary details dont exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:summaryDetail, keys(quoteSummary)) "There are is no summaryDetail item."
    result = Dict(String(k) => v for (k , v) in quoteSummary.summaryDetail)
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
julia> get_get_quoteSummary("AAPL") |> sector_industry
Dict{String, String} with 2 entries:
  "industry" => "Consumer Electronics"
  "sector"   => "Technology"

julia> get_sector_industry("AAPL")
Dict{String, String} with 2 entries:
  "industry" => "Consumer Electronics"
  "sector"   => "Technology"
```
"""
function get_sector_industry(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:summaryProfile)
    @assert in(quote_type,field_types) """The summary profile does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    result = Dict("sector" =>quoteSummary.summaryProfile.sector, "industry"=>quoteSummary.summaryProfile.industry)
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
Dict{String, Vector} with 5 entries:
  "firm"      => ["UBS", "Morgan Stanley", "B of A Securities", "Barclay…
  "action"    => Union{Missing, String}["main", "main", "main", "main", …
  "fromGrade" => Union{Missing, String}["", "", "", "", "", "", "", "", …
  "date"      => Union{Missing, DateTime}[DateTime("2022-11-08T12:17:03"…
  "toGrade"   => Union{Missing, String}["Buy", "Overweight", "Neutral", …

julia> get_upgrade_downgrade_history("AAPL")
Dict{String, Vector} with 5 entries:
  "firm"      => ["UBS", "Morgan Stanley", "B of A Securities", "Barclay…
  "action"    => Union{Missing, String}["main", "main", "main", "main", …
  "fromGrade" => Union{Missing, String}["", "", "", "", "", "", "", "", …
  "date"      => Union{Missing, DateTime}[DateTime("2022-11-08T12:17:03"…
  "toGrade"   => Union{Missing, String}["Buy", "Overweight", "Neutral", …
  
julia> using DataFrames
julia> get_upgrade_downgrade_history("AAPL") |> DataFrame
871×5 DataFrame
 Row │ action   date                 firm               fromGrade  toGr ⋯
     │ String?  DateTime?            String             String?    Stri ⋯
─────┼───────────────────────────────────────────────────────────────────
   1 │ main     2022-11-08T12:17:03  UBS                           Buy  ⋯
   2 │ main     2022-11-08T12:14:23  Morgan Stanley                Over  
   3 │ main     2022-11-07T13:08:30  B of A Securities             Neut  
  ⋮  │    ⋮              ⋮                   ⋮              ⋮           ⋱
 870 │ main     2012-03-08T07:33:00  FBN Securities                Outp  
 871 │ main     2012-02-09T08:17:00  Canaccord Genuity             Buy  ⋯
                                             1 column and 866 rows omitted
```
"""
function get_upgrade_downgrade_history(quoteSummary::JSON3.Object)
    quote_type = _quote_type(quoteSummary)
    field_types = _check_field_quotetype(:upgradeDowngradeHistory)
    @assert in(quote_type,field_types) """The history of up- and downgrades does not exist for $(quote_type) items only for $(join(field_types,", "))""" 
    @assert in(:upgradeDowngradeHistory, keys(quoteSummary)) "There are is no upgradeDowngradeHistory item."
    if isempty(quoteSummary[:upgradeDowngradeHistory].history)
        return Dict()
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
    res = Dict(["firm","date","toGrade","fromGrade","action"] .=> 
               [firm,date,toGrade,fromGrade,action])
    return res
end
get_upgrade_downgrade_history(symbol::AbstractString) =  get_quoteSummary(symbol) |> get_upgrade_downgrade_history