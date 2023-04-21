# Search for Yahoo Finance Symbols

This package currently provides two ways to get tickers.
   * you know the company/security name but are unsure about the ticker use `get_symbols()`
   * you simply want all tickers listed on the NASDAQ, AMEX, or NYSE use `get_all_symbols()`

## Structs 
The Items returned by `get_symbols`

### YahooSearch
Basically is a custom Array of `YahooSearchItem`s returned by `get_symbols`.

```julia
mutable struct YahooSearch{YahooSearchItem,N} <: AbstractArray{YahooSearchItem,N}
   arr::Array{YahooSearchItem,N}
end
```

### YahooSearchItem
This is an individual search item in `YahooSearch`. It contains the following fields:
- symbol: The Symbol (Ticker)
- shortname: The short name of the instrument/company
- quoteType: The type of asset (e.g. EQUITY)
- sector: The Sector (only if quotetype==EQUITY, otherwise "")
- industry: The Industry (only if quotetype==EQUITY, otherwise "")

```julia
mutable struct YahooSearchItem
   symbol::String
   shortname::String
   exchange::String
   quoteType::String
   sector::String
   industry::String
end
```
## Search Functions

````@docs
get_symbols
get_all_symbols
````
