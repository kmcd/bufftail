afl = '
#include "C:\Program Files\AmiBroker\Formulas\Systems\STRATEGY_AFL.afl"

Buy = Buy && VOLATILITY_FILTER ;

// Optimisations from WFA

AddTextColumn("BUY", "Entry" );
#include <entry_signals.afl>
'

project = '
<?xml version="1.0" encoding="ISO-8859-1"?>
<AmiBroker-Analysis CompactMode="0">
<General>
<FormatVersion>1</FormatVersion>
<Symbol>@TU#C</Symbol>
<FormulaPath>Formulas\\Signals\\PROJECT_AFL.afl</FormulaPath>
<ApplyTo>2</ApplyTo>
<RangeType>1</RangeType>
<RangeAmount>1</RangeAmount>
<FromDate>1/1/2011 00:00:00</FromDate>
<ToDate>1/1/2012</ToDate>
<SyncOnSelect>0</SyncOnSelect>
<RunEvery>0</RunEvery>
<RunEveryInterval>5min</RunEveryInterval>
<IncludeFilter>
<ExcludeMode>0</ExcludeMode>
<MarketID>-1</MarketID>
<GroupID>-1</GroupID>
<SectorID>-1</SectorID>
<IndustryID>-1</IndustryID>
<WatchListID>76</WatchListID>
<Favourite>0</Favourite>
<Index>0</Index>
<GICSID>-1</GICSID>
<ICBID>-1</ICBID>
</IncludeFilter>
<ExcludeFilter>
<ExcludeMode>1</ExcludeMode>
<MarketID>-1</MarketID>
<GroupID>-1</GroupID>
<SectorID>-1</SectorID>
<IndustryID>-1</IndustryID>
<WatchListID>-1</WatchListID>
<Favourite>0</Favourite>
<Index>0</Index>
<GICSID>-1</GICSID>
<ICBID>-1</ICBID>
</ExcludeFilter>
</General>
<BacktestSettings>
<InitialEquity>10000</InitialEquity>
<TradeFlags>3</TradeFlags>
<MaxLossStopMode>0</MaxLossStopMode>
<MaxLossStopValue>0</MaxLossStopValue>
<MaxLossStopAtStop>0</MaxLossStopAtStop>
<ProfitStopMode>0</ProfitStopMode>
<ProfitStopValue>0</ProfitStopValue>
<ProfitStopAtStop>0</ProfitStopAtStop>
<TrailingStopMode>0</TrailingStopMode>
<TrailingStopPeriods>0</TrailingStopPeriods>
<TrailingStopValue>0</TrailingStopValue>
<TrailingStopAtStop>0</TrailingStopAtStop>
<CommissionMode>3</CommissionMode>
<CommissionValue>2.15</CommissionValue>
<BuyPriceField>0</BuyPriceField>
<BuyDelay>0</BuyDelay>
<SellPriceField>0</SellPriceField>
<SellDelay>0</SellDelay>
<ShortPriceField>0</ShortPriceField>
<ShortDelay>0</ShortDelay>
<CoverPriceField>0</CoverPriceField>
<CoverDelay>0</CoverDelay>
<ReportSystemFormula>0</ReportSystemFormula>
<ReportSystemSettings>0</ReportSystemSettings>
<ReportOverallSummary>1</ReportOverallSummary>
<ReportSummary>1</ReportSummary>
<ReportTradeList>1</ReportTradeList>
<LoadRemainingQuotes>1</LoadRemainingQuotes>
<Periodicity>0</Periodicity>
<InterestRate>0</InterestRate>
<ReportOutPositions>1</ReportOutPositions>
<UseConstantPriceArrays>0</UseConstantPriceArrays>
<PointsOnlyTest>1</PointsOnlyTest>
<AllowShrinkingPosition>0</AllowShrinkingPosition>
<RangeType>1</RangeType>
<RangeLength>0</RangeLength>
<RangeFromDate>1/1/2011 00:00:00</RangeFromDate>
<RangeToDate>1/1/2012</RangeToDate>
<ApplyTo>2</ApplyTo>
<FilterQty>2</FilterQty>
<IncludeFilter>
<ExcludeMode>0</ExcludeMode>
<MarketID>-1</MarketID>
<GroupID>-1</GroupID>
<SectorID>-1</SectorID>
<IndustryID>-1</IndustryID>
<WatchListID>76</WatchListID>
<Favourite>0</Favourite>
<Index>0</Index>
<GICSID>-1</GICSID>
<ICBID>-1</ICBID>
</IncludeFilter>
<ExcludeFilter>
<ExcludeMode>1</ExcludeMode>
<MarketID>-1</MarketID>
<GroupID>-1</GroupID>
<SectorID>-1</SectorID>
<IndustryID>-1</IndustryID>
<WatchListID>-1</WatchListID>
<Favourite>0</Favourite>
<Index>0</Index>
<GICSID>-1</GICSID>
<ICBID>-1</ICBID>
</ExcludeFilter>
<UseOptimizedEvaluation>0</UseOptimizedEvaluation>
<BacktestRangeType>3</BacktestRangeType>
<BacktestRangeLength>6</BacktestRangeLength>
<BacktestRangeFromDate>1/1/2009 00:00:00</BacktestRangeFromDate>
<BacktestRangeToDate>1/1/2010</BacktestRangeToDate>
<MarginRequirement>100</MarginRequirement>
<SameDayStops>0</SameDayStops>
<RoundLotSize>1</RoundLotSize>
<TickSize>0</TickSize>
<DrawdownPriceField>0</DrawdownPriceField>
<ReverseSignalForcesExit>0</ReverseSignalForcesExit>
<NoDefaultColumns>0</NoDefaultColumns>
<AllowSameBarExit>0</AllowSameBarExit>
<ExtensiveOptimizationWarning>0</ExtensiveOptimizationWarning>
<WaitForBackfill>0</WaitForBackfill>
<MaxRanked>4</MaxRanked>
<MaxTraded>1</MaxTraded>
<MaxTracked>100</MaxTracked>
<PortfolioReportMode>0</PortfolioReportMode>
<MinShares>1</MinShares>
<SharpeRiskFreeReturn>5</SharpeRiskFreeReturn>
<PortfolioMode>0</PortfolioMode>
<PriceBoundCheck>1</PriceBoundCheck>
<AlignToReferenceSymbol>0</AlignToReferenceSymbol>
<ReferenceSymbol>^DJI</ReferenceSymbol>
<UPIRiskFreeReturn>5.4</UPIRiskFreeReturn>
<NBarStopMode>0</NBarStopMode>
<NBarStopValue>0</NBarStopValue>
<NBarStopReentryDelay>0</NBarStopReentryDelay>
<MaxLossStopReentryDelay>0</MaxLossStopReentryDelay>
<ProfitStopReentryDelay>0</ProfitStopReentryDelay>
<TrailingStopReentryDelay>0</TrailingStopReentryDelay>
<AddFutureBars>0</AddFutureBars>
<DistChartSpacing>5</DistChartSpacing>
<ProfitDistribution>1</ProfitDistribution>
<MAFEDistribution>1</MAFEDistribution>
<IndividualDetailedReports>0</IndividualDetailedReports>
<PortfolioReportTradeList>1</PortfolioReportTradeList>
<LimitTradeSizeAsPctVol>10</LimitTradeSizeAsPctVol>
<DisableSizeLimitWhenVolumeIsZero>1</DisableSizeLimitWhenVolumeIsZero>
<UsePrevBarEquityForPosSizing>0</UsePrevBarEquityForPosSizing>
<NBarStopHasPriority>0</NBarStopHasPriority>
<UseCustomBacktestProc>0</UseCustomBacktestProc>
<CustomBacktestProcFormulaPath>C:\Program Files\AmiBroker\Formulas\Custom\expectancy.afl</CustomBacktestProcFormulaPath>
<MinPosValue>1</MinPosValue>
<MaxPosValue>0</MaxPosValue>
<ChartInterval>86400</ChartInterval>
<DisableRuinStop>0</DisableRuinStop>
<OptTarget>K-Ratio</OptTarget>
<WFMode>1</WFMode>
<GenerateReport>0</GenerateReport>
<MaxLongPos>0</MaxLongPos>
<MaxShortPos>0</MaxShortPos>
<SeparateLongShortRank>0</SeparateLongShortRank>
<TotalSymbolQty>100</TotalSymbolQty>
<EnableUserReportCharts>1</EnableUserReportCharts>
<ChartWidth>500</ChartWidth>
<ChartHeight>300</ChartHeight>
<SettlementDelay>0</SettlementDelay>
</BacktestSettings>
</AmiBroker-Analysis>
'

strategies = {
  CH_L:'channel_long',
  CH_CTL:'channel_CT_long'
  MA_L:'kma_long',
  MO_L:'momentum_long',
  OS_L:'oscillator_long',
  OS_CTL:'oscillator_CT_long',
  RT_CTL:'runs_test_CT_long',
  RT_L:'runs_test_long',
  SP_L:'spread_long',
  SP_CTL:'spread_CT_long',
  TR_CTL:'trend_CT_long',
  TR_L:'trend_long',
  ZS_CTL:'zscore_long',
  ZS_L:'zscore_CT_long',
}

# Create files for each strategy & volatility bound
strategies.each do |id,strategy_afl_location|
  afl_code = afl.gsub /STRATEGY_AFL/, strategy_afl_location
  project_code = project.gsub(/PROJECT_AFL/, id.to_s)
  
  afl_file = id.to_s + '.afl'
  project_file = id.to_s + '.apx'
  
  File.open(afl_file,'w') {|_| _.puts afl_code }
  File.open(project_file,'w') {|_| _.puts project_code }
end
