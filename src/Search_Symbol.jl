const MARKETS = ["AMEX", "NASDAQ", "NYSE", "SZSE"] # Supported markets, Add Shenzhen Stock Exchange

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




# Old Function: 
# function get_symbols(search_term::String)
	
# 	yfinance_search_link = "https://query2.finance.yahoo.com/v1/finance/search"
	
#   # Example of full query:
#   # https://query2.finance.yahoo.com/v1/finance/search?q=microsoft&lang=en-US&region=US&quotesCount=6&newsCount=2&listsCount=2&enableFuzzyQuery=false&quotesQueryId=tss_match_phrase_query&multiQuoteQueryId=multi_quote_single_token_query&newsQueryId=news_cie_vespa&enableCb=true&enableNavLinks=true&enableEnhancedTrivialQuery=true&enableResearchReports=true&researchReportsCount=2
# 	query = Dict("q" => search_term)
	
# 	response = HTTP.get(yfinance_search_link,query = query)
	
# 	repsonse_parsed = JSON3.read(response.body)

# 	quotes = repsonse_parsed.quotes
	
# 	# Also provides news under response_parsed.news
# 	return quotes
# end



"""
This is an `YahooSearchItem`

# Fields
- symbol: The Symbol (Ticker)
- shortname: The short name of the instrument/company
- quoteType: The type of asset (e.g. EQUITY)
- sector: The Sector (only if quotetype==EQUITY, otherwise "")
- industry: The Industry (only if quotetype==EQUITY, otherwise "")
"""
mutable struct YahooSearchItem
   symbol::String
   shortname::String
   exchange::String
   quoteType::String
   sector::String
   industry::String
end

"""
This is an `YahooSearch <: AbstractArray{YahooSearchItem, N}`

Basically a custom Array of `YahooSearchItem`s
"""
mutable struct YahooSearch{YahooSearchItem,N} <: AbstractArray{YahooSearchItem,N}
   arr::Array{YahooSearchItem,N}
end

function Base.size(x::YahooSearch)
   return size(x.arr)
end
function Base.getindex(x::YahooSearch,i::Int)
   return x.arr[i]
end
function Base.show(io::IO,x::YahooSearchItem)
   println(io,"")
   println(io,"Symbol:\t $(x.symbol)")
   println(io,"Name:\t $(x.shortname)")
   println(io,"Type:\t $(x.quoteType)")
   println(io,"Exch.:\t $(x.exchange)")
   if isequal(x.sector,"").==false
       println(io,"Sec.:\t $(x.sector)")
       println(io,"Ind.:\t $(x.industry)")
   end
end

"""
    get_symbols(search_term::String)

Allows searches for specific securities.

# Arguments
   * `search_term::String`: Typically a company/security name (e.g. microsoft)

# Returns
   * A `YahooSearch <: AbstractArray` containing `YahooSearchItem`s containing the following fields: symbol`::String`, shortname`::String`, exchange`::String`, quoteType`::String`, sector`::String`, industry`::String`

# Example 
```julia
julia> get_symbols("micro")
7-element YahooSearch{YahooSearchItem, 1}:
 
Symbol:  MGC=F
Name:    Micro Gold Futures,Jun-2023
Type:    FUTURE
Exch.:   New York Commodity Exchange (CMX)


Symbol:  MSFT
Name:    Microsoft Corporation
Type:    EQUITY
Exch.:   NASDAQ (NMS)
Sec.:    Technology
Ind.:    Software—Infrastructure


Symbol:  AMD
Name:    Advanced Micro Devices, Inc.
Type:    EQUITY
Exch.:   NASDAQ (NMS)
Sec.:    Technology
Ind.:    Semiconductors


Symbol:  MU
Name:    Micron Technology, Inc.
Type:    EQUITY
Exch.:   NASDAQ (NMS)
Sec.:    Technology
Ind.:    Semiconductors


Symbol:  MSTR
Name:    MicroStrategy Incorporated
Type:    EQUITY
Exch.:   NASDAQ (NMS)
Sec.:    Technology
Ind.:    Software—Application


Symbol:  SMCI
Name:    Super Micro Computer, Inc.
Type:    EQUITY
Exch.:   NASDAQ (NMS)
Sec.:    Technology
Ind.:    Computer Hardware


Symbol:  FNGU
Name:    MicroSectors FANG  Index 3X Lev
Type:    ETF
Exch.:   NYSEArca (PCX)
```
"""
function get_symbols(search_term::String)
  yfinance_search_link = "https://query2.finance.yahoo.com/v1/finance/search"
  query = Dict("q" => search_term)
  response = HTTP.get(yfinance_search_link,query = query)
  repsonse_parsed = JSON3.read(response.body).quotes
   quotes = YahooSearchItem[]
   for i in repsonse_parsed
       if haskey(i, :sector)
           push!(quotes,YahooSearchItem(i.symbol,i.shortname,"$(i.exchDisp) ($(i.exchange))",i.quoteType,i.sector,i.industry))
       else
           push!(quotes,YahooSearchItem(i.symbol,i.shortname,"$(i.exchDisp) ($(i.exchange))",i.quoteType,"",""))
       end
   end
  return YahooSearch(quotes)
end
