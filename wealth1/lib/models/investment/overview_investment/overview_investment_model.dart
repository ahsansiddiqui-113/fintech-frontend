// Models
class ChartResponse {
  final bool status;
  final String message;
  final ChartBody body;

  ChartResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) {
    return ChartResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      body: ChartBody.fromJson(json['body'] ?? {}),
    );
  }
}

class ChartBody {
  final List<ChartData> crypto;
  final List<ChartData> stocks;
  final List<ChartData> funds;
  final List<ChartData> others;
  final List<ChartData> overview;
  final double totalInvestCrypto;
  final double totalInvestStocks;
  final double totalInvestFunds;
  final double totalInvestOthers;
  final double totalInvestOverview;
  final double percentageChangeCrypto;
  final double percentageChangeStocks;
  final double percentageChangeFunds;
  final double percentageChangeOthers;
  final double percentageChangeOverview;

  ChartBody({
    required this.crypto,
    required this.stocks,
    required this.funds,
    required this.others,
    required this.overview,
    required this.totalInvestCrypto,
    required this.totalInvestStocks,
    required this.totalInvestFunds,
    required this.totalInvestOthers,
    required this.totalInvestOverview,
    required this.percentageChangeCrypto,
    required this.percentageChangeStocks,
    required this.percentageChangeFunds,
    required this.percentageChangeOthers,
    required this.percentageChangeOverview,
  });

  factory ChartBody.fromJson(Map<String, dynamic> json) {
    return ChartBody(
      crypto: (json['crypto'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      stocks: (json['stocks'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      funds: (json['funds'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      others: (json['others'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      overview: (json['overview'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      totalInvestCrypto:
          (json['totalInvestment_crypto'] as num?)?.toDouble() ?? 0.0,
      totalInvestStocks:
          (json['totalInvestment_stocks'] as num?)?.toDouble() ?? 0.0,
      totalInvestFunds:
          (json['totalInvestment_funds'] as num?)?.toDouble() ?? 0.0,
      totalInvestOthers:
          (json['totalInvestment_others'] as num?)?.toDouble() ?? 0.0,
      totalInvestOverview:
          (json['totalInvestment_overview'] as num?)?.toDouble() ?? 0.0,
      percentageChangeCrypto:
          (json['percentageChange_crypto'] as num?)?.toDouble() ?? 0.0,
      percentageChangeStocks:
          (json['percentageChange_stocks'] as num?)?.toDouble() ?? 0.0,
      percentageChangeFunds:
          (json['percentageChange_funds'] as num?)?.toDouble() ?? 0.0,
      percentageChangeOthers:
          (json['percentageChange_others'] as num?)?.toDouble() ?? 0.0,
      percentageChangeOverview:
          (json['percentageChange_overview'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChartData {
  final String monthName;
  final double total;

  ChartData({
    required this.monthName,
    required this.total,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      monthName: json['date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
