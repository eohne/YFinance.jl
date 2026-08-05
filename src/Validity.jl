"""
    _symbol_status(symbol::AbstractString)

Internal. Returns the HTTP status code of a minimal chart request for `symbol`.
Errors that never produced a status (connection failure, timeout, ...) are
propagated to the caller.

Only `200` and `404` carry information about the symbol itself. Any other status
means Yahoo declined to answer - most commonly `429` when we are being rate
limited - and says nothing about whether the ticker exists.
"""
function _symbol_status(symbol::AbstractString)
    q = Dict("range"=>"1d", "interval"=>"1d")
    try
        res = HTTP.get("https://query2.finance.yahoo.com/v8/finance/chart/$(symbol)", query = q, proxy=_PROXY_SETTINGS[:proxy],headers=_PROXY_SETTINGS[:auth])
        return Int(res.status)
    catch e
        # Only a StatusError carries a status. Anything else (connection failure,
        # timeout, ...) is propagated, exactly as before: the old code read `e.status`
        # unconditionally and therefore also threw out of this handler.
        e isa HTTP.StatusError || rethrow()
        return Int(e.status)
    end #end try
end #end _symbol_status

"""
    validate_symbol(symbol::AbstractString)

Validates a Symbol (Ticker). Returns `true` if the ticker is valid and `false` if the ticker is not valid.

# Arguments

 * symbol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)

# How it works

Checks if the HTTP request works (status 200) or whether the request errors (common status in this case: 404)

If Yahoo answers with neither 200 nor 404 - for instance 429 when the request is
rate limited - the symbol cannot actually be checked. In that case a warning is
given and `false` is returned, so a `false` under rate limiting does not prove the
ticker is invalid.

"""
function validate_symbol(symbol::AbstractString)
    status = _symbol_status(symbol)
    if status == 200
        return true
    elseif status == 404
        return false
    end #end if
    @warn "$symbol could not be validated: Yahoo answered with status $status. Returning false, but this does not mean the symbol is invalid - please retry later."
    return false
end #end validate_symbol

"""
    get_valid_symbols(symbol::AbstractString)

Takes a symbol. If the symbol is valid it returns the symbol in a vector if not it returns an empty vector.

# Arguments

 * symbol`::AbstractString` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

# Examples

```julia-repl
julia> get_valid_symbols("AAPL")
1-element Vector{String}:
 "AAPL"

julia> get_valid_symbols("asdfs")
 String[]
```

"""
function get_valid_symbols(symbol::AbstractString)
    valid = validate_symbol(symbol)
    return  valid ? [symbol] : String[]
end #end get_valid_symbols


"""
    get_valid_symbols(symbol::AbstractVector{<:AbstractString})

Takes a `AbstractVector` of symbols and returns only the valid ones.

# Arguments

 * symbol`::AbstractVector{<:AbstractString}` is a vector of tickers (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

# Examples

```julia-repl
julia> get_valid_symbols("AAPL","AMD","asdfs")
2-element Vector{String}:
 "AAPL"
 "AMD"
```

"""
function get_valid_symbols(symbol::AbstractVector{<:AbstractString})
    idx = collect(validate_symbol.(symbol))
    return  symbol[idx]
end #end get_valid_symbols
