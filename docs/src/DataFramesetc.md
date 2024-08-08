# Converting To Tables

## DataFrames (DataFrames.jl)

The OrderedDicts can readily be converted to DataFrames by simply calling the DataFrames function on them.

```julia
using DataFrames

prices = get_prices("AAPL")

DataFrame(prices)
```  

### Broadcasting to get one DataFrame (stacked)
```julia
tickers=["AAPL","TSLA","F"]
prices = get_prices.(tickers,startdt="2024-01-01",enddt="2024-08-01") |> (x-> DataFrame.(x)) |> (x->vcat(x...))
```  

```julia
438×8 DataFrame
 Row │ ticker  timestamp            open      high      low       close    adjclose  vol       
     │ String  DateTime             Float64   Float64   Float64   Float64  Float64   Float64
─────┼─────────────────────────────────────────────────────────────────────────────────────────
   1 │ AAPL    2024-01-02T14:30:00  186.658   187.945   183.407    185.64  185.152   8.2272e7
   2 │ AAPL    2024-01-03T14:30:00  183.736   185.392   182.948    184.25  183.766   5.8261e7
   3 │ AAPL    2024-01-04T14:30:00  181.671   182.609   180.405    181.91  181.432   7.17945e7
   4 │ AAPL    2024-01-05T14:30:00  181.512   182.28    179.697    181.18  180.704   6.21396e7
  ⋮  │   ⋮              ⋮              ⋮         ⋮         ⋮         ⋮        ⋮          ⋮
 436 │ F       2024-07-29T13:30:00   11.0085   11.0085   10.6344    11.01   10.8411  9.02616e7
 437 │ F       2024-07-30T13:30:00   10.8608   10.9396   10.6147    10.84   10.6737  6.82735e7
 438 │ F       2024-07-31T13:30:00   10.6934   10.8411   10.5556    10.82   10.654   7.43204e7
                                                                               431 rows omitted
```

## TimeArray from TimeSeries

If you use Julia 1.9 or newer you can just use a sink argument in `get_prices` instead.
```julia
using TimeSeries, YFinance
get_prices(TimeArray,"AAPL")
```

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

### Broadcast and create one TimeArray for the adjclose prices  


```julia
tickers = ["AAPL","TSLA","F"]
prices = get_prices.((TimeArray,),tickers)
```  

```julia
3-element Vector{TimeArray{Float64, 2, DateTime, Matrix{Float64}}}:
 5×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
 5×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
 5×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
```  

Combine into one TimeArray:
```julia
prices=hcat(prices...)
```  

```julia
5×18 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
┌─────────────────────┬────────┬────────┬────────┬────────┬──────────┬───────────┬────────┬────────┬────────┬─────────┬────────────┬───────────┬─────────┬─────────┬─────────┬─────────
│                     │ open   │ high   │ low    │ close  │ adjclose │ vol       │ open_1 │ high_1 │ low_1  │ close_1 │ adjclose_1 │ vol_1     │ open_2  │ high_2  │ low_2   │ close_ ⋯
├─────────────────────┼────────┼────────┼────────┼────────┼──────────┼───────────┼────────┼────────┼────────┼─────────┼────────────┼───────────┼─────────┼─────────┼─────────┼─────────
│ 2024-08-01T13:30:00 │ 224.37 │ 224.48 │ 217.02 │ 218.36 │   218.36 │  6.2501e7 │ 227.69 │ 231.87 │ 214.33 │  216.86 │     216.86 │ 8.38619e7 │ 10.6934 │ 10.7525 │ 10.4473 │   10.6 ⋯
│ 2024-08-02T13:30:00 │ 219.15 │  225.6 │ 217.71 │ 219.86 │   219.86 │ 1.05569e8 │ 214.88 │ 216.13 │ 205.78 │  207.67 │     207.67 │ 8.28801e7 │ 10.3882 │ 10.3882 │ 9.84663 │   10.0 ⋯
│ 2024-08-05T13:30:00 │ 199.09 │  213.5 │  196.0 │ 209.27 │   209.27 │ 1.19549e8 │ 185.22 │ 203.88 │  182.0 │  198.88 │     198.88 │ 1.00309e8 │ 9.41338 │ 9.74816 │ 9.34445 │    9.7 ⋯
│ 2024-08-06T13:30:00 │  205.3 │ 209.99 │ 201.07 │ 207.23 │   207.23 │ 6.96605e7 │ 200.75 │  202.9 │ 192.67 │  200.64 │     200.64 │ 7.37839e7 │ 9.63985 │ 9.70877 │ 9.53153 │    9.7 ⋯
│ 2024-08-07T13:30:00 │  206.9 │ 213.64 │ 206.39 │ 209.82 │   209.82 │ 6.34023e7 │ 200.77 │ 203.49 │ 191.48 │  191.76 │     191.76 │ 7.07614e7 │    9.85 │    9.98 │    9.75 │    9.7 ⋯
└─────────────────────┴────────┴────────┴────────┴────────┴──────────┴───────────┴────────┴────────┴────────┴─────────┴────────────┴───────────┴─────────┴─────────┴─────────┴─────────
                                                                                                                                                                      3 columns omitted
```

