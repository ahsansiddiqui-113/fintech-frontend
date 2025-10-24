class InvestOverviewModel {
  final List<Holding>? crypto;
  final List<Holding>? stocks;
  final List<Holding>? funds;
  final List<Holding>? others;
  final double? cryptoTotal;
  final double? stocksTotal;
  final double? fundsTotal;
  final double? othersTotal;
  final double? totalInvestments;

  InvestOverviewModel({
    this.crypto,
    this.stocks,
    this.funds,
    this.others,
    this.cryptoTotal,
    this.stocksTotal,
    this.fundsTotal,
    this.othersTotal,
    this.totalInvestments,
  });

  factory InvestOverviewModel.fromJson(Map<String, dynamic> json) {
    List<Holding> parseHoldings(List<dynamic>? jsonList) =>
        (jsonList ?? []).map((e) => Holding.fromJson(e)).toList();

    return InvestOverviewModel(
      crypto: parseHoldings(json['crypto']),
      stocks: parseHoldings(json['stocks']),
      funds: parseHoldings(json['funds']),
      others: parseHoldings(json['others']),
      cryptoTotal: (json['cryptoTotal'] ?? 0).toDouble(),
      stocksTotal: (json['stocksTotal'] ?? 0).toDouble(),
      fundsTotal: (json['fundsTotal'] ?? 0).toDouble(),
      othersTotal: (json['othersTotal'] ?? 0).toDouble(),
      totalInvestments: (json['totalInvestments'] ?? 0).toDouble(),
    );
  }
}

class Holding {
  final String? id;
  final String? name;
  final String? subtitle;
  final double? amount;
  final double? quantity;
  final double? updatedAmount;
  final String? tickerSymbol;
  final String? image;

  Holding({
    this.id,
    this.name,
    this.subtitle,
    this.amount,
    this.quantity,
    this.updatedAmount,
    this.tickerSymbol,
    this.image,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      updatedAmount: (json['updatedAmount'] ?? 0).toDouble(),
      tickerSymbol: json['ticker_symbol'] ?? '',
      image: json['image'],
    );
  }
}
