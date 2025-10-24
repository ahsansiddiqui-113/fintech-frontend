class NetWorthData {
  final double totalNetWorth;
  final double totalAssets;
  final double totalLiabilities;
  final List<Asset> assets;
  final List<Liability> liabilities;
  final List<HistoricalData> historicalTrend;

  NetWorthData({
    required this.totalNetWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.assets,
    required this.liabilities,
    required this.historicalTrend,
  });

  factory NetWorthData.fromJson(Map<String, dynamic> json) {
    return NetWorthData(
      totalNetWorth: (json['totalNetWorth'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num).toDouble(),
      assets: (json['assets'] as List)
          .map((asset) => Asset.fromJson(asset as Map<String, dynamic>))
          .toList(),
      liabilities: (json['liabilities'] as List)
          .map((liability) =>
              Liability.fromJson(liability as Map<String, dynamic>))
          .toList(),
      historicalTrend: (json['historicalTrend'] as List)
          .map(
              (trend) => HistoricalData.fromJson(trend as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNetWorth': totalNetWorth,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'liabilities':
          liabilities.map((liability) => liability.toJson()).toList(),
      'historicalTrend':
          historicalTrend.map((trend) => trend.toJson()).toList(),
    };
  }
}

class Asset {
  final String type;
  final double amount;
  final String percentage;

  Asset({
    required this.type,
    required this.amount,
    required this.percentage,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: json['percentage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

class Liability {
  final String type;
  final double amount;
  final String percentage;

  Liability({
    required this.type,
    required this.amount,
    required this.percentage,
  });

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: json['percentage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

class HistoricalData {
  final int year;
  final double value;

  HistoricalData({
    required this.year,
    required this.value,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    return HistoricalData(
      year: json['year'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'value': value,
    };
  }
}
