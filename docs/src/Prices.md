# Download Price Data

This function returns open, high, low, close, and adjusted close prices as well as volume.  

For a few stocks yahoo finance will return `nothing` for specific timestamps in the price series.  

For performance reasons and easier integration with `TimeSeries.jl` these `nothing` values are returned as `NaN`s. Some other packages like python's `yahooquery` do not return these datapoints at all. We decided to return them to indicate a break in the series and to indicate that Yahoo Finance thinks it should have price information for the specific timestamp but does not have any.   

````@docs
get_prices
````
<!-- ````@docs
get_prices(::AbstractString;::AbstractString,::AbstractString,::Any,::Any,::Any,::Any,::Any,::Any,::Any,::Any)
```` -->

## Optional Sink Argument (Julia 1.9+)

For Julia versions 1.9+ optional sink arguments can be given as the first argument.
If you want to return a TimeArray from TimeSeries.jl execute `get_prices(TimeArray,syombol,...)`. If you want to return a TSFrame from TSFrames.jl execute `get_prices(TSFrame,syombol,...)`.

<!-- ````@docs
get_prices(::Type{TSFrame},::String;::AbstractString,::AbstractString,::Any, ::Any,::Any,::Any,::Any,::Any,::Any,::Any)
get_prices(::Type{TimeArray},::String;:AbstractString,::AbstractString,::Any, ::Any,::Any,::Any,::Any,::Any,::Any,::Any)
```` -->


You can also covert from the OrderedDict to these by using the following function:

```@docs
sink_prices_to(::Type{TimeArray},::OrderedDict{String,Any})
sink_prices_to(::Type{TSFrame},::OrderedDict{String,Any})
```