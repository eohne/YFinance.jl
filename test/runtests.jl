using TimeSeries, TSFrames,YFinance, Dates
using Test

@testset "YFinance" begin 
    @testset "Get Prices" begin
        ta = get_valid_symbols(["aapl","amd","adsflajsldf"])
        @test ta==["aapl","amd"]

        ta=YFinance._date_to_unix("2000-01-01","2010-01-01")
        @test ta==(946684800, 1262304000)
        ta=YFinance._date_to_unix(Date(200,1,1),Date(201,1,1))
        @test ta==(-55855785600, -55824249600)
        ta=YFinance._date_to_unix(DateTime(200,1,1),DateTime(201,1,1))
        @test ta==(-55855785600, -55824249600)

        @test_throws ErrorException get_prices("aapl",interval="1m", range="1mo")
        @test_throws ErrorException get_prices("aapl",interval="1m",startdt="2000-01-01", enddt="2020-10-01")

        ta = get_prices("AAPL",range="max",exchange_local_time=true)
        @test length(ta["timestamp"]) > 100
        @test typeof(sink_prices_to(TimeArray,ta)) <: TimeArray
        @test typeof(sink_prices_to(TSFrame,ta)) <: TSFrame

        ta = get_prices("AAPL",interval="1m",range="5d")
        @test length(ta["timestamp"]) > 100

        ta = get_prices("ADANIENT.NS",startdt =Dates.today()-Year(10) , enddt = Dates.today())
        @test length(ta["timestamp"]) > 100

        ta = get_prices(TimeArray,"AAPL",interval="1m",range="5d")
        @test typeof(ta) <:TimeArray
        @test size(ta,2) ==5
        ta = get_prices(TSFrame, "AAPL",interval="1m",range="5d")
        @test typeof(ta) <:TSFrame
        @test size(ta,2) ==6
    end
    @testset "Dividends and Splits" begin
        ta = get_prices("GOOGL",interval="1d",startdt="2022-01-01",enddt="2023-01-01",divsplits=true)
        @test haskey(ta, "div")
        @test haskey(ta, "split_ratio")
        @test isequal(maximum(ta["split_ratio"]), 20)
        @test isequal(length(ta["timestamp"]), length(ta["div"]))
        @test isequal(length(ta["timestamp"]), length(ta["split_ratio"]))
        
    end
    @testset "Dividends" begin
        ta = get_dividends("WBA",startdt="2022-01-01",enddt="2023-01-01")
        ta = get_dividends("TSLA",startdt="2022-01-01",enddt="2023-01-01")
        @test haskey(ta, "div")
        @test length(ta["div"])==4
        
    end
    @testset "Splits" begin
        ta = get_splits("WBA",startdt="2022-01-01",enddt="2023-01-01")
        ta = get_splits("TSLA",startdt="2022-01-01",enddt="2023-01-01")
        @test haskey(ta, "timestamp")
        @test haskey(ta, "numerator")
        @test haskey(ta, "denominator")
        @test isempty(ta["ratio"])
        
    end
    @testset "Fundamental Data" begin
        ta = get_Fundamental("AAPL","income_statement","annual",Dates.today() - Year(5),Dates.today())
        @test in("InterestExpense",keys(ta))
        @test length(ta["InterestExpense"]) > 3
    end
    @testset "Get Options" begin
        ta = get_Options("AAPL")
        @test in("calls", keys(ta))
        @test length(ta["calls"]["strike"]) > 1
    end
    @testset "Get ESG" begin
        ta = get_ESG("AAPL")
        @test in("score",keys(ta))
        @test length(ta["score"]["timestamp"]) > 0
    end
    @testset "Get QuoteSummary Items" begin
        ta = get_quoteSummary("AAPL")
        @test in(:price,keys(ta))

        @test haskey(get_calendar_events(ta),"earnings_dates")

        @test haskey(get_earnings_estimates(ta),"estimate")

        @test haskey(get_eps(ta),"estimate")

        @test haskey(get_insider_holders(ta),"name")

        @test haskey(get_insider_transactions(ta),"filerName")

        @test haskey(get_institutional_ownership(ta),"organization")

        @test haskey(get_major_holders_breakdown(ta),"institutionsCount")

        @test haskey(get_recommendation_trend(ta),"strongbuy")

        @test haskey(get_summary_detail(ta),"tradeable")

        @test haskey(get_sector_industry(ta),"sector")

        @test haskey(get_upgrade_downgrade_history(ta),"firm")
    end

    @testset "All Symbols" begin
        # Test case insensitivity
        @test length(get_all_symbols("nySE")) == length(get_all_symbols("NYSE"))

        # Test if the market is supported
        @test_throws ArgumentError get_all_symbols("wrong")

        @test isa(get_all_symbols("NASDAQ"), Vector{String})

        @test length(get_all_symbols("AMEX")) > 100
    end
    @testset "Search_Symbol" begin        
        ta = get_symbols("micro")
        @test typeof(ta) <: YahooSearch
        @test length(ta) >0 
        @test typeof(ta[1]) <: YahooSearchItem
        @test typeof(ta[1].symbol) <: String
        @test isnothing(show(ta));

        ta = get_symbols("asjdflkalskjfdkjalk")
        @test typeof(ta) <: YahooSearch
        @test isempty(ta)
    end

    @testset "News_Search" begin        
        ta = search_news("MSFT")
        @test typeof(ta) <: YahooNews
        @test length(ta) >0 
        @test typeof(ta[1]) <: NewsItem
        @test typeof(ta[1].title) <: String

        @test size(titles(ta),1) > 0 
        @test typeof(titles(ta)[1]) <: String 

        @test size(links(ta),1) > 0 
        @test typeof(links(ta)[1]) <: String 
        @test size(timestamps(ta),1) > 0  
        @test typeof(timestamps(ta)[1]) <: DateTime 
    end

    @testset "Create Proxy" begin
        @test isnothing(_PROXY_SETTINGS.proxy)
        @test typeof(_PROXY_SETTINGS.auth) <:Dict
        @test isempty(_PROXY_SETTINGS.auth) 
        create_proxy_settings("someproxy","username123","pw123")
        @test _PROXY_SETTINGS.proxy=="someproxy"
        @test typeof(_PROXY_SETTINGS.auth) <:Dict
        @test _PROXY_SETTINGS.auth["Proxy-Authorization"] <: String
        @test _PROXY_SETTINGS.auth["Proxy-Authorization"]=="Basic dXNlcm5hbWUxMjM6cHcxMjM="
        clear_proxy_settings()
        @test isnothing(_PROXY_SETTINGS.proxy)
        @test typeof(_PROXY_SETTINGS.auth) <:Dict
        @test isempty(_PROXY_SETTINGS.auth)
    end
end
