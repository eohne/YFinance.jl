# Search for News
Allows for the search of relevant news to the search term. The search term is typically a symbol (ticker) but can also be a company name (or parts of a company name).

## Structs:
The structs returned by `search_news`

### YahooNews
Basically a custom Array of `NewsItem`s returned by `search_news`

```julia
mutable struct YahooNews{NewsItem,N} <: AbstractArray{NewsItem,N}
    arr::Array{NewsItem,N}
end
```

### NewsItem
Is an individual news item contained in `YahooNews` contains the following fields:
- title: Title of the news article
- publisher: Publisher of the news 
- link: The link to the news article
- timestamp: The timestamp of the time when the news was published (`DateTime`)
- symbols: An array of the tickers related to the news item

```julia
mutable struct NewsItem
    title::String
    publisher::String
    link::String
    timestamp::DateTime
    symbols::Vector{String}
end
```

### Convenience Functions
Allows of accessing all titles, links, and timestamps stored in arrays directly from the YahooNews item. 
````@docs
titles
links
timestamps
````
## News Search Function
````@docs
search_news
````