# Download Quote Summary Data

The quote summary item contains tons of different kinds of information. Not all information is available for all tickers.
The get_quoteSummary function returns all items available for the ticker.

````@docs
get_quoteSummary
````

# Sub-Items

The below functions can extract certain items from the Yahoo quoteSummary. The functions below return Dictionaries that can readily be piped into a DataFrame.
 
## Calendar Events

````@docs
get_calendar_events
````
## Earnings Estimates

````@docs
get_earnings_estimates
````
## Earnings Per Share (EPS)

````@docs
get_eps
````
## Insider Holdings

````@docs
get_insider_holders
````
## Insider Transactions

````@docs
get_insider_transactions
````
## Institutional Ownership

````@docs
get_institutional_ownership
````
## Major Holders Breakdown

````@docs
get_major_holders_breakdown
````
## Analyst Recommendation Trend

````@docs
get_recommendation_trend
````
## Up- & Downgrade History

````@docs
get_upgrade_downgrade_history
````
## Summary Detail

````@docs
get_summary_detail
````
## Sector & Industry

````@docs
get_sector_industry
````
