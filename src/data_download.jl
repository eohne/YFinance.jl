
const _BASE_URL_ = "https://query2.finance.yahoo.com";

function _url(base,ticker)
    return "$(base)/v8/finance/chart/$(uppercase(ticker))"
end


"""
        get_prices(symbol::AbstractString; range::AbstractString="1mo", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10)
    
    Retrievs prices from Yahoo Finance.

    ## Arguments

      * `Smybol` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)
    
      You can either provide a `range` or a `startdt` and an `enddt`.
      * `range` takes the following values: "1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"
      
      * `startdt` and `enddt` take the following types: `::Date`,`::DateTime`, or a `String` of the following form `yyyy-mm-dd`
      
      * `prepost` is a boolean indicating whether pre and post periods should be included. Defaults to `false`
      
      * `autoadjust` defaults to `true`. It adjusts open, high, low, close prices, and volume by multiplying by the ratio between the close and the adjusted close prices - only available for intervals of 1d and up. 
    
    # Examples
    ```julia-repl
    julia> get_prices("AAPL",range="1d",interval="90m")
    Dict{String, Any} with 7 entries:
    "vol"    => [10452686, 0]
    "ticker" => "AAPL"
    "high"   => [142.55, 142.045]
    "open"   => [142.34, 142.045]
    "timestamp"     => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:08:33")]
    "low"    => [140.9, 142.045]
    "close"  => [142.28, 142.045]
    ```
    ## Can be easily converted to a DataFrame
    ```julia-repl
    julia> get_prices("AAPL",range="1d",interval="90m") |> DataFrame
    2×7 DataFrame
    Row │ close    timestamp            high     low      open     ticker  vol      
        │ Float64  DateTime             Float64  Float64  Float64  String  Int64    
    ────┼───────────────────────────────────────────────────────────────────────────
      1 │  142.28  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    10452686
      2 │  142.19  2022-12-09T15:08:03   142.19   142.19   142.19  AAPL           0
    ```

    ## Broadcasting
    ```julia-repl
    julia> get_prices.(["AAPL","NFLX"],range="1d",interval="90m")
    2-element Vector{Dict{String, Any}}:
    Dict(
        "vol" => [11085386, 0], 
        "ticker" => "AAPL", 
        "high" => [142.5500030517578, 142.2949981689453], 
        "open" => [142.33999633789062, 142.2949981689453], 
        "timestamp" => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:15:34")], 
        "low" => [140.89999389648438, 142.2949981689453], 
        "close" => [142.27000427246094, 142.2949981689453])
    Dict(
        "vol" => [4435651, 0], 
        "ticker" => "NFLX", 
        "high" => [326.29998779296875, 325.30999755859375], 
        "open" => [321.45001220703125, 325.30999755859375], 
        "timestamp" => [DateTime("2022-12-09T14:30:00"), DateTime("2022-12-09T15:15:35")], 
        "low" => [319.5199890136719, 325.30999755859375], 
        "close" => [325.79998779296875, 325.30999755859375])
    ```

    ## Converting it to a DataFrame:
    ```julia-repl
    julia> data = get_prices.(["AAPL","NFLX"],range="1d",interval="90m");
    julia> vcat([DataFrame(i) for i in data]...)
    4×7 DataFrame
    Row │ close    timestamp            high     low      open     ticker  vol      
        │ Float64  DateTime             Float64  Float64  Float64  String  Int64    
    ────┼───────────────────────────────────────────────────────────────────────────
      1 │  142.21  2022-12-09T14:30:00   142.55   140.9    142.34  AAPL    11111223
      2 │  142.16  2022-12-09T15:12:20   142.16   142.16   142.16  AAPL           0
      3 │  324.51  2022-12-09T14:30:00   326.3    319.52   321.45  NFLX     4407336
      4 │  324.65  2022-12-09T15:12:20   324.65   324.65   324.65  NFLX           0
    ```
    """
