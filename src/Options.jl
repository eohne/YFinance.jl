"""
    get_Options(symbol::String)

Retrievs options data from Yahoo Finance stored in a OrderedCollections.OrderedDict with two items. One contains Call options the other Put options. These subitems are OrderedCollections.OrderedDict themselves.
The call and put options OrderedCollections.OrderedDict can readily be transformed to a DataFrame.

# Arguments

 * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty OrderedCollections.OrderedDict is returned.

# Examples  
```julia-repl
julia> get_Options("AAPL")
OrderedDict{String, OrderedDict{String, Vector{Any}}} with 2 entries:
  "calls" => OrderedDict("contractSymbol"=>["AAPL221230C00050000", "AAPL221230C00055000",…
  "puts"  => OrderedDict("contractSymbol"=>["AAPL221230P00050000", "AAPL221230P00055000",…

julia> using DataFrames
julia> get_Options("AAPL")["calls"] |> DataFrame
72×16 DataFrame
 Row │ contractSymbol       strike  currency  lastPrice  change  percentChange  volume   ⋯
     │ Any                  Any     Any       Any        Any     Any            Any      ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ AAPL221230C00050000  50      USD       79.85      0       0              1        ⋯
   2 │ AAPL221230C00055000  55      USD       72.85      0       0              1
   3 │ AAPL221230C00060000  60      USD       66.4       0       0              19        
  ⋮  │          ⋮             ⋮        ⋮          ⋮        ⋮           ⋮           ⋮     ⋱
  71 │ AAPL221230C00230000  230     USD       0.02       0       0              missing   
  72 │ AAPL221230C00250000  250     USD       0.01       0       0              2        ⋯
                                                             9 columns and 67 rows omitted

julia> using DataFrames
julia> data  = get_Options("AAPL");
julia> vcat( [DataFrame(i) for i in values(data)]...)
141×16 DataFrame
 Row │ contractSymbol       strike  currency  lastPrice  change  percentChange  volume   ⋯
     │ Any                  Any     Any       Any        Any     Any            Any      ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ AAPL221230C00050000  50      USD       79.85      0       0              1        ⋯
   2 │ AAPL221230C00055000  55      USD       72.85      0       0              1
   3 │ AAPL221230C00060000  60      USD       66.4       0       0              19        
  ⋮  │          ⋮             ⋮        ⋮          ⋮        ⋮           ⋮          ⋮      ⋱
 140 │ AAPL221230P00225000  225     USD       94.65      0       0              1
 141 │ AAPL221230P00230000  230     USD       99.65      0       0              1        ⋯
                                                            9 columns and 136 rows omitted
```
"""
function get_Options(symbol::String;throw_error=false)
    _set_cookies_and_crumb()
    if isequal(_CRUMB,"")
        @warn "This item requires a crumb but a crumb could not be successfully retrieved!"
        return nothing
    end

     # Check if symbol is valid
     old_symbol = symbol
     symbol = get_valid_symbols(symbol)
     if isempty(symbol)
         if throw_error
             error("$old_symbol is not a valid Symbol!")
         else
             @warn "$old_symbol is not a valid Symbol an empy OrderedCollections.OrderedDict was returned!" 
             return OrderedCollections.OrderedDict()
         end
     else
         symbol = symbol[1]
     end
     # Could add "date" to query to get only for certain expiration date.
    res = HTTP.get("https://query2.finance.yahoo.com/v7/finance/options/$(symbol)",query = Dict("formatted"=>"false","crumb"=>_CRUMB), proxy=_PROXY_SETTINGS[:proxy],headers=merge(_PROXY_SETTINGS[:auth],_HEADER),cookies=_COOKIE)    
    res = JSON3.read(res.body)
    puts = res.optionChain.result[1].options[1].puts
    calls = res.optionChain.result[1].options[1].calls
    res_p = OrderedCollections.OrderedDict(
        "contractSymbol"=> [],
        "strike"=> [],
        "currency"=> [],
        "lastPrice"=> [],
        "change"=> [],
        "percentChange"=> [],
        "volume"=> [],
        "openInterest"=> [],
        "bid"=> [],
        "ask"=> [],
        "contractSize"=> [],
        "expiration"=> [],
        "lastTradeDate"=> [],
        "impliedVolatility"=> [],
        "inTheMoney"=> []
        )
    res_c = OrderedCollections.OrderedDict(
        "contractSymbol"=> [],
        "strike"=> [],
        "currency"=> [],
        "lastPrice"=> [],
        "change"=> [],
        "percentChange"=> [],
        "volume"=> [],
        "openInterest"=> [],
        "bid"=> [],
        "ask"=> [],
        "contractSize"=> [],
        "expiration"=> [],
        "lastTradeDate"=> [],
        "impliedVolatility"=> [],
        "inTheMoney"=> []
        )

    for i in eachindex(puts)
        for j in keys(res_p)
            if !in(j, keys(puts[i]))
                push!(res_p[j], missing)
            else
                if in(j, ["expiration","lastTradeDate"])
                push!(res_p[j], unix2datetime(puts[i][j]))
                else
                    push!(res_p[j], puts[i][j])
                end
            end
        end
    end
    for i in eachindex(calls)
        for j in keys(res_c)
            if !in(j, keys(calls[i]))
                push!(res_c[j], missing)
            else
                if in(j, ["expiration","lastTradeDate"])
                    push!(res_c[j], unix2datetime(calls[i][j]))
                    else
                        push!(res_c[j], calls[i][j])
                    end
            end
        end
    end
    res_c["type"] = repeat(["call"], length(res_c["strike"]))
    res_p["type"] = repeat(["put"], length(res_p["strike"]))
    return OrderedCollections.OrderedDict("calls" => res_c, "puts" => res_p)
end