Get the relevant column names (all columns that are called adjclose)    
```julia
cidx = colnames(prices)[occursin.(r"adj",string.(colnames(prices)))]
```  

```
3-element Vector{Symbol}:
 :adjclose
 :adjclose_1
 :adjclose_2
```  

Select these columns
```julia
prices = prices[cidx]
```  

```julia
5×3 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
┌─────────────────────┬──────────┬────────────┬────────────┐
│                     │ adjclose │ adjclose_1 │ adjclose_2 │
├─────────────────────┼──────────┼────────────┼────────────┤
│ 2024-08-01T13:30:00 │   218.36 │     216.86 │     10.526 │
│ 2024-08-02T13:30:00 │   219.86 │     207.67 │    9.87617 │
│ 2024-08-05T13:30:00 │   209.27 │     198.88 │    9.56107 │
│ 2024-08-06T13:30:00 │   207.23 │     200.64 │       9.63 │
│ 2024-08-07T13:30:00 │   209.82 │     191.76 │       9.77 │
└─────────────────────┴──────────┴────────────┴────────────┘
```  

Rename them back to the tickers:
```julia
TimeSeries.rename!(prices,Symbol.(tickers))
```  

```julia
5×3 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2024-08-01T13:30:00 to 2024-08-07T13:30:00
┌─────────────────────┬────────┬────────┬─────────┐
│                     │ AAPL   │ TSLA   │ F       │
├─────────────────────┼────────┼────────┼─────────┤
│ 2024-08-01T13:30:00 │ 218.36 │ 216.86 │  10.526 │
│ 2024-08-02T13:30:00 │ 219.86 │ 207.67 │ 9.87617 │
│ 2024-08-05T13:30:00 │ 209.27 │ 198.88 │ 9.56107 │
│ 2024-08-06T13:30:00 │ 207.23 │ 200.64 │    9.63 │
│ 2024-08-07T13:30:00 │ 209.82 │ 191.76 │    9.77 │
└─────────────────────┴────────┴────────┴─────────┘
```

Or in one function:
```julia
function get_adj_close_TA(tickers,startdt,enddt,interval)
    prices = get_prices.((TimeArray,),tickers,startdt=startdt,enddt=enddt,interval=interval) |> (x->hcat(x...))
    prices = prices[colnames(prices)[occursin.(r"adj",string.(colnames(prices)))]]
    TimeSeries.rename!(prices,Symbol.(tickers))
    return prices
end;

get_adj_close_TA(["AAPL","TSLA","F","AMD","NFLX","WBA"],Date(2023-01-01),Date(2024-01-01),"1d")
```  