function get_prices(symbol::AbstractString; range::AbstractString="1mo", interval::AbstractString="1d",startdt="", enddt="",prepost=false,autoadjust=true,timeout = 10)
    validranges = ["1d","5d","1mo","3mo","6mo","1y","2y","5y","10y","ytd","max"]
    validintervals = ["1m","2m","5m","15m","30m","60m","90m","1h","1d","5d","1wk","1mo","3mo"]
    @assert in(range,validranges) "The chosen range is not supported choose one from:\n 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max"
    @assert in(interval,validintervals) "The chosen interval is not supported choose one from:\n 1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo"
    url = _url(_BASE_URL_,uppercase(symbol))
    if !isequal(startdt,"") || !isequal(enddt,"")
        range = ""
        if typeof(startdt) <: Date
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(startdt))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(enddt))))
        elseif typeof(startdt) <:DateTime
            startdt = Int(round(Dates.datetime2unix(startdt)))
            enddt = Int(round(Dates.datetime2unix(enddt)))
        elseif typeof(startdt) <: AbstractString
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(startdt,Dates.DateFormat("yyyy-mm-dd"))))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(enddt,Dates.DateFormat("yyyy-mm-dd"))))))
        else
            error("Startdt and Enddt must be either a Date, a DateTime, or a string of the following format yyyy-mm-dd!")
        end
    end

    parameters = Dict(
        "period1"=>startdt,
        "period2"=>enddt,
        "range"=>range,
        "interval"=>interval,
        "includePrePost"=>prepost,
        "events" => "div,splits"
    )
    # uri = URI(uri; query=parameters) |> string
    res = HTTP.get(url,query=parameters,readtimeout = timeout)
    res = JSON3.read(res.body).chart.result[1]

    # if interval in ["1m","2m","5m","15m","30m","60m","90m"] there is no adjusted close!

    if in(interval, ["1m","2m","5m","15m","30m","60m","90m"])
        d =     Dict(
                "ticker" => symbol,
                "timestamp" => Dates.unix2datetime.(res.timestamp),
                "open" => res.indicators.quote[1].open,
                "high" => res.indicators.quote[1].high,
                "low"  => res.indicators.quote[1].low,
                "close" => res.indicators.quote[1].close,
                "vol" => res.indicators.quote[1].volume) 
    else   
        d =     Dict(
            "ticker" => symbol,
            "timestamp" => Dates.unix2datetime.(res.timestamp),
            "open" => res.indicators.quote[1].open,
            "high" => res.indicators.quote[1].high,
            "low"  => res.indicators.quote[1].low,
            "close" => res.indicators.quote[1].close,
            "adjclose" => res.indicators.adjclose[1].adjclose,
            "vol" => res.indicators.quote[1].volume) 
        if autoadjust
            ratio = d["adjclose"] ./ d["close"]
            d["open"] = d["open"] .* ratio
            d["high"] = d["high"] .* ratio
            d["low"] = d["low"] .* ratio
            d["vol"] = d["vol"] .* ratio
        end
    end
    return d
end

const _QuoteSummary_Items = [
    "assetProfile",
    "balanceSheetHistory",
    "balanceSheetHistoryQuarterly",
    "calendarEvents",
    "cashflowStatementHistory",
    "cashflowStatementHistoryQuarterly",
    "defaultKeyStatistics",
    "earnings",
    "earningsHistory",
    "earningsTrend",
    "esgScores",
    "financialData",
    "fundOwnership",
    "fundPerformance",
    "fundProfile",
    "incomeStatementHistory",
    "incomeStatementHistoryQuarterly",
    "indexTrend",
    "industryTrend",
    "insiderHolders",
    "insiderTransactions",
    "institutionOwnership",
    "majorDirectHolders",
    "majorHoldersBreakdown",
    "netSharePurchaseActivity",
    "price",
    "quoteType",
    "recommendationTrend",
    "secFilings",
    "sectorTrend",
    "summaryDetail",
    "summaryProfile",
    "topHoldings",
    "upgradeDowngradeHistory"
]

"""
        get_quoteSummary(symbol::String; item=nothing)
    
    Retrievs general information from Yahoo Finance stored in a JSON3 object.

    ## Arguments

      * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

      * item can either be a string or multiple items as a `Vector` of `Strings`. To see valid items call `_QuoteSummary_Items` (not all items are available for all types of securities)  

    # Examples
    ```julia-repl
    julia> get_quoteSummary("AAPL")
    
    JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 31 entries:
    :assetProfile             => {…
    :recommendationTrend      => {…
    :cashflowStatementHistory => {…

    ⋮                         => ⋮
    julia> get_quoteSummary("AAPL",item = "quoteType")
    JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 13 entries:
    :exchange               => "NMS"
    :quoteType              => "EQUITY"
    :symbol                 => "AAPL"
    ⋮                       => ⋮
    ```
    """
function get_quoteSummary(symbol::String; item=nothing)
    if isequal(item,nothing)
        item = _QuoteSummary_Items
    end

    @assert all(in.(item, (_QuoteSummary_Items,))) "At least one item is not a valid option. To view options please call _QuoteSummary_Items"
    
    if typeof(item) <: AbstractString
        q= Dict("formatted" => "false","modules" => item)
    else
        q= Dict("formatted" => "false","modules" => join(item,","))
    end
    
    res = HTTP.get("https://query2.finance.yahoo.com/v10/finance/quoteSummary/$(symbol)",query =q )    
    res = JSON3.read(res.body)
    if typeof(item) <: AbstractString
        return res.quoteSummary.result[1][Symbol(item)]
    else
        return res.quoteSummary.result[1]
    end
