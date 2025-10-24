class AddBudgetModel {
  final bool? status;
  final String? message;
  final Body? body;

  AddBudgetModel({
    this.status,
    this.message,
    this.body,
  });

  factory AddBudgetModel.fromJson(Map<String, dynamic> json) => AddBudgetModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body?.toJson(),
      };
}

class Body {
  final String? id;
  final String? categoryName;
  final int? budgetAmount;
  final int? budgetSpend;
  final int? budgetRemaining;

  Body({
    this.id,
    this.categoryName,
    this.budgetAmount,
    this.budgetSpend,
    this.budgetRemaining,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        id: json["id"],
        categoryName: json["categoryName"],
        budgetAmount: json["budgetAmount"],
        budgetSpend: json["budgetSpend"],
        budgetRemaining: json["budgetRemaining"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "budgetAmount": budgetAmount,
        "budgetSpend": budgetSpend,
        "budgetRemaining": budgetRemaining,
      };
}
