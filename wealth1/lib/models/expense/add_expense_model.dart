class AddExpenseModel {
  final bool? status;
  final String? message;
  final Body? body;

  AddExpenseModel({
    this.status,
    this.message,
    this.body,
  });

  factory AddExpenseModel.fromJson(Map<String, dynamic> json) =>
      AddExpenseModel(
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
  final String? category;
  final int? amount;
  final String? description;
  final DateTime? date;
  final bool? isRecurring;
  final bool? isDeleted;
  final dynamic recurrenceInterval;
  final dynamic nextOccurrence;
  final ChartConfig? chartConfig;
  final String? id;

  Body({
    this.category,
    this.amount,
    this.description,
    this.date,
    this.isRecurring,
    this.isDeleted,
    this.recurrenceInterval,
    this.nextOccurrence,
    this.chartConfig,
    this.id,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        category: json["category"],
        amount: json["amount"],
        description: json["description"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        isRecurring: json["isRecurring"],
        isDeleted: json["isDeleted"],
        recurrenceInterval: json["recurrenceInterval"],
        nextOccurrence: json["nextOccurrence"],
        chartConfig: json["chartConfig"] == null
            ? null
            : ChartConfig.fromJson(json["chartConfig"]),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "amount": amount,
        "description": description,
        "date": date?.toIso8601String(),
        "isRecurring": isRecurring,
        "isDeleted": isDeleted,
        "recurrenceInterval": recurrenceInterval,
        "nextOccurrence": nextOccurrence,
        "chartConfig": chartConfig?.toJson(),
        "_id": id,
      };
}

class ChartConfig {
  final String? chartType;
  final String? lineColor;

  ChartConfig({
    this.chartType,
    this.lineColor,
  });

  factory ChartConfig.fromJson(Map<String, dynamic> json) => ChartConfig(
        chartType: json["chartType"],
        lineColor: json["lineColor"],
      );

  Map<String, dynamic> toJson() => {
        "chartType": chartType,
        "lineColor": lineColor,
      };
}