end



_Fundamental_Types = Dict(
    "income_statement"=> [
        "Amortization",
        "AmortizationOfIntangiblesIncomeStatement",
        "AverageDilutionEarnings",
        "BasicAccountingChange",
        "BasicAverageShares",
        "BasicContinuousOperations",
        "BasicDiscontinuousOperations",
        "BasicEPS",
        "BasicEPSOtherGainsLosses",
        "BasicExtraordinary",
        "ContinuingAndDiscontinuedBasicEPS",
        "ContinuingAndDiscontinuedDilutedEPS",
        "CostOfRevenue",
        "DepletionIncomeStatement",
        "DepreciationAmortizationDepletionIncomeStatement",
        "DepreciationAndAmortizationInIncomeStatement",
        "DepreciationIncomeStatement",
        "DilutedAccountingChange",
        "DilutedAverageShares",
        "DilutedContinuousOperations",
        "DilutedDiscontinuousOperations",
        "DilutedEPS",
        "DilutedEPSOtherGainsLosses",
        "DilutedExtraordinary",
        "DilutedNIAvailtoComStockholders",
        "DividendPerShare",
        "EBIT",
        "EBITDA",
        "EarningsFromEquityInterest",
        "EarningsFromEquityInterestNetOfTax",
        "ExciseTaxes",
        "GainOnSaleOfBusiness",
        "GainOnSaleOfPPE",
        "GainOnSaleOfSecurity",
        "GeneralAndAdministrativeExpense",
        "GrossProfit",
        "ImpairmentOfCapitalAssets",
        "InsuranceAndClaims",
        "InterestExpense",
        "InterestExpenseNonOperating",
        "InterestIncome",
        "InterestIncomeNonOperating",
        "MinorityInterests",
        "NetIncome",
        "NetIncomeCommonStockholders",
        "NetIncomeContinuousOperations",
        "NetIncomeDiscontinuousOperations",
        "NetIncomeExtraordinary",
        "NetIncomeFromContinuingAndDiscontinuedOperation",
        "NetIncomeFromContinuingOperationNetMinorityInterest",
        "NetIncomeFromTaxLossCarryforward",
        "NetIncomeIncludingNoncontrollingInterests",
        "NetInterestIncome",
        "NetNonOperatingInterestIncomeExpense",
        "NormalizedBasicEPS",
        "NormalizedDilutedEPS",
        "NormalizedEBITDA",
        "NormalizedIncome",
        "OperatingExpense",
        "OperatingIncome",
        "OperatingRevenue",
        "OtherGandA",
        "OtherIncomeExpense",
        "OtherNonOperatingIncomeExpenses",
        "OtherOperatingExpenses",
        "OtherSpecialCharges",
        "OtherTaxes",
        "OtherunderPreferredStockDividend",
        "PreferredStockDividends",
        "PretaxIncome",
        "ProvisionForDoubtfulAccounts",
        "ReconciledCostOfRevenue",
        "ReconciledDepreciation",
        "RentAndLandingFees",
        "RentExpenseSupplemental",
        "ReportedNormalizedBasicEPS",
        "ReportedNormalizedDilutedEPS",
        "ResearchAndDevelopment",
        "RestructuringAndMergernAcquisition",
        "SalariesAndWages",
        "SecuritiesAmortization",
        "SellingAndMarketingExpense",
        "SellingGeneralAndAdministration",
        "SpecialIncomeCharges",
        "TaxEffectOfUnusualItems",
        "TaxLossCarryforwardBasicEPS",
        "TaxLossCarryforwardDilutedEPS",
        "TaxProvision",
        "TaxRateForCalcs",
        "TotalExpenses",
        "TotalOperatingIncomeAsReported",
        "TotalOtherFinanceCost",
        "TotalRevenue",
        "TotalUnusualItems",
        "TotalUnusualItemsExcludingGoodwill",
        "WriteOff",
    ],
    "balance_sheet"=> [
        "AccountsPayable",
        "AccountsReceivable",
        "AccruedInterestReceivable",
        "AccumulatedDepreciation",
        "AdditionalPaidInCapital",
        "AllowanceForDoubtfulAccountsReceivable",
        "AssetsHeldForSaleCurrent",
        "AvailableForSaleSecurities",
        "BuildingsAndImprovements",
        "CapitalLeaseObligations",
        "CapitalStock",
        "CashAndCashEquivalents",
        "CashCashEquivalentsAndShortTermInvestments",
        "CashEquivalents",
        "CashFinancial",
        "CommercialPaper",
        "CommonStock",
        "CommonStockEquity",
        "ConstructionInProgress",
        "CurrentAccruedExpenses",
        "CurrentAssets",
        "CurrentCapitalLeaseObligation",
        "CurrentDebt",
        "CurrentDebtAndCapitalLeaseObligation",
        "CurrentDeferredAssets",
        "CurrentDeferredLiabilities",
        "CurrentDeferredRevenue",
        "CurrentDeferredTaxesAssets",
        "CurrentDeferredTaxesLiabilities",
        "CurrentLiabilities",
        "CurrentNotesPayable",
        "CurrentProvisions",
        "DefinedPensionBenefit",
        "DerivativeProductLiabilities",
        "DividendsPayable",
        "DuefromRelatedPartiesCurrent",
        "DuefromRelatedPartiesNonCurrent",
        "DuetoRelatedPartiesCurrent",
        "DuetoRelatedPartiesNonCurrent",
        "EmployeeBenefits",
        "FinancialAssets",
        "FinancialAssetsDesignatedasFairValueThroughProfitorLossTotal",
        "FinishedGoods",
        "FixedAssetsRevaluationReserve",
        "ForeignCurrencyTranslationAdjustments",
        "GainsLossesNotAffectingRetainedEarnings",
        "GeneralPartnershipCapital",
        "Goodwill",
        "GoodwillAndOtherIntangibleAssets",
        "GrossAccountsReceivable",
        "GrossPPE",
        "HedgingAssetsCurrent",
        "HeldToMaturitySecurities",
        "IncomeTaxPayable",
        "InterestPayable",
        "InventoriesAdjustmentsAllowances",
        "Inventory",
        "InvestedCapital",
        "InvestmentProperties",
        "InvestmentinFinancialAssets",
        "InvestmentsAndAdvances",
        "InvestmentsInOtherVenturesUnderEquityMethod",
        "InvestmentsinAssociatesatCost",
        "InvestmentsinJointVenturesatCost",
        "InvestmentsinSubsidiariesatCost",
        "LandAndImprovements",
        "Leases",
        "LiabilitiesHeldforSaleNonCurrent",
        "LimitedPartnershipCapital",
        "LineOfCredit",
        "LoansReceivable",
        "LongTermCapitalLeaseObligation",
        "LongTermDebt",
        "LongTermDebtAndCapitalLeaseObligation",
        "LongTermEquityInvestment",
        "LongTermProvisions",
        "MachineryFurnitureEquipment",
        "MinimumPensionLiabilities",
        "MinorityInterest",
        "NetDebt",
        "NetPPE",
        "NetTangibleAssets",
        "NonCurrentAccountsReceivable",
        "NonCurrentAccruedExpenses",
        "NonCurrentDeferredAssets",
        "NonCurrentDeferredLiabilities",
        "NonCurrentDeferredRevenue",
        "NonCurrentDeferredTaxesAssets",
        "NonCurrentDeferredTaxesLiabilities",
        "NonCurrentNoteReceivables",
        "NonCurrentPensionAndOtherPostretirementBenefitPlans",
        "NonCurrentPrepaidAssets",
        "NotesReceivable",
        "OrdinarySharesNumber",
        "OtherCapitalStock",
        "OtherCurrentAssets",
        "OtherCurrentBorrowings",
        "OtherCurrentLiabilities",
        "OtherEquityAdjustments",
        "OtherEquityInterest",
        "OtherIntangibleAssets",
        "OtherInventories",
        "OtherInvestments",
        "OtherNonCurrentAssets",
        "OtherNonCurrentLiabilities",
        "OtherPayable",
        "OtherProperties",
        "OtherReceivables",
        "OtherShortTermInvestments",
        "Payables",
        "PayablesAndAccruedExpenses",
        "PensionandOtherPostRetirementBenefitPlansCurrent",
        "PreferredSecuritiesOutsideStockEquity",
        "PreferredSharesNumber",
        "PreferredStock",
        "PreferredStockEquity",
        "PrepaidAssets",
        "Properties",
        "RawMaterials",
        "Receivables",
        "ReceivablesAdjustmentsAllowances",
        "RestrictedCash",
        "RestrictedCommonStock",
        "RetainedEarnings",
        "ShareIssued",
        "StockholdersEquity",
        "TangibleBookValue",
        "TaxesReceivable",
        "TotalAssets",
        "TotalCapitalization",
        "TotalDebt",
        "TotalEquityGrossMinorityInterest",
        "TotalLiabilitiesNetMinorityInterest",
        "TotalNonCurrentAssets",
        "TotalNonCurrentLiabilitiesNetMinorityInterest",
        "TotalPartnershipCapital",
        "TotalTaxPayable",
        "TradeandOtherPayablesNonCurrent",
        "TradingSecurities",
        "TreasurySharesNumber",
        "TreasuryStock",
        "UnrealizedGainLoss",
        "WorkInProcess",
        "WorkingCapital",
    ],
    "cash_flow"=> [
        "AdjustedGeographySegmentData",
        "AmortizationCashFlow",
        "AmortizationOfIntangibles",
        "AmortizationOfSecurities",
        "AssetImpairmentCharge",
        "BeginningCashPosition",
        "CapitalExpenditure",
        "CapitalExpenditureReported",
        "CashDividendsPaid",
        "CashFlowFromContinuingFinancingActivities",
        "CashFlowFromContinuingInvestingActivities",
        "CashFlowFromContinuingOperatingActivities",
        "CashFlowFromDiscontinuedOperation",
        "CashFlowsfromusedinOperatingActivitiesDirect",
        "CashFromDiscontinuedFinancingActivities",
        "CashFromDiscontinuedInvestingActivities",
        "CashFromDiscontinuedOperatingActivities",
        "ChangeInAccountPayable",
        "ChangeInAccruedExpense",
        "ChangeInCashSupplementalAsReported",
        "ChangeInDividendPayable",
        "ChangeInIncomeTaxPayable",
        "ChangeInInterestPayable",
        "ChangeInInventory",
        "ChangeInOtherCurrentAssets",
        "ChangeInOtherCurrentLiabilities",
        "ChangeInOtherWorkingCapital",
        "ChangeInPayable",
        "ChangeInPayablesAndAccruedExpense",
        "ChangeInPrepaidAssets",
        "ChangeInReceivables",
        "ChangeInTaxPayable",
        "ChangeInWorkingCapital",
        "ChangesInAccountReceivables",
        "ChangesInCash",
        "ClassesofCashPayments",
        "ClassesofCashReceiptsfromOperatingActivities",
        "CommonStockDividendPaid",
        "CommonStockIssuance",
        "CommonStockPayments",
        "DeferredIncomeTax",
        "DeferredTax",
        "Depletion",
        "Depreciation",
        "DepreciationAmortizationDepletion",
        "DepreciationAndAmortization",
        "DividendPaidCFO",
        "DividendReceivedCFO",
        "DividendsPaidDirect",
        "DividendsReceivedCFI",
        "DividendsReceivedDirect",
        "DomesticSales",
        "EarningsLossesFromEquityInvestments",
        "EffectOfExchangeRateChanges",
        "EndCashPosition",
        "ExcessTaxBenefitFromStockBasedCompensation",
        "FinancingCashFlow",
        "ForeignSales",
        "FreeCashFlow",
        "GainLossOnInvestmentSecurities",
        "GainLossOnSaleOfBusiness",
        "GainLossOnSaleOfPPE",
        "IncomeTaxPaidSupplementalData",
        "InterestPaidCFF",
        "InterestPaidCFO",
        "InterestPaidDirect",
        "InterestPaidSupplementalData",
        "InterestReceivedCFI",
        "InterestReceivedCFO",
        "InterestReceivedDirect",
        "InvestingCashFlow",
        "IssuanceOfCapitalStock",
        "IssuanceOfDebt",
        "LongTermDebtIssuance",
        "LongTermDebtPayments",
        "NetBusinessPurchaseAndSale",
        "NetCommonStockIssuance",
        "NetForeignCurrencyExchangeGainLoss",
        "NetIncome",
        "NetIncomeFromContinuingOperations",
        "NetIntangiblesPurchaseAndSale",
        "NetInvestmentPropertiesPurchaseAndSale",
        "NetInvestmentPurchaseAndSale",
        "NetIssuancePaymentsOfDebt",
        "NetLongTermDebtIssuance",
        "NetOtherFinancingCharges",
        "NetOtherInvestingChanges",
        "NetPPEPurchaseAndSale",
        "NetPreferredStockIssuance",
        "NetShortTermDebtIssuance",
        "OperatingCashFlow",
        "OperatingGainsLosses",
        "OtherCashAdjustmentInsideChangeinCash",
        "OtherCashAdjustmentOutsideChangeinCash",
        "OtherCashPaymentsfromOperatingActivities",
        "OtherCashReceiptsfromOperatingActivities",
        "OtherNonCashItems",
        "PaymentsonBehalfofEmployees",
        "PaymentstoSuppliersforGoodsandServices",
        "PensionAndEmployeeBenefitExpense",
        "PreferredStockDividendPaid",
        "PreferredStockIssuance",
        "PreferredStockPayments",
        "ProceedsFromStockOptionExercised",
        "ProvisionandWriteOffofAssets",
        "PurchaseOfBusiness",
        "PurchaseOfIntangibles",
        "PurchaseOfInvestment",
        "PurchaseOfInvestmentProperties",
        "PurchaseOfPPE",
        "ReceiptsfromCustomers",
        "ReceiptsfromGovernmentGrants",
        "RepaymentOfDebt",
        "RepurchaseOfCapitalStock",
        "SaleOfBusiness",
        "SaleOfIntangibles",
        "SaleOfInvestment",
        "SaleOfInvestmentProperties",
        "SaleOfPPE",
        "ShortTermDebtIssuance",
        "ShortTermDebtPayments",
        "StockBasedCompensation",
        "TaxesRefundPaid",
        "TaxesRefundPaidDirect",
        "UnrealizedGainLossOnInvestmentSecurities",
    ],
    "valuation"=> [
        "ForwardPeRatio",
        "PsRatio",
        "PbRatio",
        "EnterprisesValueEBITDARatio",
        "EnterprisesValueRevenueRatio",
        "PeRatio",
        "MarketCap",
        "EnterpriseValue",
        "PegRatio"
    ]
)

