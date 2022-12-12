"""
    get_ESG(symbol::String)

Retrievs ESG Scores from Yahoo Finance stored in a Dictionary with two items. One, `score`, contains the companies ESG scores and individal Overall, Environment, Social and  Goverance Scores as well as a timestamp of type `DateTime`.
The other,  `peer_score`, contains the peer group's scores. The subdictionaries can be transformed to `DataFrames`

# Arguments

 * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty dictionary is returned.

# Examples
```julia-repl
julia> get_ESG("AAPL")
Dict{String, Dict{String, Any}} with 2 entries:
"peer_score" => Dict("governanceScore"=>Union{Missing, Float64}[63.2545, 63.454…  
"score"      => Dict("governanceScore"=>Union{Missing, Real}[62, 62, 62, 62, 62… 

julia> using DataFrames
julia> get_ESG("AAPL")["score"] |> DataFrame
96×6 DataFrame
Row │ environmentScore  esgScore    governanceScore  socialScore  symbol  times ⋯
    │ Real?             Real?       Real?            Real?        String  DateT ⋯
────┼────────────────────────────────────────────────────────────────────────────
  1 │            74          61               62           45     AAPL    2014- ⋯
  2 │            74          60               62           45     AAPL    2014-  
 ⋮  │        ⋮              ⋮              ⋮              ⋮         ⋮           ⋱
 95 │       missing     missing          missing      missing     AAPL    2022-  
 96 │             0.65       16.68             9.18         6.86  AAPL    2022-  
                                                        1 column and 92 rows omitted
```
"""
function get_ESG(symbol::String;throw_error=false)

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

    q = Dict("symbol" =>symbol)
    function nothingtomissing(x::Any)
        return x
    end
    function nothingtomissing(x::Nothing)
        return missing
    end    
    res = HTTP.get("https://query2.finance.yahoo.com/v1/finance/esgChart",query =q )   
    res = JSON3.read(res.body)
    res = res.esgChart.result[1]
    self = Dict(
        "symbol" => symbol,
        "timestamp"=>unix2datetime.(res.symbolSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.symbolSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.symbolSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.symbolSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.symbolSeries.socialScore))
    peers = Dict(
        "symbol" => res.peerGroup,
        "timestamp"=>unix2datetime.(res.peerSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.peerSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.peerSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.peerSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.peerSeries.socialScore))
    return Dict("score" =>self,"peer_score"=>peers)
end

# #Maybe implement in the future
# "esg_peer_scores"
#     url "https://query2.finance.yahoo.com/v1/finance/esgPeerScores"
#      query symbol