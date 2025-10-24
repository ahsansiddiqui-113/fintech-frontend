class TransationsModel {
  final bool? status;
  final String? message;
  final List<TransBody>? body;

  TransationsModel({
    this.status,
    this.message,
    this.body,
  });

  factory TransationsModel.fromJson(Map<String, dynamic> json) =>
      TransationsModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null || json["body"] == []
            ? null
            : List<TransBody>.from(
                json["body"]!.map((x) => TransBody.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body == null || body == []
            ? null
            : List<dynamic>.from(body!.map((x) => x.toJson())),
      };
}

class TransBody {
  final String? category;
  final String? title;
  final double? amount;
  final DateTime? date;
  final bool? isPositive;
  final String? id;
  final String? typeTrans;
  final String? bankAccount;
  final String? logoUrl;
  final String? merchantName;
  final String? accountId;
  final String? plaidCategory;
  final PersonalFinanceCategory? personalFinanceCategory;

  TransBody({
    this.category,
    this.title,
    this.amount,
    this.date,
    this.isPositive,
    this.id,
    this.typeTrans,
    this.bankAccount,
    this.logoUrl,
    this.merchantName,
    this.accountId,
    this.plaidCategory,
    this.personalFinanceCategory,
  });

  factory TransBody.fromJson(Map<String, dynamic> json) => TransBody(
        category: json["category"],
        title: json["title"],
        amount: json["amount"]?.toDouble(),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        isPositive: json["isPositive"],
        id: json["plaidTransactionId"],
        typeTrans: json["typeTrans"],
        bankAccount: json["bankAccount"],
        logoUrl: json["logo_url"],
        merchantName: json["merchant_name"],
        accountId: json["account_id"],
        plaidCategory: json["plaid_category"],
        personalFinanceCategory: json["personal_finance_category"] == null
            ? null
            : PersonalFinanceCategory.fromJson(
                json["personal_finance_category"]),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "title": title,
        "amount": amount,
        "date": date?.toIso8601String(),
        "isPositive": isPositive,
        "plaidTransactionId": id,
        "typeTrans": typeTrans,
        "bankAccount": bankAccount,
        "logo_url": logoUrl,
        "merchant_name": merchantName,
        "account_id": accountId,
        "plaid_category": plaidCategory,
        "personal_finance_category": personalFinanceCategory?.toJson(),
      };
}

class PersonalFinanceCategory {
  final String? confidenceLevel;
  final String? detailed;
  final String? primary;

  PersonalFinanceCategory({
    this.confidenceLevel,
    this.detailed,
    this.primary,
  });

  factory PersonalFinanceCategory.fromJson(Map<String, dynamic> json) =>
      PersonalFinanceCategory(
        confidenceLevel: json["confidence_level"],
        detailed: json["detailed"],
        primary: json["primary"],
      );

  Map<String, dynamic> toJson() => {
        "confidence_level": confidenceLevel,
        "detailed": detailed,
        "primary": primary,
      };
}