_Fundamental_Intervals = [
    "annual",
    "quarterly",
    "monthly",
]


"""
        get_Fundamental(symbol::AbstractString, item::AbstractString,interval::AbstractString, startdt, enddt)
    
    Retrievs financial statement information from Yahoo Finance stored in a Dictionary.

    # Arguments

      * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

      * item`::String` can either be an entire financial statement or a subitem. Entire financial statements:"income_statement", "valuation", "cash_flow", "balance_sheet".  To see valid sub items grouped by financial statement type in a Dictionary call `_Fundamental_Types`  

      * interval`::String` can be one of "annual", "quarterly", "monthly"  

      * `startdt` and `enddt` take the following types: `::Date`,`::DateTime`, or a `String` of the following form `yyyy-mm-dd`  
    
    # Examples
    ```julia-repl
    julia> get_Fundamental("NFLX", "income_statement","quarterly","2000-01-01","2022-12-31")
    
    Dict{String, Any} with 39 entries:
    "NetNonOperatingInterestIncomeExpense" => Any[-94294000, -80917000, 8066000, 44771000, 88829000]
    "NetInterestIncome"                    => Any[-94294000, -80917000, 8066000, 44771000, 88829000]
    "InterestExpense"                      => Any[190429000, 189429000, 187579000, 175455000, 172575000]
    ⋮                                      => ⋮

    julia> get_Fundamental("AAPL", "InterestExpense","quarterly","2000-01-01","2022-12-31") |> DataFrame
    5×2 DataFrame
    Row │ InterestExpense  timestamp
        │ Any              DateTime
    ────┼──────────────────────────────────────
      1 │ 672000000        2021-09-30T00:00:00 
      2 │ 694000000        2021-12-31T00:00:00
      3 │ 691000000        2022-03-31T00:00:00
      4 │ 719000000        2022-06-30T00:00:00
      5 │ 827000000        2022-09-30T00:00:00
    ```
    """
