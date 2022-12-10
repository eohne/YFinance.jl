var documenterSearchIndex = {"docs":
[{"location":"#YFinance.jl","page":"Home","title":"YFinance.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Download price, fundamental, and option data from Yahoo Finance This is a side project and my first package so do not expect too much. ","category":"page"},{"location":"#***-LEGAL-DISCLAIMER-***","page":"Home","title":"*** LEGAL DISCLAIMER ***","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Yahoo!, Y!Finance, and Yahoo! finance are registered trademarks of Yahoo, Inc.","category":"page"},{"location":"","page":"Home","title":"Home","text":"YFinance.jl is not affiliated with Yahoo, Inc. in any way. The data retreived can only be used for personal use.  Please see Yahoo's terms of use:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Here\nHere\nHere","category":"page"},{"location":"#What-you-can-download","page":"Home","title":"What you can download","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Price data (including intraday)\nFundamental data\nOption Data\nESG Data\nquoteSummary data (this is a JSON3.object that contains a multitude of different information)","category":"page"},{"location":"#Function-Documentation","page":"Home","title":"Function Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"get_prices\r\n\r\nget_quoteSummary\r\n\r\nget_Fundamental\r\n\r\nget_Options\r\n\r\nget_ESG","category":"page"},{"location":"#YFinance.get_prices","page":"Home","title":"YFinance.get_prices","text":"get_prices(symbol::AbstractString; range::AbstractString=\"1mo\", interval::AbstractString=\"1d\",startdt=\"\", enddt=\"\",prepost=false,autoadjust=true,timeout = 10)\n\nRetrievs prices from Yahoo Finance.\n\nArguments\n\nSmybol is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)\n\nYou can either provide a range or a startdt and an enddt.\n\nrange takes the following values: \"1d\",\"5d\",\"1mo\",\"3mo\",\"6mo\",\"1y\",\"2y\",\"5y\",\"10y\",\"ytd\",\"max\"\n\nstartdt and enddt take the following types: ::Date,::DateTime, or a String of the following form yyyy-mm-dd\n\nprepost is a boolean indicating whether pre and post periods should be included. Defaults to false\n\nautoadjust defaults to true. It adjusts open, high, low, close prices, and volume by multiplying the with the ratios between the close and the adjusted close prices - only available for intervals of 1d and up. \n\nExamples\n\njulia> get_prices(\"AAPL\",range=\"1d\",interval=\"90m\")\nDict{String, Any} with 7 entries:\n\"vol\"    => [10452686, 0]\n\"ticker\" => \"AAPL\"\n\"high\"   => [142.55, 142.045]\n\"open\"   => [142.34, 142.045]\n\"timestamp\"     => [DateTime(\"2022-12-09T14:30:00\"), DateTime(\"2022-12-09T15:08:33\")]\n\"low\"    => [140.9, 142.045]\n\"close\"  => [142.28, 142.045]\n\nCan be easily converted to a DataFrame\n\njulia> get_prices(\"AAPL\",range=\"1d\",interval=\"90m\") |> DataFrame\n2×7 DataFrame\nRow │ close    timestamp            high     low      open     ticker  vol      \n    │ Float64  DateTime             Float64  Float64  Float64  String  Int64    \n────┼───────────────────────────────────────────────────────────────────────────\n  1 │  142.28  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    10452686\n  2 │  142.19  2022-12-09T15:08:03   142.19   142.19   142.19  AAPL           0\n\nBroadcasting\n\njulia> get_prices.([\"AAPL\",\"NFLX\"],range=\"1d\",interval=\"90m\")\n2-element Vector{Dict{String, Any}}:\nDict(\n    \"vol\" => [11085386, 0], \n    \"ticker\" => \"AAPL\", \n    \"high\" => [142.5500030517578, 142.2949981689453], \n    \"open\" => [142.33999633789062, 142.2949981689453], \n    \"timestamp\" => [DateTime(\"2022-12-09T14:30:00\"), DateTime(\"2022-12-09T15:15:34\")], \n    \"low\" => [140.89999389648438, 142.2949981689453], \n    \"close\" => [142.27000427246094, 142.2949981689453])\nDict(\n    \"vol\" => [4435651, 0], \n    \"ticker\" => \"NFLX\", \n    \"high\" => [326.29998779296875, 325.30999755859375], \n    \"open\" => [321.45001220703125, 325.30999755859375], \n    \"timestamp\" => [DateTime(\"2022-12-09T14:30:00\"), DateTime(\"2022-12-09T15:15:35\")], \n    \"low\" => [319.5199890136719, 325.30999755859375], \n    \"close\" => [325.79998779296875, 325.30999755859375])\n\nConverting it to a DataFrame:\n\njulia> data = get_prices.([\"AAPL\",\"NFLX\"],range=\"1d\",interval=\"90m\");\njulia> vcat([DataFrame(i) for i in data]...)\n4×7 DataFrame\nRow │ close    timestamp            high     low      open     ticker  vol      \n    │ Float64  DateTime             Float64  Float64  Float64  String  Int64    \n────┼───────────────────────────────────────────────────────────────────────────\n  1 │  142.21  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    11111223\n  2 │  142.16  2022-12-09T15:12:20   142.16   142.16   142.16  AAPL           0\n  3 │  324.51  2022-12-09T14:30:00   326.3    319.52   321.45  NFLX     4407336\n  4 │  324.65  2022-12-09T15:12:20   324.65   324.65   324.65  NFLX           0\n\n\n\n\n\n","category":"function"},{"location":"#YFinance.get_quoteSummary","page":"Home","title":"YFinance.get_quoteSummary","text":"get_quoteSummary(symbol::String; item=nothing)\n\nRetrievs general information from Yahoo Finance stored in a JSON3 object.\n\nArguments\n\nsmybol::String is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  \nitem can either be a string or multiple items as a Vector of Strings. To see valid items call _QuoteSummary_Items (not all items are available for all types of securities)  \n\nExamples\n\njulia> get_quoteSummary(\"AAPL\")\n\nJSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 31 entries:\n:assetProfile             => {…\n:recommendationTrend      => {…\n:cashflowStatementHistory => {…\n\n⋮                         => ⋮\njulia> get_quoteSummary(\"AAPL\",item = \"quoteType\")\nJSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 13 entries:\n:exchange               => \"NMS\"\n:quoteType              => \"EQUITY\"\n:symbol                 => \"AAPL\"\n⋮                       => ⋮\n\n\n\n\n\n","category":"function"},{"location":"#YFinance.get_Fundamental","page":"Home","title":"YFinance.get_Fundamental","text":"get_Fundamental(symbol::AbstractString, item::AbstractString,interval::AbstractString, startdt, enddt)\n\nRetrievs financial statement information from Yahoo Finance stored in a Dictionary.\n\nArguments\n\nsmybol::String is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  \nitem::String can either be an entire financial statement or a subitem. Entire financial statements:\"incomestatement\", \"valuation\", \"cashflow\", \"balancesheet\".  To see valid sub items grouped by financial statement type in a Dictionary call `Fundamental_Types`  \ninterval::String can be one of \"annual\", \"quarterly\", \"monthly\"  \nstartdtandenddttake the following types:::Date,::DateTime, or aStringof the following formyyyy-mm-dd`  \n\nExamples\n\njulia> get_Fundamental(\"NFLX\", \"income_statement\",\"quarterly\",\"2000-01-01\",\"2022-12-31\")\n\nDict{String, Any} with 39 entries:\n\"NetNonOperatingInterestIncomeExpense\" => Any[-94294000, -80917000, 8066000, 44771000, 88829000]\n\"NetInterestIncome\"                    => Any[-94294000, -80917000, 8066000, 44771000, 88829000]\n\"InterestExpense\"                      => Any[190429000, 189429000, 187579000, 175455000, 172575000]\n⋮                                      => ⋮\n\njulia> get_Fundamental(\"AAPL\", \"InterestExpense\",\"quarterly\",\"2000-01-01\",\"2022-12-31\") |> DataFrame\n5×2 DataFrame\nRow │ InterestExpense  timestamp\n    │ Any              DateTime\n────┼──────────────────────────────────────\n  1 │ 672000000        2021-09-30T00:00:00 \n  2 │ 694000000        2021-12-31T00:00:00\n  3 │ 691000000        2022-03-31T00:00:00\n  4 │ 719000000        2022-06-30T00:00:00\n  5 │ 827000000        2022-09-30T00:00:00\n\n\n\n\n\n","category":"function"},{"location":"#YFinance.get_Options","page":"Home","title":"YFinance.get_Options","text":"get_Options(symbol::String)\n\nRetrievs options data from Yahoo Finance stored in a Dictionary with two items. One contains Call options the other Put options. These subitems are dictionaries themselves. The call and put options Dictionaries can readily be transformed to a DataFrame.\n\nArguments\n\nsmybol::String is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  \n\nExamples\n\njulia> get_Options(\"AAPL\")\nDict{String, Dict{String, Vector{Any}}} with 2 entries:\n\"calls\" => Dict(\"percentChange\"=>[ -2.90804  …   0], \"expiration\"=>[DateTime(\"2022-12-09T00:…  \n\"puts\"  => Dict(\"percentChange\"=>[0,  …   0], \"expiration\"=>[DateTime(\"2022-12-09T00:00:00\"), DateTime(\"20…\n\n \njulia> get_Options(\"AAPL\")[\"calls\"] |> DataFrame\n65×16 DataFrame\nRow │ ask    bid    change     contractSize  contractSymbol       currency  exp ⋯\n    │ Any    Any    Any        Any           Any                  Any       Any ⋯\n────┼────────────────────────────────────────────────────────────────────────────\n  1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD       202 ⋯\n  2 │ 84.3   84.15  0          REGULAR       AAPL221209C00060000  USD       202  \n ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮              ⋮          ⋱  \n 64 │ 0.01   0      0          REGULAR       AAPL221209C00240000  USD       202  \n 65 │ 0      0      0          REGULAR       AAPL221209C00250000  USD       202  \n                                                   10 columns and 61 rows omitted\n\n\njulia> data  = get_Options(\"AAPL\")\njulia> vcat( [DataFrame(i) for i in values(data)]...)\n124×16 DataFrame\nRow │ ask    bid    change     contractSize  contractSymbol       cur ⋯\n    │ Any    Any    Any        Any           Any                  Any ⋯\n────┼──────────────────────────────────────────────────────────────────\n  1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD ⋯\n  2 │ 84.55  84.35  0          REGULAR       AAPL221209C00060000  USD  \n ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮               ⋱ \n123 │ 75.85  75.15  0          REGULAR       AAPL221209P00220000  USD  \n124 │ 85.85  85.15  0          REGULAR       AAPL221209P00230000  USD  \n                                        11 columns and 120 rows omitted\n\n\n\n\n\n","category":"function"},{"location":"#YFinance.get_ESG","page":"Home","title":"YFinance.get_ESG","text":"get_ESG(symbol::String)\n\nRetrievs ESG Scores from Yahoo Finance stored in a Dictionary with two items. One, score, contains the companies ESG scores and individal Overall, Environment, Social and  Goverance Scores as well as a timestamp of type DateTime. The other,  peer_score, contains the peer group's scores. The subdictionaries can be transformed to DataFrames\n\nArguments\n\nsmybol::String is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  \n\nExamples\n\njulia> get_ESG(\"AAPL\")\nDict{String, Dict{String, Any}} with 2 entries:\n\"peer_score\" => Dict(\"governanceScore\"=>Union{Missing, Float64}[63.2545, 63.454…  \n\"score\"      => Dict(\"governanceScore\"=>Union{Missing, Real}[62, 62, 62, 62, 62… \n   \njulia> get_ESG(\"AAPL\")[\"score\"] |> DataFrame\n96×6 DataFrame\nRow │ environmentScore  esgScore    governanceScore  socialScore  symbol  times ⋯\n    │ Real?             Real?       Real?            Real?        String  DateT ⋯\n────┼────────────────────────────────────────────────────────────────────────────\n  1 │            74          61               62           45     AAPL    2014- ⋯\n  2 │            74          60               62           45     AAPL    2014-  \n ⋮  │        ⋮              ⋮              ⋮              ⋮         ⋮           ⋱\n 95 │       missing     missing          missing      missing     AAPL    2022-  \n 96 │             0.65       16.68             9.18         6.86  AAPL    2022-  \n                                                     1 column and 92 rows omitted\n\n\n\n\n\n","category":"function"}]
}
