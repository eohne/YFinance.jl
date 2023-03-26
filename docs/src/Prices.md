# Download Price Data

This function returns open, high, low, close, and adjusted close prices as well as volume.  

For a few stocks yahoo finance will return `nothing` for specific timestamps in the price series.  

For performance reasons and easier integration with `TimeSeries.jl` these `nothing` values are returned as `NaN`s. Some other packages like python's `yahooquery` do not return these datapoints at all. We decided to return them to indicate a break in the series and to indicate that Yahoo Finance thinks it should have price information for the specific timestamp but does not have any.   

````@docs
get_prices
````
