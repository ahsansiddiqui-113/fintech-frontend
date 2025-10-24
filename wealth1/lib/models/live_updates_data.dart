class LiveUpdatesData {
  final LiveUpdatePortfolio portfolio;
  final LiveUpdateSpending spending;
  final LiveUpdateIncome income;

  LiveUpdatesData({
    required this.portfolio,
    required this.spending,
    required this.income,
  });

  factory LiveUpdatesData.fromJson(Map<String, dynamic> json) {
    return LiveUpdatesData(
      portfolio: LiveUpdatePortfolio.fromJson(json['liveUpdatePortfolio']),
      spending: LiveUpdateSpending.fromJson(json['liveUpdateSpending']),
      income: LiveUpdateIncome.fromJson(json['liveUpdateIncome']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liveUpdatePortfolio': portfolio.toJson(),
      'liveUpdateSpending': spending.toJson(),
      'liveUpdateIncome': income.toJson(),
    };
  }
}

class LiveUpdatePortfolio {
  final List<double> data;
  final List<String> timestamps;
  final List<StockDetail> details;

  LiveUpdatePortfolio({
    required this.data,
    required this.timestamps,
    required this.details,
  });

  factory LiveUpdatePortfolio.fromJson(Map<String, dynamic> json) {
    return LiveUpdatePortfolio(
      data: List<double>.from(json['data']),
      timestamps: List<String>.from(json['timestamps']),
      details: List<StockDetail>.from(
        json['details'].map((x) => StockDetail.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamps': timestamps,
      'details': details.map((x) => x.toJson()).toList(),
    };
  }
}

class StockDetail {
  final String stock;
  final String change;
  final String amount;

  StockDetail({
    required this.stock,
    required this.change,
    required this.amount,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      stock: json['stock'],
      change: json['change'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock': stock,
      'change': change,
      'amount': amount,
    };
  }
}

class LiveUpdateSpending {
  final List<double> data;
  final List<String> categories;
  final List<double> values;

  LiveUpdateSpending({
    required this.data,
    required this.categories,
    required this.values,
  });

  factory LiveUpdateSpending.fromJson(Map<String, dynamic> json) {
    return LiveUpdateSpending(
      data: List<double>.from(json['data']),
      categories: List<String>.from(json['categories']),
      values: List<double>.from(json['values']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'categories': categories,
      'values': values,
    };
  }
}

class LiveUpdateIncome {
  final List<double> data;
  final List<String> sources;
  final List<double> values;

  LiveUpdateIncome({
    required this.data,
    required this.sources,
    required this.values,
  });

  factory LiveUpdateIncome.fromJson(Map<String, dynamic> json) {
    return LiveUpdateIncome(
      data: List<double>.from(json['data']),
      sources: List<String>.from(json['sources']),
      values: List<double>.from(json['values']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'sources': sources,
      'values': values,
    };
  }
}
