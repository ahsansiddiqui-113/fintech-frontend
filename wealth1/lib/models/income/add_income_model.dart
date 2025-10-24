class AddIncomeModel {
  final bool? status;
  final String? message;
  final Body? body;

  AddIncomeModel({
    this.status,
    this.message,
    this.body,
  });

  factory AddIncomeModel.fromJson(Map<String, dynamic> json) => AddIncomeModel(
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
  final String? name;
  final String? type;
  final int? amount;
  final DateTime? paymentDate;
  final String? description;
  final bool? isDeleted;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Body({
    this.name,
    this.type,
    this.amount,
    this.paymentDate,
    this.description,
    this.isDeleted,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        name: json["name"],
        type: json["type"],
        amount: json["amount"],
        paymentDate: json["paymentDate"] == null
            ? null
            : DateTime.parse(json["paymentDate"]),
        description: json["description"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "amount": amount,
        "paymentDate": paymentDate?.toIso8601String(),
        "description": description,
        "isDeleted": isDeleted,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
