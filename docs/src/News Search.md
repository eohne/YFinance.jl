# Search for News
Allows for the search of relevant news to the search term. The search term is typically a symbol (ticker) but can also be a company name (or parts of a company name).

# Structs:
````@docs
NewsItem
YahooNews
````
# Convenience Functions
Allows of accessing all titles, links, and timestamps stored in arrays directly from the YahooNews item. 
````@docs
titles
links
timestamps
````
# News Search Function
````@docs
search_news
````