# Supported markets
const MARKETS = ["AMEX", "NASDAQ", "NYSE"]

"""
    get_symbols(market::String)

Fetch all the symbols from a given `market`.

# Arguments
- `market::String`: The market to fetch the symbols from.
Currently supported markets are:
  - `AMEX`
  - `NASDAQ`
  - `NYSE`

# Returns
- `Vector{String}`: A vector of strings containing the symbols.

# Example
```julia
julia> get_symbols("NYSE")
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
"""
function get_symbols(market::String)::Vector{String}
  uppercase(market) in MARKETS || throw(ArgumentError("Invalid market. Supported markets \
  are $(MARKETS)"))
  url = "https://dumbstockapi.com/stock?format=tickers-only&exchange=$market"
  response = HTTP.request("GET", url)
  Symbols_string::String = String(response.body)
  splitted::Vector{String} = split(Symbols_string, ",")
  pured::Vector{String} = replace.(splitted, r"\"" => "")
  pured[1] = replace(pured[1], r"\[" => "")
  pured[lastindex(pured)] = replace(pured[lastindex(pured)], r"\]" => "")
  return pured
end;
