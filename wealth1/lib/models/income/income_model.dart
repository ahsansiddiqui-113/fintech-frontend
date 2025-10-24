class IncomeModel {
  final bool? status;
  final String? message;
  final IncomeBody? body;

  IncomeModel({
    this.status,
    this.message,
    this.body,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null ? null : IncomeBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body?.toJson(),
      };
}

class IncomeBody {
  final List<Income>? incomes;
  final double? totalIncomeAmount;

  IncomeBody({
    this.incomes,
    this.totalIncomeAmount,
  });

  factory IncomeBody.fromJson(Map<String, dynamic> json) => IncomeBody(
        incomes: json["incomes"] == null
            ? []
            : List<Income>.from(
                json["incomes"]!.map((x) => Income.fromJson(x))),
        totalIncomeAmount: json["total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "incomes": incomes == null
            ? []
            : List<dynamic>.from(incomes!.map((x) => x.toJson())),
        "total": totalIncomeAmount,
      };
}

class Income {
  final String? name;
  final String? type;
  final double? amount;
  final String? logo;
  final String? frequency;
  final DateTime? paymentDate;
  final int? taxRate;
  final String? description;
  final bool? archived;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? plaidTransactionId;

  Income({
    this.name,
    this.type,
    this.amount,
    this.logo,
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

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        name: json["title"],
        type: json["category"],
        amount: json["amount"]?.toDouble(),
        logo: json["logo_url"],
        frequency: json["frequency"],
        paymentDate: json["paymentDate"] == null
            ? null
            : DateTime.parse(json["paymentDate"]),
        taxRate: json["taxRate"],
        description: json["description"],
        archived: json["archived"],
        id: json["_id"],
        createdAt: json["date"] == null ? null : DateTime.parse(json["date"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        plaidTransactionId: json["plaidTransactionId"],
      );

  Map<String, dynamic> toJson() => {
        "title": name,
        "category": type,
        "amount": amount,
        "logo_url": logo,
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