function get_Fundamental(symbol::AbstractString, item::AbstractString,interval::AbstractString, startdt, enddt)
    # Check Start and end dates. 
    if !isequal(startdt,"") || !isequal(enddt,"")
        range = ""
        if typeof(startdt) <: Date
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(startdt))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(enddt))))
        elseif typeof(startdt) <:DateTime
            startdt = Int(round(Dates.datetime2unix(startdt)))
            enddt = Int(round(Dates.datetime2unix(enddt)))
        elseif typeof(startdt) <: AbstractString
            startdt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(startdt,Dates.DateFormat("yyyy-mm-dd"))))))
            enddt = Int(round(Dates.datetime2unix(Dates.DateTime(Dates.Date(enddt,Dates.DateFormat("yyyy-mm-dd"))))))
        else
            error("Startdt and Enddt must be either a Date, a DateTime, or a string of the following format yyyy-mm-dd!")
        end
    end
    @assert in(interval, _Fundamental_Intervals) "Chosen interval is not supported. Choose one of: annual, quarterly, monthly"
    #Build Query:
    if in(item, keys(_Fundamental_Types))
        entire_statement = true
        query_items = join(string.(interval,_Fundamental_Types[item]),",")
    else
        entire_statement = false
        @assert in(item, vcat([_Fundamental_Types[i] for i in keys(_Fundamental_Types)]...)) "Chosen item is not supported. View supported items by calling _Fundamental_Types"
        query_items = string(interval, item)
    end
    q = Dict(
        "symbol"=>symbol,
        "type" => query_items,
        "period1"=>startdt,
        "period2"=>enddt,
        "formatted" => "false"
    )  
    url = "https://query2.finance.yahoo.com/ws/fundamentals-timeseries/v1/finance/timeseries/$(symbol)"
    res = HTTP.get(url,query = q)
    res = JSON3.read(res.body).timeseries.result
    if entire_statement
        result = Dict{String,Any}()
        for i in eachindex(res)
            #continue if there is no data for this element
            if !in(:timestamp,keys(res[i]))
                continue
            end
            unix2datetime.(res[i].timestamp)
            k = res[i].meta.type[1]
            element_result = []
            for j in values(res[i][Symbol(k)])
                push!(element_result,j.reportedValue.raw)
            end
            result[replace(k,r"^(quarterly|annual|monthly)"=>"")] = element_result
        end
    else
        if !in(Symbol(query_items),keys(res[1]))
            error("There is no data available for this item.")
        else
            value = []
            for i in values(res[1][Symbol(query_items)])
                push!(value, i.reportedValue.raw)
            end

            result = Dict("timestamp" => unix2datetime.(res[1].timestamp),item =>value)
        end             
    end
    return result
