// package:wealthnx/models/expense/expense_recurring.dart
class ExpenseRecurringModel {
  final bool? status;
  final String? message;
  final ExpenseTransBody? body;

  ExpenseRecurringModel({
    this.status,
    this.message,
    this.body,
  });

  factory ExpenseRecurringModel.fromJson(Map<String, dynamic> json) =>
      ExpenseRecurringModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null
            ? null
            : ExpenseTransBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body?.toJson(),
      };
}

class ExpenseTransBody {
  final double? totalExpense;
  final List<ExpenseRecurring>? expenses;

  ExpenseTransBody({
    this.totalExpense,
    this.expenses,
  });

  factory ExpenseTransBody.fromJson(Map<String, dynamic> json) =>
      ExpenseTransBody(
        totalExpense: json["totalRecurringExpense"]?.toDouble(),
        expenses: json["expenses"] == null
            ? []
            : List<ExpenseRecurring>.from(
                json["expenses"]!.map((x) => ExpenseRecurring.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalRecurringExpense": totalExpense,
        "expenses": expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
      };
}

class ExpenseRecurring {
  final ChartConfigRecurring? chartConfig;
  final bool? isRecurring;
  final bool? isDeleted; // Added to match JSON
  final dynamic recurrenceInterval;
  final String? category;
  final double? amount;
  final DateTime? date;
  final String? id;
  final String? description;
  final String? plaidTransactionId;
  final String? bankAccount;
  final dynamic nextOccurrence;
  final String? name; // Added to match JSON

  ExpenseRecurring({
    this.chartConfig,
    this.isRecurring,
    this.isDeleted,
    this.recurrenceInterval,
    this.category,
    this.amount,
    this.date,
    this.id,
    this.description,
    this.plaidTransactionId,
    this.bankAccount,
    this.nextOccurrence,
    this.name,
  });

  factory ExpenseRecurring.fromJson(Map<String, dynamic> json) =>
      ExpenseRecurring(
        chartConfig: json["chartConfig"] == null
            ? null
            : ChartConfigRecurring.fromJson(json["chartConfig"]),
        isRecurring: json["isRecurring"],
        isDeleted: json["isDeleted"],
        recurrenceInterval: json["recurrenceInterval"],
        category: json["category"],
        amount: json["amount"]?.toDouble(),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        id: json["_id"],
        description: json["description"],
        plaidTransactionId: json["plaidTransactionId"],
        bankAccount: json["bankAccount"],
        nextOccurrence: json["nextOccurrence"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "chartConfig": chartConfig?.toJson(),
        "isRecurring": isRecurring,
        "isDeleted": isDeleted,
        "recurrenceInterval": recurrenceInterval,
        "category": category,
        "amount": amount,
        "date": date?.toIso8601String(),
        "_id": id,
        "description": description,
        "plaidTransactionId": plaidTransactionId,
        "bankAccount": bankAccount,
        "nextOccurrence": nextOccurrence,
        "name": name,
      };
}

class ChartConfigRecurring {
  final String? chartType;
  final String? lineColor;

  ChartConfigRecurring({
    this.chartType,
    this.lineColor,
  });

  factory ChartConfigRecurring.fromJson(Map<String, dynamic> json) =>
      ChartConfigRecurring(
        chartType: json["chartType"],
        lineColor: json["lineColor"],
      );

  Map<String, dynamic> toJson() => {
        "chartType": chartType,
        "lineColor": lineColor,
      };
}
