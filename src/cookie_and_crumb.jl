"""
    _rand_header()

Chooses a random header.
"""
function _rand_header()
    return rand(HEADERS)
end;

"""
    get_cookie()

Retrieves cookies from "https://fc.yahoo.com".
"""
function get_cookie()
    res = HTTP.get("https://fc.yahoo.com",cookies=true,redirect=true,_HEADER,status_exception = false)
    cookies = HTTP.cookies(res)
    return Dict(cookies[1].name => cookies[1].value)
end;

"""
    get_crumb(; retries::Int=3, backoff::Real=5.0)

Passes the request header and the cookies to "https://query2.finance.yahoo.com/v1/test/getcrumb" and retrieves the crumb.
If the global _HEADER or _COOKIE variables are not defined they are created.

Yahoo rate limits this endpoint aggressively, and every crumb-dependent function
goes through it. HTTP.jl already retries a 429 a few times, but only over a couple
of seconds, which is rarely long enough. So a 429 is retried up to `retries` further
times, waiting `backoff`, `2backoff`, `4backoff`, ... seconds and drawing a fresh
header and cookie each round. With the defaults that adds up to 35 seconds of
waiting before giving up. If every attempt is rate limited the last
`HTTP.StatusError` is thrown, exactly as it would be without any retrying. Pass
`retries=0` to disable.
"""
function get_crumb(; retries::Int=3, backoff::Real=5.0)
    if (@isdefined _HEADER) && (@isdefined _COOKIE)
        nothing
    else
        _set_cookies_and_crumb()
    end
    for attempt in 0:retries
        try
            crumb = HTTP.get("https://query2.finance.yahoo.com/v1/test/getcrumb",_HEADER,cookies=_COOKIE)
            res = String(crumb.body)
            if isequal(res,"")
                @warn "Crumb could not be retrieved. Certain data items will not be available!"
            end
            return res
        catch e
            # Only a rate limit is worth waiting out, and only while attempts remain.
            (e isa HTTP.StatusError && e.status == 429 && attempt < retries) || rethrow()
            wait_time = backoff * 2^attempt
            @warn "Yahoo rate limited the crumb request (429). Retrying in $(wait_time)s ($(attempt+1)/$(retries))."
            sleep(wait_time)
            # A different header/cookie pair sometimes gets a different answer. If the
            # cookie cannot be renewed either, keep the old one and retry regardless.
            global _HEADER = _rand_header()
            try
                global _COOKIE = get_cookie()
            catch
                nothing
            end
        end
    end
end;

"""
    _renew_cookies_and_crumb(; kwargs...)

Renews both the cookies and the crumb. Keyword arguments are forwarded to
[`get_crumb`](@ref), so the retry budget can be widened.
"""
function _renew_cookies_and_crumb(; kwargs...)
    if @isdefined _HEADER
       global _COOKIE = get_cookie()
       global _CRUMB = get_crumb(; kwargs...)
    else
        global _HEADER = _rand_header()
        global _COOKIE = get_cookie()
        global _CRUMB = get_crumb(; kwargs...)
    end
end;


"""
    _set_cookies_and_crumb(; kwargs...)

Checks if the global _COOKIE and _CRUMB variables are set if not it creates them.

The crumb is fetched at most once per session and reused from then on, so this stays
cheap to call before every request. Keyword arguments are forwarded to
[`get_crumb`](@ref): calling it once up front with a wider budget - for instance
`_set_cookies_and_crumb(retries=4)`, which waits up to 75 seconds - is a way to be
patient once rather than let whichever request happens to come first take the rate
limit. Note the budget compounds, so raising `backoff` as well grows it quickly.
"""
function _set_cookies_and_crumb(; kwargs...)
    if @isdefined _HEADER
        nothing
    else
       global _HEADER = _rand_header()
    end
    if @isdefined _COOKIE
        nothing
    else
        global _COOKIE = get_cookie()
    end
    if @isdefined _CRUMB
        nothing
    else
        global _CRUMB = get_crumb(; kwargs...)
    end
end;
