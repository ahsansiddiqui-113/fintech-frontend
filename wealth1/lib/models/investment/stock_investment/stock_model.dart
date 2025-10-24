class CompanyOverview {
  final String? symbol;
  final String? assetType;
  final String? name;
  final String? description;
  final String? cik;
  final String? exchange;
  final String? currency;
  final String? country;
  final String? sector;
  final String? industry;
  final String? address;
  final String? officialSite;
  final String? fiscalYearEnd;
  final String? latestQuarter;
  final String? marketCapitalization;
  final String? ebitda;
  final String? peRatio;
  final String? pegRatio;
  final String? bookValue;
  final String? dividendPerShare;
  final String? dividendYield;
  final String? eps;
  final String? revenuePerShareTTM;
  final String? profitMargin;
  final String? operatingMarginTTM;
  final String? returnOnAssetsTTM;
  final String? returnOnEquityTTM;
  final String? revenueTTM;
  final String? grossProfitTTM;
  final String? dilutedEPSTTM;
  final String? quarterlyEarningsGrowthYOY;
  final String? quarterlyRevenueGrowthYOY;
  final String? analystTargetPrice;
  final String? analystRatingStrongBuy;
  final String? analystRatingBuy;
  final String? analystRatingHold;
  final String? analystRatingSell;
  final String? analystRatingStrongSell;
  final String? trailingPE;
  final String? forwardPE;
  final String? priceToSalesRatioTTM;
  final String? priceToBookRatio;
  final String? evToRevenue;
  final String? evToEbitda;
  final String? beta;
  final String? week52High;
  final String? week52Low;
  final String? day50MovingAverage;
  final String? day200MovingAverage;
  final String? sharesOutstanding;
  final String? dividendDate;
  final String? exDividendDate;

  CompanyOverview({
    this.symbol,
    this.assetType,
    this.name,
    this.description,
    this.cik,
    this.exchange,
    this.currency,
    this.country,
    this.sector,
    this.industry,
    this.address,
    this.officialSite,
    this.fiscalYearEnd,
    this.latestQuarter,
    this.marketCapitalization,
    this.ebitda,
    this.peRatio,
    this.pegRatio,
    this.bookValue,
    this.dividendPerShare,
    this.dividendYield,
    this.eps,
    this.revenuePerShareTTM,
    this.profitMargin,
    this.operatingMarginTTM,
    this.returnOnAssetsTTM,
    this.returnOnEquityTTM,
    this.revenueTTM,
    this.grossProfitTTM,
    this.dilutedEPSTTM,
    this.quarterlyEarningsGrowthYOY,
    this.quarterlyRevenueGrowthYOY,
    this.analystTargetPrice,
    this.analystRatingStrongBuy,
    this.analystRatingBuy,
    this.analystRatingHold,
    this.analystRatingSell,
    this.analystRatingStrongSell,
    this.trailingPE,
    this.forwardPE,
    this.priceToSalesRatioTTM,
    this.priceToBookRatio,
    this.evToRevenue,
    this.evToEbitda,
    this.beta,
    this.week52High,
    this.week52Low,
    this.day50MovingAverage,
    this.day200MovingAverage,
    this.sharesOutstanding,
    this.dividendDate,
    this.exDividendDate,
  });

  factory CompanyOverview.fromJson(Map<String?, dynamic> json) {
    return CompanyOverview(
      symbol: json['Symbol'] ?? '',
      assetType: json['AssetType'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      cik: json['CIK'] ?? '',
      exchange: json['Exchange'] ?? '',
      currency: json['Currency'] ?? '',
      country: json['Country'] ?? '',
      sector: json['Sector'] ?? '',
      industry: json['Industry'] ?? '',
      address: json['Address'] ?? '',
      officialSite: json['OfficialSite'] ?? '',
      fiscalYearEnd: json['FiscalYearEnd'] ?? '',
      latestQuarter: json['LatestQuarter'] ?? '',
      marketCapitalization: json['MarketCapitalization'] ?? '',
      ebitda: json['EBITDA'] ?? '',
      peRatio: json['PERatio'] ?? '',
      pegRatio: json['PEGRatio'] ?? '',
      bookValue: json['BookValue'] ?? '',
      dividendPerShare: json['DividendPerShare'] ?? '',
      dividendYield: json['DividendYield'] ?? '',
      eps: json['EPS'] ?? '',
      revenuePerShareTTM: json['RevenuePerShareTTM'] ?? '',
      profitMargin: json['ProfitMargin'] ?? '',
      operatingMarginTTM: json['OperatingMarginTTM'] ?? '',
      returnOnAssetsTTM: json['ReturnOnAssetsTTM'] ?? '',
      returnOnEquityTTM: json['ReturnOnEquityTTM'] ?? '',
      revenueTTM: json['RevenueTTM'] ?? '',
      grossProfitTTM: json['GrossProfitTTM'] ?? '',
      dilutedEPSTTM: json['DilutedEPSTTM'] ?? '',
      quarterlyEarningsGrowthYOY: json['QuarterlyEarningsGrowthYOY'] ?? '',
      quarterlyRevenueGrowthYOY: json['QuarterlyRevenueGrowthYOY'] ?? '',
      analystTargetPrice: json['AnalystTargetPrice'] ?? '',
      analystRatingStrongBuy: json['AnalystRatingStrongBuy'] ?? 0,
      analystRatingBuy: json['AnalystRatingBuy'] ?? 0,
      analystRatingHold: json['AnalystRatingHold'] ?? 0,
      analystRatingSell: json['AnalystRatingSell'] ?? 0,
      analystRatingStrongSell: json['AnalystRatingStrongSell'] ?? 0,
      trailingPE: json['TrailingPE'] ?? '',
      forwardPE: json['ForwardPE'] ?? '',
      priceToSalesRatioTTM: json['PriceToSalesRatioTTM'] ?? '',
      priceToBookRatio: json['PriceToBookRatio'] ?? '',
      evToRevenue: json['EVToRevenue'] ?? '',
      evToEbitda: json['EVToEBITDA'] ?? '',
      beta: json['Beta'] ?? '',
      week52High: json['52WeekHigh'] ?? '',
      week52Low: json['52WeekLow'] ?? '',
      day50MovingAverage: json['50DayMovingAverage'] ?? '',
      day200MovingAverage: json['200DayMovingAverage'] ?? '',
      sharesOutstanding: json['SharesOutstanding'] ?? '',
      dividendDate: json['DividendDate'] ?? '',
      exDividendDate: json['ExDividendDate'] ?? '',
    );
  }
}
