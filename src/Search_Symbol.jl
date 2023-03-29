const MARKETS = ["AMEX", "NASDAQ", "NYSE"] # Supported markets

"""
    get_all_symbols(market::T)::Vector{T} where {T<:String}

Fetch all the symbols from a given `market`.

# Arguments
- `market::String`: The market to fetch the symbols from.
Currently supported markets are:
  - `AMEX`
  - `NASDAQ`
  - `NYSE`  

Uses dumbstockapi.com

# Returns
- `Vector{String}`: A vector of strings containing the symbols.

# Example
```julia
julia> get_all_symbols("NYSE")
3127-element Vector{String}:
 "A"
 "AA"
 "AAC"
 "AAN"
 ⋮
 "ZTR"
 "ZTS"
 "ZUO"
 "ZYME"
```
"""
function get_all_symbols(market::T)::Vector{T} where {T<:String}
  uppercase(market) in MARKETS || throw(ArgumentError("Invalid market. Supported markets are $(MARKETS)"))
  url = "https://dumbstockapi.com/stock?format=tickers-only&exchange=$market"
  response = HTTP.request("GET", url)
  Symbols_string::T = String(response.body)
  splitted::Vector{T} = split(Symbols_string, ",")
  pured::Vector{T} = replace.(splitted, r"\"" => "")
  f_idx, l_idx = firstindex(pured), lastindex(pured)
  pured[f_idx] = replace(pured[f_idx], r"\[" => "")
  pured[l_idx] = replace(pured[l_idx], r"\]" => "")
  return pured
end;




"""
    get_symbols(search_term::String)

Allows searches for specific securities.

# Arguments
   * `search_term::String`: Typically a company/security name (e.g. microsoft)

# Returns
   * `JSON3.Array{JSON3.Object}`: Each array element is a `JSON3.Object` search results contiangint the following keys:
     - exchange, shortname, quoteType, symbol, index, score, typeDisp, longname, exchDisp, isYahooFinance
   * If no match was found an empty `JSON3.Array` is returned.

# Example 
```julia
julia> get_symbols("micro")
7-element JSON3.Array{JSON3.Object, Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}}:
 {
         "exchange": "CMX",
        "shortname": "Micro Gold Futures,Jun-2023",
        "quoteType": "FUTURE",
           "symbol": "MGC=F",
            "index": "quotes",
            "score": 3179100,
         "typeDisp": "Future",
         "exchDisp": "New York Commodity Exchange",
   "isYahooFinance": true
}
 {
         "exchange": "NMS",
        "shortname": "Microsoft Corporation",
        "quoteType": "EQUITY",
           "symbol": "MSFT",
            "index": "quotes",
            "score": 274384,
         "typeDisp": "Equity",
         "longname": "Microsoft Corporation",
         "exchDisp": "NASDAQ",
           "sector": "Technology",
         "industry": "Software—Infrastructure",
   "isYahooFinance": true
}
 {
         "exchange": "NMS",
        "shortname": "Micron Technology, Inc.",
        "quoteType": "EQUITY",
           "symbol": "MU",
            "index": "quotes",
            "score": 265579,
         "typeDisp": "Equity",
         "longname": "Micron Technology, Inc.",
         "exchDisp": "NASDAQ",
           "sector": "Technology",
         "industry": "Semiconductors",
   "isYahooFinance": true
}
 {
         "exchange": "NMS",
        "shortname": "Advanced Micro Devices, Inc.",
        "quoteType": "EQUITY",
           "symbol": "AMD",
            "index": "quotes",
            "score": 252946,
         "typeDisp": "Equity",
         "longname": "Advanced Micro Devices, Inc.",
         "exchDisp": "NASDAQ",
           "sector": "Technology",
         "industry": "Semiconductors",
   "isYahooFinance": true
}
 {
         "exchange": "NMS",
        "shortname": "MicroStrategy Incorporated",
        "quoteType": "EQUITY",
           "symbol": "MSTR",
            "index": "quotes",
            "score": 52264,
         "typeDisp": "Equity",
         "longname": "MicroStrategy Incorporated",
         "exchDisp": "NASDAQ",
           "sector": "Technology",
         "industry": "Software—Application",
   "isYahooFinance": true
}
 {
         "exchange": "NMS",
        "shortname": "Super Micro Computer, Inc.",
        "quoteType": "EQUITY",
           "symbol": "SMCI",
            "index": "quotes",
            "score": 38924,
         "typeDisp": "Equity",
         "longname": "Super Micro Computer, Inc.",
         "exchDisp": "NASDAQ",
           "sector": "Technology",
         "industry": "Computer Hardware",
   "isYahooFinance": true
}
 {
         "exchange": "PCX",
        "shortname": "MicroSectors FANG  Index 3X Lev",
        "quoteType": "ETF",
           "symbol": "FNGU",
            "index": "quotes",
            "score": 33432,
         "typeDisp": "ETF",
         "longname": "MicroSectors FANG+ Index 3X Leveraged ETN",
         "exchDisp": "NYSEArca",
   "isYahooFinance": true
}
```
"""
function get_symbols(search_term::String)
	
	yfinance_search_link = "https://query2.finance.yahoo.com/v1/finance/search"
	
  # Example of full query:
  # https://query2.finance.yahoo.com/v1/finance/search?q=microsoft&lang=en-US&region=US&quotesCount=6&newsCount=2&listsCount=2&enableFuzzyQuery=false&quotesQueryId=tss_match_phrase_query&multiQuoteQueryId=multi_quote_single_token_query&newsQueryId=news_cie_vespa&enableCb=true&enableNavLinks=true&enableEnhancedTrivialQuery=true&enableResearchReports=true&researchReportsCount=2
	query = Dict("q" => search_term)
	
	response = HTTP.get(yfinance_search_link,query = query)
	
	repsonse_parsed = JSON3.read(response.body)

	quotes = repsonse_parsed.quotes
	
	# Also provides news under response_parsed.news
	return quotes
end