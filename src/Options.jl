"""
    get_Options(symbol::String)

Retrievs options data from Yahoo Finance stored in a Dictionary with two items. One contains Call options the other Put options. These subitems are dictionaries themselves.
The call and put options Dictionaries can readily be transformed to a DataFrame.

# Arguments

 * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty dictionary is returned.

# Examples  
```julia-repl
julia> get_Options("AAPL")
Dict{String, Dict{String, Vector{Any}}} with 2 entries:
"calls" => Dict("percentChange"=>[ -2.90804  …   0], "expiration"=>[DateTime("2022-12-09T00:…  
"puts"  => Dict("percentChange"=>[0,  …   0], "expiration"=>[DateTime("2022-12-09T00:00:00"), DateTime("20…

julia> using DataFrames
julia> get_Options("AAPL")["calls"] |> DataFrame
65×16 DataFrame
Row │ ask    bid    change     contractSize  contractSymbol       currency  exp ⋯
    │ Any    Any    Any        Any           Any                  Any       Any ⋯
────┼────────────────────────────────────────────────────────────────────────────
    1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD       202 ⋯
    2 │ 84.3   84.15  0          REGULAR       AAPL221209C00060000  USD       202  
    ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮              ⋮          ⋱  
    64 │ 0.01   0      0          REGULAR       AAPL221209C00240000  USD       202  
    65 │ 0      0      0          REGULAR       AAPL221209C00250000  USD       202  
                                                    10 columns and 61 rows omitted

julia> using DataFrames
julia> data  = get_Options("AAPL")
julia> vcat( [DataFrame(i) for i in values(data)]...)
124×16 DataFrame
Row │ ask    bid    change     contractSize  contractSymbol       cur ⋯
    │ Any    Any    Any        Any           Any                  Any ⋯
────┼──────────────────────────────────────────────────────────────────
    1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD ⋯
    2 │ 84.55  84.35  0          REGULAR       AAPL221209C00060000  USD  
    ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮               ⋱ 
123 │ 75.85  75.15  0          REGULAR       AAPL221209P00220000  USD  
124 │ 85.85  85.15  0          REGULAR       AAPL221209P00230000  USD  
                                        11 columns and 120 rows omitted
```
"""
function get_Options(symbol::String;throw_error=false)

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

    res = HTTP.get("https://query2.finance.yahoo.com/v7/finance/options/$(symbol)",query = Dict("formatted"=>"false"))    
    res = JSON3.read(res.body)
    puts = res.optionChain.result[1].options[1].puts
    calls = res.optionChain.result[1].options[1].calls
    res_p = Dict(
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
    res_c = Dict(
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
    return Dict("calls" => res_c, "puts" => res_p)
end

