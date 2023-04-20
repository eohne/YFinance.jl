"""
This is an `NewsItem`

# Fields
- title: Title of the news article
- publisher: Publisher of the news 
- link: The link to the news article
- timestamp: The timestamp of the time when the news was published (`DateTime`)
- symbols: An array of the tickers related to the news item
"""
mutable struct NewsItem
    title::String
    publisher::String
    link::String
    timestamp::DateTime
    symbols::Vector{String}
end

"""
This is an `YahooNews <: AbstractArray{NewsItem, N}`

Basically a custom Array of `NewsItem`s
"""
mutable struct YahooNews{NewsItem,N} <: AbstractArray{NewsItem,N}
    arr::Array{NewsItem,N}
end

function Base.size(x::YahooNews)
    return size(x.arr)
end
function Base.getindex(x::YahooNews,i::Int)
    return x.arr[i]
end

"""
    titles(x::YahooNews)

Returns the titles of all `NewsItem`s in a `Vector`

# Arugments:  
   * x::YahooNews

# Returns:  
   * `Vector{String}`

# Example:
```julia
julia> x = search_news("MSFT");

julia> titles(x)
8-element Vector{String}:
 "Microsoft Removes Twitter From Ad Program; Musk Threatens Suit"
 "AI ChatBots Guzzle Water. How and Why It’s a Problem."
 "Best Dow Jones Stocks To Buy And Watch In April: Travelers Surges On Earnings"
 "Top Companies for Financial Strength"
 "VIDEO: Your Top Questions Answe" ⋯ 17 bytes ⋯ "eiling and Portfolio Management"
 "Microsoft agrees to buy \$50m Foxconn parcel in Wisconsin"
 "LinkedIn Reveals Top Workplace:" ⋯ 19 bytes ⋯ "etflix Rank For Happy Employees"
 "Microsoft Working With Space an" ⋯ 24 bytes ⋯ "Blockchain Data for Azure Cloud"
 ```
"""
function titles(x::YahooNews)
    titles = String[]
    for i in 1:length(x)
        push!(titles, x[i].title)
    end
    return titles
end


"""
    links(x::YahooNews)

Returns the links of all `NewsItem`s in a `Vector`

# Arugments:  
    * x::YahooNews

# Returns:  
    * `Vector{String}`

# Example:
```julia
julia> x = search_news("MSFT");

julia> links(x)
8-element Vector{String}:
 "https://finance.yahoo.com/news/" ⋯ 20 bytes ⋯ "itter-ad-program-221121298.html"
 "https://finance.yahoo.com/m/06a" ⋯ 37 bytes ⋯ "chatbots-guzzle-water.-how.html"
 "https://finance.yahoo.com/m/65b" ⋯ 36 bytes ⋯ "st-dow-jones-stocks-to-buy.html"
 "https://finance.yahoo.com/m/9c4" ⋯ 35 bytes ⋯ "op-companies-for-financial.html"
 "https://finance.yahoo.com/m/ebf" ⋯ 35 bytes ⋯ "ideo%3A-your-top-questions.html"
 "https://finance.yahoo.com/news/board-oks-microsoft-data-center-163630944.html"
 "https://finance.yahoo.com/news/" ⋯ 20 bytes ⋯ "-workplace-where-155427039.html"
 "https://finance.yahoo.com/news/microsoft-working-space-time-add-150000132.html"
``` 
"""
function links(x::YahooNews)
    links = String[]
    for i in 1:length(x)
        push!(links, x[i].link)
    end
    return links
end


"""
    timestamps(x::YahooNews)

Returns the timestamp of all `NewsItem`s in a `Vector`

# Arugments:  
    * x::YahooNews

# Returns:  
    * `Vector{DateTime}`

# Example:
```julia
julia> x = search_news("MSFT");

julia> timestamps(x)
8-element Vector{Dates.DateTime}:
 2023-04-19T22:11:21
 2023-04-19T20:33:00
 2023-04-19T18:06:33
 2023-04-19T18:03:00
 2023-04-19T16:46:00
 2023-04-19T16:36:30
 2023-04-19T15:54:27
 2023-04-19T15:00:00
``` 
"""
function timestamps(x::YahooNews)
    timestamps = DateTime[]
    for i in 1:length(x)
        push!(timestamps, x[i].timestamp)
    end
    return timestamps
end
function Base.show(io::IO,x::NewsItem)
    str = join(x.symbols,", ")
    println(io,"Title:\t\t $(x.title)")
    println(io,"Timestamp:\t $(Dates.format(x.timestamp, "u d HH:MM p"))")
    println(io,"Publisher:\t $(x.publisher)")
    println(io,"Link:\t\t $(x.link)")
    println(io,"Symbols:\t $(str)")
end




