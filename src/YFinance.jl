module YFinance
    
    using Base64 # Required for Authentication
    using OrderedCollections # Required for ordered Dictionary Output. No reordering needed if converting to Tables
    using Dates
    using HTTP
    using JSON3
    using Random

    export _PROXY_SETTINGS, create_proxy_settings,clear_proxy_settings, _set_cookies_and_crumb
    export validate_symbol,get_valid_symbols,get_prices, get_dividends, get_splits
    export _QuoteSummary_Items,get_quoteSummary
    export _Fundamental_Types, _Fundamental_Intervals,get_Fundamental,get_Options,get_ESG
    export get_calendar_events,get_earnings_estimates,get_eps,get_insider_holders,get_insider_transactions
    export get_institutional_ownership,get_major_holders_breakdown,get_recommendation_trend
    export get_summary_detail,get_sector_industry,get_upgrade_downgrade_history
    export get_all_symbols, get_symbols, YahooSearch, YahooSearchItem
    export NewsItem, YahooNews, titles, links, timestamps, search_news
    export sink_prices_to

    #Re Exports from Base:
    export size, getindex, show

    # Load Order
    include("headers.jl");
    include("cookie_and_crumb.jl");
    include("Proxy_Auth.jl");
    include("Validity.jl");
    include("Prices.jl");
    include("QuoteSummary.jl");
    include("Fundamental.jl");
    include("Options.jl");
    include("ESG.jl");
    include("Search_Symbol.jl");
    include("News_Search.jl");
end