end


# Get Options Data:

"""
        get_Options(symbol::String)
    
    Retrievs options data from Yahoo Finance stored in a Dictionary with two items. One contains Call options the other Put options. These subitems are dictionaries themselves.
    The call and put options Dictionaries can readily be transformed to a DataFrame.

    # Arguments

      * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

    # Examples  
    ```julia-repl
    julia> get_Options("AAPL")
    Dict{String, Dict{String, Vector{Any}}} with 2 entries:
    "calls" => Dict("percentChange"=>[ -2.90804  …   0], "expiration"=>[DateTime("2022-12-09T00:…  
    "puts"  => Dict("percentChange"=>[0,  …   0], "expiration"=>[DateTime("2022-12-09T00:00:00"), DateTime("20…

 
    julia> get_Options("AAPL")["calls"] |> DataFrame
    65×16 DataFrame
    Row │ ask    bid    change     contractSize  contractSymbol       currency  exp ⋯
        │ Any    Any    Any        Any           Any                  Any       Any ⋯
    ────┼────────────────────────────────────────────────────────────────────────────
      1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD       202 ⋯
      2 │ 84.3   84.15  0          REGULAR       AAPL221209C00060000  USD       202  
     ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮              ⋮          ⋱  
     64 │ 0.01   0      0          REGULAR       AAPL221209C00240000  USD       202  
     65 │ 0      0      0          REGULAR       AAPL221209C00250000  USD       202  
                                                       10 columns and 61 rows omitted
    
    
    julia> data  = get_Options("AAPL")
    julia> vcat( [DataFrame(i) for i in values(data)]...)
    124×16 DataFrame
    Row │ ask    bid    change     contractSize  contractSymbol       cur ⋯
        │ Any    Any    Any        Any           Any                  Any ⋯
    ────┼──────────────────────────────────────────────────────────────────
      1 │ 94.3   94.1   0          REGULAR       AAPL221209C00050000  USD ⋯
      2 │ 84.55  84.35  0          REGULAR       AAPL221209C00060000  USD  
     ⋮  │   ⋮      ⋮        ⋮           ⋮                 ⋮               ⋱ 
    123 │ 75.85  75.15  0          REGULAR       AAPL221209P00220000  USD  
    124 │ 85.85  85.15  0          REGULAR       AAPL221209P00230000  USD  
                                            11 columns and 120 rows omitted
    ```
    """
