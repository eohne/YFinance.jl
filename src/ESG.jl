"""
    get_ESG(symbol::String)

Retrievs ESG Scores from Yahoo Finance stored in a OrderedCollections.OrderedDict with two items. One, `score`, contains the companies ESG scores and individal Overall, Environment, Social and  Goverance Scores as well as a timestamp of type `DateTime`.
The other,  `peer_score`, contains the peer group's scores. The subdictionaries can be transformed to `DataFrames`

# Arguments

 * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

 *  throw_error`::Bool` defaults to `false`. If set to true the function errors when the ticker is not valid. Else a warning is given and an empty OrderedCollections.OrderedDict is returned.

# Examples
```julia-repl
julia> get_ESG("AAPL")
OrderedDict{String, OrderedDict{String, Any}} with 2 entries:
  "score"      => OrderedDict("symbol"=>"AAPL", "timestamp"=>[DateTime("2014-09-01T00:00:…
  "peer_score" => OrderedDict("symbol"=>"Technology Hardware", "timestamp"=>[DateTime("20…

julia> using DataFrames
julia> get_ESG("AAPL")["score"] |> DataFrame
96×6 DataFrame
 Row │ symbol  timestamp            esgScore    governanceScore  environmentScore  socialScore 
     │ String  DateTime             Real?       Real?            Real?             Real?       
─────┼─────────────────────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2014-09-01T00:00:00       61               62                74           45
   2 │ AAPL    2014-10-01T00:00:00       60               62                74           45
   3 │ AAPL    2014-11-01T00:00:00       61               62                74           45
  ⋮  │   ⋮              ⋮               ⋮              ⋮                ⋮               ⋮
  95 │ AAPL    2022-07-01T00:00:00  missing          missing           missing      missing    
  96 │ AAPL    2022-08-01T00:00:00       16.68             9.18              0.65         6.86
                                                                                91 rows omitted
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
             @warn "$old_symbol is not a valid Symbol an empy OrderedCollections.OrderedDict was returned!" 
             return OrderedCollections.OrderedDict()
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
    res = HTTP.get("https://query2.finance.yahoo.com/v1/finance/esgChart",query =q, proxy=_PROXY_SETTINGS[:proxy],headers=_PROXY_SETTINGS[:auth])   
    res = JSON3.read(res.body)
    res = res.esgChart.result[1]
    self = OrderedCollections.OrderedDict(
        "symbol" => symbol,
        "timestamp"=>unix2datetime.(res.symbolSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.symbolSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.symbolSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.symbolSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.symbolSeries.socialScore))
    peers = OrderedCollections.OrderedDict(
        "symbol" => res.peerGroup,
        "timestamp"=>unix2datetime.(res.peerSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.peerSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.peerSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.peerSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.peerSeries.socialScore))
    return OrderedCollections.OrderedDict("score" =>self,"peer_score"=>peers)
end

# #Maybe implement in the future
# "esg_peer_scores"
#     url "https://query2.finance.yahoo.com/v1/finance/esgPeerScores"
#      query symbol