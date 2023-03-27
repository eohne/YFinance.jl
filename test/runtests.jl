using YFinance, Dates
using Test

@testset "YFinance" begin

        ta = get_prices("AAPL",range="max")
        @test length(ta["timestamp"]) > 100

        ta = get_prices("AAPL",interval="1m",range="5d")
        @test length(ta["timestamp"]) > 100

        ta = get_prices("AAPL",startdt =Dates.today()-Year(5) , enddt = Dates.today())
        @test length(ta["timestamp"]) > 100

        ta = get_prices("ADANIENT.NS",startdt =Dates.today()-Year(10) , enddt = Dates.today())
        @test length(ta["timestamp"]) > 100

        ta = get_Fundamental("AAPL","income_statement","annual",Dates.today() - Year(5),Dates.today())
        @test in("InterestExpense",keys(ta))
        @test length(ta["InterestExpense"]) > 3

        ta = get_Options("AAPL")
        @test in("calls", keys(ta))
        @test length(ta["calls"]["strike"]) > 1

        ta = get_ESG("AAPL")
        @test in("score",keys(ta))
        @test length(ta["score"]["timestamp"]) > 0

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

        @testset "Search_Symbol" begin
            # Test case insensitivity
            @test length(get_symbols("nySE")) == length(get_symbols("NYSE"))

            # Test if the market is supported
            @test_throws ArgumentError get_symbols("wrong")

            @test isa(get_symbols("NASDAQ"), Vector{String})

            @test length(get_symbols("AMEX")) > 100
        end
end