function get_Options(symbol::String)
    res = HTTP.get("https://query2.finance.yahoo.com/v7/finance/options/$(symbol)",query = Dict("formatted"=>"false"))    
    res = JSON3.read(res.body)
    puts = res.optionChain.result[1].options[1].puts
    calls = res.optionChain.result[1].options[1].calls
    res_p = Dict(
        "contractSymbol"=> [],
        "strike"=> [],
        "currency"=> [],
        "lastPrice"=> [],
        "change"=> [],
        "percentChange"=> [],
        "volume"=> [],
        "openInterest"=> [],
        "bid"=> [],
        "ask"=> [],
        "contractSize"=> [],
        "expiration"=> [],
        "lastTradeDate"=> [],
        "impliedVolatility"=> [],
        "inTheMoney"=> []
        )
    res_c = Dict(
        "contractSymbol"=> [],
        "strike"=> [],
        "currency"=> [],
        "lastPrice"=> [],
        "change"=> [],
        "percentChange"=> [],
        "volume"=> [],
        "openInterest"=> [],
        "bid"=> [],
        "ask"=> [],
        "contractSize"=> [],
        "expiration"=> [],
        "lastTradeDate"=> [],
        "impliedVolatility"=> [],
        "inTheMoney"=> []
        )

    for i in eachindex(puts)
        for j in keys(res_p)
            if !in(j, keys(puts[i]))
                push!(res_p[j], missing)
            else
                if in(j, ["expiration","lastTradeDate"])
                push!(res_p[j], unix2datetime(puts[i][j]))
                else
                    push!(res_p[j], puts[i][j])
                end
            end
        end
    end
    for i in eachindex(calls)
        for j in keys(res_c)
            if !in(j, keys(calls[i]))
                push!(res_c[j], missing)
            else
                if in(j, ["expiration","lastTradeDate"])
                    push!(res_c[j], unix2datetime(calls[i][j]))
                    else
                        push!(res_c[j], calls[i][j])
                    end
            end
        end
    end
    res_c["type"] = repeat(["call"], length(res_c["strike"]))
    res_p["type"] = repeat(["put"], length(res_p["strike"]))
    return Dict("calls" => res_c, "puts" => res_p)
