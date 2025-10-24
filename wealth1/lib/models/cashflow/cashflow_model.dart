class CashFlowModel {
  final bool status;
  final String? message;
  final CashFlowBody? body;

  CashFlowModel({
    required this.status,
    this.message,
    this.body,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      status: json['status'] ?? false,
      message: json['message'],
      body: json['body'] != null ? CashFlowBody.fromJson(json['body']) : null,
    );
  }
}

class CashFlowBody {
  final String? month;
  final List<CategoryBreakdown>? incomeBreakdown;
  final List<CategoryBreakdown>? expenseBreakdown;
  final double? totalIncome;
  final double? totalExpenses;
  final double? netCashFlow;
  final double? income;
  final double? expenses;
  final String? id;
  final double? cashflow;
  final String? lastUpdated;
  final double? incomeChangePercent;
  final double? expenseChangePercent;
  final double? netChangePercent;

  CashFlowBody({
    this.month,
    this.incomeBreakdown,
    this.expenseBreakdown,
    this.totalIncome,
    this.totalExpenses,
    this.netCashFlow,
    this.income,
    this.expenses,
    this.id,
    this.cashflow,
    this.lastUpdated,
    this.expenseChangePercent,
    this.incomeChangePercent,
    this.netChangePercent,
  });

  factory CashFlowBody.fromJson(Map<String, dynamic> json) {
    return CashFlowBody(
      month: json['month'],
      incomeBreakdown: (json['incomeBreakdown'] as List?)
          ?.map((e) => CategoryBreakdown.fromJson(e))
          .toList(),
      expenseBreakdown: (json['expenseBreakdown'] as List?)
          ?.map((e) => CategoryBreakdown.fromJson(e))
          .toList(),
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      netCashFlow: (json['netCashFlow'] ?? 0).toDouble(),
      income: (json['income'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      id: json['_id'],
      cashflow: (json['cashflow'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'],
      expenseChangePercent: (json['expenseChangePercent'] ?? 0).toDouble(),
      incomeChangePercent: (json['incomeChangePercent'] ?? 0).toDouble(),
      netChangePercent: (json['netChangePercent'] ?? 0).toDouble(),
    );
  }
}

class CategoryBreakdown {
  final String? category;
  final String? name;
  final String? type;
  final String? logo;
  final double? amount;
  final String? frequency;
  final DateTime? paymentDate;
  final int? taxRate;
  final String? description;
  final bool? archived;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? plaidTransactionId;

  CategoryBreakdown({
    this.category,
    this.name,
    this.type,
    this.logo,
    this.amount,
    this.frequency,
    this.paymentDate,
    this.taxRate,
    this.description,
    this.archived,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.plaidTransactionId,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'],
      name: json["name"],
      logo: json["logo_url"],
      type: json["type"],
      amount: json["amount"]?.toDouble(),
      frequency: json["frequency"],
      paymentDate: json["paymentDate"] == null
          ? null
          : DateTime.parse(json["paymentDate"]),
      taxRate: json["taxRate"],
      description: json["description"],
      archived: json["archived"],
      id: json["_id"],
      createdAt: json["date"] == null ? null : DateTime.parse(json["date"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      plaidTransactionId: json["plaidTransactionId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "category": category,
        "name": name,
        "logo_url": logo,
        "type": type,
        "amount": amount,
        "frequency": frequency,
        "paymentDate": paymentDate?.toIso8601String(),
        "taxRate": taxRate,
        "description": description,
        "archived": archived,
        "_id": id,
        "date": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "plaidTransactionId": plaidTransactionId,
      };
}
