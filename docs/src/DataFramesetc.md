# Converting To Tables

## DataFrames (DataFrames.jl)

The OrderedDicts can readily be converted to DataFrames by simply calling the DataFrames function on them.

```julia
using DataFrames

prices = get_prices("AAPL")

DataFrame(prices)
```
## TimeArray from TimeSeries

If you use Julia 1.9 or newer you can just use a sink argument in `get_prices` instead.
```julia
using TimeSeries, YFinance
get_prices(TimeArray,"AAPL")
```
(runtime for this is about 80% faster than `yahoo(:INTC)` from MarketData.jl (median run time: 0.09s vs 0.41s) )

or alternatively

```julia
using TimeSeries, YFinance
prices = get_prices("AAPL")
sink_prices_to(TimeArray,prices)
```

If you use an older version you can run the below code:

The TimeArray takes a Vector with the timestamp, a matrix with the price data, column names, and some metadata.  

Below is a simple function showing how one may convert the dictionaries containing the price information into a TimeArray - this is most likely not the fastest or most elegant way.

```julia
using TimeSeries

prices = get_prices("AAPL")

function stock_price_to_time_array(d)
    coln = collect(keys(x))[3:end] # only get the keys that are not ticker or datetime
    m = hcat([x[k] for k in coln]...) #Convert the dictionary into a matrix
    return TimeArray(x["timestamp"],m,Symbol.(coln),x["ticker"])
end

stock_price_to_time_array(prices)
```

## TSFrame from TSFrames.jl

If you use Julia 1.9 or newer you can just use a sink argument in `get_prices` instead.
```julia
using TSFrames, YFinance
get_prices(TSFrame,"AAPL")
```
or alternatively

```julia
using TSFrames, YFinance
prices = get_prices("AAPL")
sink_prices_to(TSFrame,prices)
```

If you use an older version you can run the below code:


The TSFrame takes a matrix, a DateTime index, and a Vector of column names as arguments.  

Below is an example of a function converting the price data to a TSFrame - this is most likely not the fastest or most elegant way.

```julia
using TSFrames

prices = get_prices("AAPL")

function stock_price_to_TSFrames(x)
    coln = collect(keys(x))[3:end] # only get the keys that are not ticker or datetime
    m = hcat([x[k] for k in coln]...) #Convert the dictionary into a matrix
    tsf = TSFrame(m,x["timestamp"],colnames = Symbol.(coln)) # create the timeseries array
    return tsf
end

stock_price_to_TSFrames(prices)
```