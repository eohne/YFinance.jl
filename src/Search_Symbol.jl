const MARKETS = ["AMEX", "ARCA", "BATS", "NASDAQ", "NYSE"] # Supported markets

const _SYMDIR = "https://www.nasdaqtrader.com/dynamic/SymDir/"
# Exchange codes used in the "Exchange" column of otherlisted.txt
const _EXCH_CODE = Dict("AMEX" => "A", "NYSE" => "N", "ARCA" => "P", "BATS" => "Z")

# Nasdaq's "NASDAQ Symbol" column uses reserved characters to mark the security
# type, so the mapping to Yahoo's convention is unambiguous. The marker splits the
# base symbol from an optional series suffix, which trails Yahoo's type code
# (e.g. the Noble Tranche 2 warrant NE+A becomes NE-WTA).
const _TYPE_CODE = (('=', "-UN"),    # units:     AAC=   -> AAC-UN
                    ('+', "-WT"),    # warrants:  ACHR+  -> ACHR-WT,  NE+A -> NE-WTA
                    ('^', "-RI"),    # rights:    AIIA^  -> AIIA-RI
                    ('-', "-P"))     # preferred: ABR-D  -> ABR-PD

function _to_yahoo(sym::AbstractString)::String
  for (marker, code) in _TYPE_CODE
    i = findfirst(marker, sym)
    i === nothing && continue
    return sym[1:prevind(sym, i)] * code * sym[nextind(sym, i):end]
  end
  return replace(sym, '.' => '-')                         # classes:   BRK.A  -> BRK-A
end

"""
    get_all_symbols(market::AbstractString; yahoo::Bool=true)::Vector{String}

Fetch all the symbols from a given `market`.

# Arguments
- `market::AbstractString`: The market to fetch the symbols from (case insensitive).
Currently supported markets are:
  - `AMEX` (NYSE American)
  - `ARCA` (NYSE Arca)
  - `BATS` (Cboe BZX)
  - `NASDAQ`
  - `NYSE`

# Keyword Arguments
- `yahoo::Bool`: If `true` (the default) symbols are translated to Yahoo Finance's
  convention (e.g. `BRK.A` becomes `BRK-A`, the preferred share `ABR-D` becomes
  `ABR-PD`, the warrant `ACHR+` becomes `ACHR-WT`, the right `JACS^` becomes
  `JACS-RI`, the unit `AAC=` becomes `AAC-UN`). Set to `false` to get the raw
  exchange symbols instead.

Uses the official Nasdaq Trader symbol directory
(`nasdaqtrader.com/dynamic/SymDir`).

# Returns
- `Vector{String}`: A vector of strings containing the symbols.

# Example
```julia
julia> get_all_symbols("NYSE")
2925-element Vector{String}:
 "A"
 "AA"
 "AAC-UN"
 "AADX"
 ⋮
 "ZTR"
 "ZTS"
 "ZVIA"
 "ZWS"
```
"""
function get_all_symbols(market::AbstractString; yahoo::Bool=true)::Vector{String}
  m = uppercase(String(market))
  m in MARKETS || throw(ArgumentError("Invalid market. Supported markets are $(MARKETS)"))

  file = m == "NASDAQ" ? "nasdaqlisted.txt" : "otherlisted.txt"
  resp = HTTP.get(_SYMDIR * file;
                  retry=true, retries=3,
                  connect_timeout=10, readtimeout=30)

  lines = split(String(resp.body), '\n'; keepempty=false)
  header = split(strip(lines[1]), '|')

  symcol = something(findfirst(==("NASDAQ Symbol"), header),
                     findfirst(==("Symbol"), header))
  testcol = findfirst(==("Test Issue"), header)
  exchcol = findfirst(==("Exchange"), header)  # nothing for nasdaqlisted.txt

  out = String[]
  for ln in @view lines[2:end]
    startswith(ln, "File Creation Time") && continue     # trailing footer line
    f = split(strip(ln), '|')
    length(f) == length(header) || continue
    testcol !== nothing && f[testcol] == "Y" && continue
    exchcol !== nothing && f[exchcol] != _EXCH_CODE[m] && continue
    push!(out, yahoo ? _to_yahoo(f[symcol]) : String(f[symcol]))
  end
  return out
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