```julia
252×6 TimeArray{Float64, 2, DateTime, Matrix{Float64}} 2021-01-04T14:30:00 to 2021-12-31T14:30:00
┌─────────────────────┬─────────┬─────────┬─────────┬────────┬────────┬─────────┐
│                     │ AAPL    │ TSLA    │ F       │ AMD    │ NFLX   │ WBA     │
├─────────────────────┼─────────┼─────────┼─────────┼────────┼────────┼─────────┤
│ 2021-01-04T14:30:00 │  126.83 │ 243.257 │ 7.03792 │   92.3 │ 522.86 │ 34.6737 │
│ 2021-01-05T14:30:00 │ 128.398 │ 245.037 │  7.1453 │  92.77 │  520.8 │ 34.4727 │
│ 2021-01-06T14:30:00 │ 124.076 │ 251.993 │ 7.30225 │  90.33 │ 500.49 │ 36.0389 │
│ 2021-01-07T14:30:00 │  128.31 │ 272.013 │ 7.48398 │  95.16 │ 508.89 │ 37.9066 │
│          ⋮          │    ⋮    │    ⋮    │    ⋮    │   ⋮    │   ⋮    │    ⋮    │
│ 2021-12-29T14:30:00 │ 176.888 │ 362.063 │  17.069 │ 148.26 │ 610.54 │ 45.4322 │
│ 2021-12-30T14:30:00 │ 175.724 │  356.78 │ 16.9943 │ 145.15 │ 612.09 │ 45.2061 │
│ 2021-12-31T14:30:00 │ 175.103 │  352.26 │ 17.2434 │  143.9 │ 602.44 │ 45.3539 │
└─────────────────────┴─────────┴─────────┴─────────┴────────┴────────┴─────────┘
                                                                 245 rows omitted
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

### Broadcast and create one TSFrame for the adjclose prices
```julia
tickers = ["AAPL","TSLA","F"]
prices = get_prices.((TSFrame,),tickers);
```  

We now want to combine them by taking the adjclose of each tsframe.

```julia
prices = join(getindex.(prices,:,([:Index,:adjclose],))...)
```  

```julia
5×3 TSFrame with DateTime Index
 Index                adjclose  adjclose_1  adjclose_2 
 DateTime             Float64?  Float64?    Float64?
───────────────────────────────────────────────────────
 2024-08-01T13:30:00    218.36      216.86    10.526
 2024-08-02T13:30:00    219.86      207.67     9.87617
 2024-08-05T13:30:00    209.27      198.88     9.56107
 2024-08-06T13:30:00    207.23      200.64     9.63
 2024-08-07T13:30:00    209.82      191.76     9.77
```

Rename:
```julia
TSFrames.rename!(prices, tickers)
```  

```julia
5×3 TSFrame with DateTime Index
 Index                AAPL      TSLA      F        
 DateTime             Float64?  Float64?  Float64?
───────────────────────────────────────────────────
 2024-08-01T13:30:00    218.36    216.86  10.526
 2024-08-02T13:30:00    219.86    207.67   9.87617
 2024-08-05T13:30:00    209.27    198.88   9.56107
 2024-08-06T13:30:00    207.23    200.64   9.63
 2024-08-07T13:30:00    209.82    191.76   9.77
```  

Or in one function:

```julia

function get_adj_close_TSF(tickers,startdt,enddt,interval)
    prices = get_prices.((TSFrame,),tickers,startdt=startdt,enddt=enddt,interval=interval)
    prices = join(getindex.(prices,:,([:Index,:adjclose],))...)
    TSFrames.rename!(prices, tickers)
    return prices    
end;
get_adj_close_TSF(["AAPL","TSLA","F","AMD","NFLX","WBA"],Date(2023-01-01),Date(2024-01-01),"1d")
```  

```julia
252×6 TSFrame with DateTime Index
 Index                AAPL      TSLA      F         AMD       NFLX      WBA      
 DateTime             Float64?  Float64?  Float64?  Float64?  Float64?  Float64?
─────────────────────────────────────────────────────────────────────────────────
 2021-01-04T14:30:00   126.83    243.257   7.03792     92.3     522.86   34.6737
 2021-01-05T14:30:00   128.398   245.037   7.1453      92.77    520.8    34.4727
 2021-01-06T14:30:00   124.076   251.993   7.30225     90.33    500.49   36.0389
 2021-01-07T14:30:00   128.31    272.013   7.48398     95.16    508.89   37.9066
          ⋮              ⋮         ⋮         ⋮         ⋮         ⋮         ⋮
 2021-12-29T14:30:00   176.888   362.063  17.069      148.26    610.54   45.4322
 2021-12-30T14:30:00   175.724   356.78   16.9943     145.15    612.09   45.2061
 2021-12-31T14:30:00   175.103   352.26   17.2434     143.9     602.44   45.3539
                                                                 245 rows omitted
```