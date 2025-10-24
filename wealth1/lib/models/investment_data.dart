class InvestmentData {
  final double totalInvestments;
  final List<InvestmentType> investmentTypes;
  final List<Crypto> crypto;
  final List<Stock> stocks;

  InvestmentData({
    required this.totalInvestments,
    required this.investmentTypes,
    required this.crypto,
    required this.stocks,
  });

  factory InvestmentData.fromJson(Map<String, dynamic> json) {
    return InvestmentData(
      totalInvestments: (json['totalInvestments'] as num).toDouble(),
      investmentTypes: (json['investmentTypes'] as List)
          .map((type) => InvestmentType.fromJson(type as Map<String, dynamic>))
          .toList(),
      crypto: (json['crypto'] as List)
          .map((crypto) => Crypto.fromJson(crypto as Map<String, dynamic>))
          .toList(),
      stocks: (json['stocks'] as List)
          .map((stock) => Stock.fromJson(stock as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvestments': totalInvestments,
      'investmentTypes': investmentTypes.map((type) => type.toJson()).toList(),
      'crypto': crypto.map((crypto) => crypto.toJson()).toList(),
      'stocks': stocks.map((stock) => stock.toJson()).toList(),
    };
  }
}

class InvestmentType {
  final String type;
  final double amount;

  InvestmentType({
    required this.type,
    required this.amount,
  });

  factory InvestmentType.fromJson(Map<String, dynamic> json) {
    return InvestmentType(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
    };
  }
}

class Crypto {
  final String name;
  final double amount;
  final String quantity;

  Crypto({
    required this.name,
    required this.amount,
    required this.quantity,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'quantity': quantity,
    };
  }
}

class Stock {
  final String name;
  final double amount;
  final String quantity;

  Stock({
    required this.name,
    required this.amount,
    required this.quantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'quantity': quantity,
    };
  }
}
