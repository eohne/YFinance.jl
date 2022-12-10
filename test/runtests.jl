using YFin, Dates
using Test

@testset "YFin" begin

        ta = get_prices("AAPL",range="max")
        @test length(ta["timestamp"]) > 100

        ta = get_quoteSummary("AAPL")
        @test in(:price,keys(ta))

        ta = get_Fundamental("AAPL","income_statement","annual",Dates.today() - Year(5),Dates.today())
        @test in("InterestExpense",keys(ta))
        @test length(ta["InterestExpense"]) > 3

        ta = get_Options("AAPL")
        @test in("calls", keys(ta))
        @test length(ta["calls"]["strike"]) > 1

        ta = get_ESG("AAPL")
        @test in("score",keys(ta))
        @test length(ta["score"]["timestamp"]) > 0     
end