end





"""
        get_ESG(symbol::String)
    
    Retrievs ESG Scores from Yahoo Finance stored in a Dictionary with two items. One, `score`, contains the companies ESG scores and individal Overall, Environment, Social and  Goverance Scores as well as a timestamp of type `DateTime`.
    The other,  `peer_score`, contains the peer group's scores. The subdictionaries can be transformed to `DataFrames`

    # Arguments

      * smybol`::String` is a ticker (e.g. AAPL for Apple Computers, or ^GSPC for the S&P500)  

    # Examples
    ```julia-repl
    julia> get_ESG("AAPL")
    Dict{String, Dict{String, Any}} with 2 entries:
    "peer_score" => Dict("governanceScore"=>Union{Missing, Float64}[63.2545, 63.454…  
    "score"      => Dict("governanceScore"=>Union{Missing, Real}[62, 62, 62, 62, 62… 
   
    julia> get_ESG("AAPL")["score"] |> DataFrame
    96×6 DataFrame
    Row │ environmentScore  esgScore    governanceScore  socialScore  symbol  times ⋯
        │ Real?             Real?       Real?            Real?        String  DateT ⋯
    ────┼────────────────────────────────────────────────────────────────────────────
      1 │            74          61               62           45     AAPL    2014- ⋯
      2 │            74          60               62           45     AAPL    2014-  
     ⋮  │        ⋮              ⋮              ⋮              ⋮         ⋮           ⋱
     95 │       missing     missing          missing      missing     AAPL    2022-  
     96 │             0.65       16.68             9.18         6.86  AAPL    2022-  
                                                         1 column and 92 rows omitted
    ```
    """
function get_ESG(symbol::String)
    q = Dict("symbol" =>symbol)
    function nothingtomissing(x::Any)
        return x
    end
    function nothingtomissing(x::Nothing)
        return missing
    end    
    res = HTTP.get("https://query2.finance.yahoo.com/v1/finance/esgChart",query =q )   
    res = JSON3.read(res.body)
    res = res.esgChart.result[1]
    self = Dict(
        "symbol" => symbol,
        "timestamp"=>unix2datetime.(res.symbolSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.symbolSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.symbolSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.symbolSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.symbolSeries.socialScore))
    peers = Dict(
        "symbol" => res.peerGroup,
        "timestamp"=>unix2datetime.(res.peerSeries.timestamp),
        "esgScore"=>nothingtomissing.(res.peerSeries.esgScore),
        "governanceScore"=>nothingtomissing.(res.peerSeries.governanceScore),
        "environmentScore"=>nothingtomissing.(res.peerSeries.environmentScore),
        "socialScore"=>nothingtomissing.(res.peerSeries.socialScore))
    return Dict("score" =>self,"peer_score"=>peers)
end



# #Maybe implement in the future
# "esg_peer_scores"
#     url "https://query2.finance.yahoo.com/v1/finance/esgPeerScores"
#      query symbol