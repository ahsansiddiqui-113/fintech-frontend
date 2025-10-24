class NetWorthResponse {
  final bool? status;
  final String? message;
  final NetWorthBody? body;

  NetWorthResponse({
    this.status,
    this.message,
    this.body,
  });

  factory NetWorthResponse.fromJson(Map<String, dynamic> json) {
    return NetWorthResponse(
      status: json['status'],
      message: json['message'],
      body: json['body'] != null ? NetWorthBody.fromJson(json['body']) : null,
    );
  }
}

class NetWorthBody {
  final double? totalNetWorth;
  final double? totalAssets;
  final double? totalLiabilities;
  final String? totalAssetsPercentage;
  final String? totalLiabilitiesPercentage;
  final String? percentageChange;
  final List<Asset>? assets;
  final List<Liability>? liabilities;
  final List<HistoricalTrend>? historicalTrend;

  NetWorthBody({
    this.totalNetWorth,
    this.totalAssets,
    this.totalLiabilities,
    this.totalAssetsPercentage,
    this.totalLiabilitiesPercentage,
    this.percentageChange,
    this.assets,
    this.liabilities,
    this.historicalTrend,
  });

  factory NetWorthBody.fromJson(Map<String, dynamic> json) {
    return NetWorthBody(
      totalNetWorth: (json['totalNetWorth'] as num?)?.toDouble(),
      totalAssets: (json['totalAssets'] as num?)?.toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble(),
      totalAssetsPercentage: json['totalAssetsPercentage'],
      totalLiabilitiesPercentage: json['totalLiabilitiesPercentage'],
      percentageChange: json['percentageChange'],
      assets: (json['assets'] as List?)?.map((e) => Asset.fromJson(e)).toList(),
      liabilities: (json['liabilities'] as List?)
          ?.map((e) => Liability.fromJson(e))
          .toList(),
      historicalTrend: (json['historicalTrend'] as List?)
          ?.map((e) => HistoricalTrend.fromJson(e))
          .toList(),
    );
  }
}

class Asset {
  final String? accountId;
  final String? name;
  final String? type;
  final String? subtype;
  final double? currentBalance;
  final double? availableBalance;
  final String? isoCurrencyCode;
  final String? mask;
  final String? officialName;
  final double? amount;
  final String? percentage;
  final String? bankName;
  final String? bankLogo;
  final String? accountNumber;

  Asset({
    this.accountId,
    this.name,
    this.type,
    this.subtype,
    this.currentBalance,
    this.availableBalance,
    this.isoCurrencyCode,
    this.mask,
    this.officialName,
    this.amount,
    this.percentage,
    this.bankName,
    this.bankLogo,
    this.accountNumber,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      accountId: json['accountId'],
      name: json['name'],
      type: json['type'],
      subtype: json['subtype'],
      currentBalance: (json['currentBalance'] as num?)?.toDouble(),
      availableBalance: (json['availableBalance'] as num?)?.toDouble(),
      isoCurrencyCode: json['isoCurrencyCode'],
      mask: json['mask'],
      officialName: json['officialName'],
      amount: (json['amount'] as num?)?.toDouble(),
      percentage: json['percentage'],
      bankName: json['bankName'],
      bankLogo: json['bankLogo'],
      accountNumber: json['accountNumber'],
    );
  }
}

class Liability {
  final String? type;
  final String? name;
  final double? amount;
  final String? percentage;
  final String? accountId;
  final String? bankName;
  final String? bankLogo;
  final String? accountNumber;

  Liability({
    this.type,
    this.name,
    this.amount,
    this.percentage,
    this.accountId,
    this.bankName,
    this.bankLogo,
    this.accountNumber,
  });

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      type: json['type'],
      name: json['name'],
      amount: (json['amount'] as num?)?.toDouble(),
      percentage: json['percentage'],
      accountId: json['accountId'],
      bankName: json['bankName'],
      bankLogo: json['bankLogo'],
      accountNumber: json['accountNumber'],
    );
  }
}

class HistoricalTrend {
  final String? id;
  final int? year;
  final double? value;

  HistoricalTrend({
    this.id,
    this.year,
    this.value,
  });

  factory HistoricalTrend.fromJson(Map<String, dynamic> json) {
    return HistoricalTrend(
      id: json['_id'],
      year: json['year'],
      value: (json['value'] as num?)?.toDouble(),
    );
  }
}
