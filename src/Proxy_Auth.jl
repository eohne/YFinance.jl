_PROXY_SETTINGS = (;proxy = nothing,auth = Dict())
"""
    create_proxy_settings(p::AbstractString,user=nothing,password=nothing)

Sets the global proxy variable `_PROXY_SETTINGS::NamedTuple`. This `NamedTuple` contains a `proxy` and a `auth` field. These fields default to `nothing` and and empty `Dict` respectively.

## Arguments

 * p`::String` (Required) of the form: "http://proxy.xyz.com:8080"

 * user`::String` Username (optional) only required if proxy requires authentication. Defaults to `nothing` (no authentication needed)

 * password`::String` The password corresponding to the Username. Defaults to `nothing` (no authentication needed) 

"""
function create_proxy_settings(p::AbstractString,user=nothing,password=nothing)
    if isnothing(user) || isnothing(password)
        global _PROXY_SETTINGS = (;proxy = p,auth = Dict())
    else
        global _PROXY_SETTINGS = (;proxy=p,auth=Dict("Proxy-Authorization" =>  ("Basic " * Base64.base64encode(user * ":" * password)))) 
    end
    return nothing
end



"""
    clear_proxy_settings()

Clears the proxy settings by setting them back to their default (no proxy configuration).    
"""
function clear_proxy_settings()
    global _PROXY_SETTINGS = (;proxy = nothing,auth = Dict())
    return nothing
end