"""
    search_news(str::String;lang="en-us")

Returns news related to the seach string `str`.

# Arugments:  
   * str`::String`: The search string. It is usually a symbol.
   * lang`::String`: The search language and region. The region is automatically set according to the language. Supported languages are: "en-us", "en-ca", "en-gb", "en-au", "en-nz", "en-SG", "en-in", "de", "es", "fr", "it", "pt-br", "zh", and "zh-tw".

# Returns:  
   * `YahooNews <: AbstractArray` that contains  `NewsItem`s with fields: title`::String`, publisher::String, link::String, timestamp`::DateTime`, symbols`::Array{String,1}`

# Example:
```julia
julia> search_news("MSFT")
8-element YahooNews{NewsItem, 1}:
 Title:          Microsoft Removes Twitter From Ad Program; Musk Threatens Suit
Timestamp:       Apr 19 22:11 PM
Publisher:       Bloomberg
Link:            https://finance.yahoo.com/news/microsoft-removes-twitter-ad-program-221121298.html
Symbols:         MSFT

 Title:          AI ChatBots Guzzle Water. How and Why It’s a Problem.
Timestamp:       Apr 19 20:33 PM
Publisher:       Barrons.com
Link:            https://finance.yahoo.com/m/06a973de-215d-3928-9c99-00867b512966/ai-chatbots-guzzle-water.-how.html
Symbols:         GOOGL, MSFT

 Title:          Best Dow Jones Stocks To Buy And Watch In April: Travelers Surges On Earnings
Timestamp:       Apr 19 18:06 PM
Publisher:       Investor's Business Daily
Link:            https://finance.yahoo.com/m/65b53896-faf4-3a06-9d0d-a63cf3c83192/best-dow-jones-stocks-to-buy.html
Symbols:         ^DJI, MSFT

 Title:          Top Companies for Financial Strength
Timestamp:       Apr 19 18:03 PM
Publisher:       The Wall Street Journal
Link:            https://finance.yahoo.com/m/9c4f6782-7ce7-3e1e-8d0a-ff7f41bc5ef7/top-companies-for-financial.html
Symbols:         XOM, MSFT, AAPL, NUE, MRNA

 Title:          VIDEO: Your Top Questions Answered on the Debt Ceiling and Portfolio Management
Timestamp:       Apr 19 16:46 PM
Publisher:       TheStreet.com
Link:            https://finance.yahoo.com/m/ebf41ba6-6cbc-38ce-93c5-bcee152080e7/video%3A-your-top-questions.html
Symbols:         CHPT, MSFT

 Title:          Microsoft agrees to buy \$50m Foxconn parcel in Wisconsin
Timestamp:       Apr 19 16:36 PM
Publisher:       AP Finance
Link:            https://finance.yahoo.com/news/board-oks-microsoft-data-center-163630944.html
Symbols:         MSFT

 Title:          LinkedIn Reveals Top Workplace: Where Amazon and Netflix Rank For Happy Employees
Timestamp:       Apr 19 15:54 PM
Publisher:       Benzinga
Link:            https://finance.yahoo.com/news/linkedin-reveals-top-workplace-where-155427039.html
Symbols:         AMZN, GOOGL, MSFT, NFLX, WFC

 Title:          Microsoft Working With Space and Time to Add Real-Time Blockchain Data for Azure Cloud
Timestamp:       Apr 19 15:00 PM
Publisher:       CoinDesk
Link:            https://finance.yahoo.com/news/microsoft-working-space-time-add-150000132.html
Symbols:         MSFT
```
"""
function search_news(str::String;lang="en-us")
    lang_opt = Dict(
        "en-us"=>("en-US","US"),
        "en-ca"=>("en-CA","ca"),
        "en-gb"=>("en-GB","GB"),
        "en-au"=>("en-AU","AU"),
        "en-nz"=>("en-NZ","NZ"),
        "en-SG"=>("en-SG","SG"),
        "en-in"=>("en-IN","IN"),
        "de"=>("de-DE","DE"),
        "es"=>("es-ES","ES"),
        "fr"=>("fr-FR","FR"),
        "it"=>("it_IT","IT"),
        "pt-br"=>("pt-BR","BR"),
        "zh"=>("zh-Hant-HK","HK"),
        "zh-tw"=>("zh-TW","TW")
    )
    @assert in(lang, keys(lang_opt)) "Language not supported choose one from: $(join(keys(lang_opt),", "))"
	yfinance_search_link = "https://query2.finance.yahoo.com/v1/finance/search"
	query = Dict("q" => str, "lang"=>lang_opt[lang][1],"region"=>lang_opt[lang][2])
	response = HTTP.get(yfinance_search_link,query = query)
	repsonse_parsed = JSON3.read(response.body).news
    news = NewsItem[]
    for i in repsonse_parsed
        if haskey(i, :relatedTickers)
            push!(news,NewsItem(i.title,i.publisher,i.link,unix2datetime(i.providerPublishTime),i.relatedTickers))
        else
            push!(news,NewsItem(i.title,i.publisher,i.link,unix2datetime(i.providerPublishTime),[]))
        end
    end
	return YahooNews(news)
end