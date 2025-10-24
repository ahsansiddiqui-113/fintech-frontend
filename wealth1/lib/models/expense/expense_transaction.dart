class ExpenseTransactionModel {
  final bool? status;
  final String? message;
  final ExpenseTransBody? body;

  ExpenseTransactionModel({
    this.status,
    this.message,
    this.body,
  });

  factory ExpenseTransactionModel.fromJson(Map<String, dynamic> json) =>
      ExpenseTransactionModel(
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
  final List<Expense>? expenses;

  ExpenseTransBody({
    this.totalExpense,
    this.expenses,
  });

  factory ExpenseTransBody.fromJson(Map<String, dynamic> json) =>
      ExpenseTransBody(
        totalExpense: json["totalExpense"]?.toDouble(),
        expenses: json["expenses"] == null
            ? []
            : List<Expense>.from(
                json["expenses"]!.map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalExpense": totalExpense,
        "expenses": expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
      };
}

class Expense {
  final ChartConfig? chartConfig;
  final bool? isRecurring;
  final dynamic recurrenceInterval;
  final String? category;
  final double? amount;
  final DateTime? date;
  final String? id;
  final String? description;
  final String? plaidTransactionId;
  final String? bankAccount;
  final dynamic nextOccurrence;
  final logo_url;

  Expense({
    this.chartConfig,
    this.isRecurring,
    this.recurrenceInterval,
    this.category,
    this.amount,
    this.date,
    this.id,
    this.description,
    this.plaidTransactionId,
    this.bankAccount,
    this.logo_url,
    this.nextOccurrence,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        chartConfig: json["chartConfig"] == null
            ? null
            : ChartConfig.fromJson(json["chartConfig"]),
        isRecurring: json["isRecurring"],
        recurrenceInterval: json["recurrenceInterval"],
        category: json["category"],
        amount: json["amount"]?.toDouble(),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        id: json["_id"],
        description: json["description"],
        logo_url: json["logo_url"],
        plaidTransactionId: json["plaidTransactionId"],
        bankAccount: json["bankAccount"],
        nextOccurrence: json["nextOccurrence"],
      );

  Map<String, dynamic> toJson() => {
        "chartConfig": chartConfig?.toJson(),
        "isRecurring": isRecurring,
        "recurrenceInterval": recurrenceInterval,
        "category": category,
        "amount": amount,
        "date": date?.toIso8601String(),
        "_id": id,
        "logo_url": logo_url,
        "description": description,
        "plaidTransactionId": plaidTransactionId,
        "bankAccount": bankAccount,
        "nextOccurrence": nextOccurrence,
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
