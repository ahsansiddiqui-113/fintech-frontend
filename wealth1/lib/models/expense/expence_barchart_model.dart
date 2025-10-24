class ExpenceBarModel {
  final bool? status;
  final String? message;
  final List<Body>? body;

  ExpenceBarModel({
    this.status,
    this.message,
    this.body,
  });

  factory ExpenceBarModel.fromJson(Map<String, dynamic> json) =>
      ExpenceBarModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null
            ? []
            : List<Body>.from(json["body"]!.map((x) => Body.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body == null
            ? []
            : List<dynamic>.from(body!.map((x) => x.toJson())),
      };
}

class Body {
  final String? monthName;
  final double? total;

  Body({
    this.monthName,
    this.total,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        monthName: json["monthName"],
        total: json["total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "monthName": monthName,
        "total": total,
      };
}
