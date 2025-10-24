class InvestmentOverview {
  final bool? status;
  final String? message;
  final List<OverviewBody>? body;

  InvestmentOverview({
    this.status,
    this.message,
    this.body,
  });

  factory InvestmentOverview.fromJson(Map<String, dynamic> json) =>
      InvestmentOverview(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null
            ? []
            : List<OverviewBody>.from(
                json["body"]!.map((x) => OverviewBody.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body == null
            ? []
            : List<dynamic>.from(body!.map((x) => x.toJson())),
      };
}

class OverviewBody {
  final List<CryptoModel>? crypto;
  final List<CryptoModel>? stocks;
  final List<CryptoModel>? funds;
  final List<CryptoModel>? others;
  final double? cryptoTotal;
  final double? cryptoChange24HPercent;
  final double? stocksTotal;
  final double? stocksChange24HPercent;
  final double? fundsTotal;
  final double? fundsChange24HPercent;
  final double? othersTotal;
  final double? otherChange24HPercent;
  final double? totalInvestments;
  final double? totalInvestmentChange24HPercent;
  final String? id;

  OverviewBody({
    this.crypto,
    this.stocks,
    this.funds,
    this.others,
    this.cryptoTotal,
    this.cryptoChange24HPercent,
    this.stocksTotal,
    this.stocksChange24HPercent,
    this.fundsTotal,
    this.fundsChange24HPercent,
    this.othersTotal,
    this.otherChange24HPercent,
    this.totalInvestments,
    this.totalInvestmentChange24HPercent,
    this.id,
  });

  factory OverviewBody.fromJson(Map<String, dynamic> json) => OverviewBody(
        crypto: json["crypto"] == null
            ? []
            : List<CryptoModel>.from(
                json["crypto"]!.map((x) => CryptoModel.fromJson(x))),
        stocks: json["stocks"] == null
            ? []
            : List<CryptoModel>.from(
                json["stocks"]!.map((x) => CryptoModel.fromJson(x))),
        funds: json["funds"] == null
            ? []
            : List<CryptoModel>.from(
                json["funds"]!.map((x) => CryptoModel.fromJson(x))),
        others: json["others"] == null
            ? []
            : List<CryptoModel>.from(
                json["others"]!.map((x) => CryptoModel.fromJson(x))),
        cryptoTotal: json["cryptoTotal"]?.toDouble(),
        cryptoChange24HPercent: json["cryptoChange24hPercent"]?.toDouble(),
        stocksTotal: json["stocksTotal"]?.toDouble(),
        stocksChange24HPercent: json["stocksChange24hPercent"]?.toDouble(),
        fundsTotal: json["fundsTotal"]?.toDouble(),
        fundsChange24HPercent: json["fundsChange24hPercent"]?.toDouble(),
        othersTotal: json["othersTotal"]?.toDouble(),
        otherChange24HPercent: json["otherChange24hPercent"]?.toDouble(),
        totalInvestments: json["totalInvestments"]?.toDouble(),
        totalInvestmentChange24HPercent:
            json["totalInvestmentChange24hPercent"]?.toDouble(),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "crypto": crypto == null
            ? []
            : List<dynamic>.from(crypto!.map((x) => x.toJson())),
        "stocks": stocks == null
            ? []
            : List<dynamic>.from(stocks!.map((x) => x.toJson())),
        "funds": funds == null
            ? []
            : List<dynamic>.from(funds!.map((x) => x.toJson())),
        "others": others == null
            ? []
            : List<dynamic>.from(others!.map((x) => x.toJson())),
        "cryptoTotal": cryptoTotal,
        "cryptoChange24hPercent": cryptoChange24HPercent,
        "stocksTotal": stocksTotal,
        "stocksChange24hPercent": stocksChange24HPercent,
        "fundsTotal": fundsTotal,
        "fundsChange24hPercent": fundsChange24HPercent,
        "othersTotal": othersTotal,
        "otherChange24hPercent": otherChange24HPercent,
        "totalInvestments": totalInvestments,
        "totalInvestmentChange24hPercent": totalInvestmentChange24HPercent,
        "_id": id,
      };
}

class CryptoModel {
  final String? cryptoId;
  final String? name;
  final String? subtitle;
  final double? amount;
  final double? quantity;
  final double? updatedAmount;
  final String? tickerSymbol;
  final String? image;
  final String? id;

  CryptoModel({
    this.cryptoId,
    this.name,
    this.subtitle,
    this.amount,
    this.quantity,
    this.updatedAmount,
    this.tickerSymbol,
    this.image,
    this.id,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) => CryptoModel(
        cryptoId: json["id"],
        name: json["name"],
        subtitle: json["subtitle"],
        amount: json["amount"]?.toDouble(),
        quantity: json["quantity"]?.toDouble(),
        updatedAmount: json["updatedAmount"]?.toDouble(),
        tickerSymbol: json["ticker_symbol"],
        image: json["image"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": cryptoId,
        "name": name,
        "subtitle": subtitle,
        "amount": amount,
        "quantity": quantity,
        "updatedAmount": updatedAmount,
        "ticker_symbol": tickerSymbol,
        "image": image,
        "_id": id,
      };
}
