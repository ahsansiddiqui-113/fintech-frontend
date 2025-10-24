class BudgetResponse {
  final bool? status;
  final String? message;
  final Body? body;

  BudgetResponse({
    this.status,
    this.message,
    this.body,
  });

  factory BudgetResponse.fromJson(Map<String, dynamic> json) => BudgetResponse(
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
  final List<Category>? category;
  final List<Budget>? budgets;
  final List<FrequencyCategoryModel>? frequencyCategoryModel;
  final int? totalBudget;
  final double? totalRemaining;
  final String? percentageRemaining;

  Body({
    this.category,
    this.budgets,
    this.totalBudget,
    this.totalRemaining,
    this.percentageRemaining,
    this.frequencyCategoryModel,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        category: json["category"] == null
            ? []
            : List<Category>.from(
                json["category"]!.map((x) => Category.fromJson(x))),
        budgets: json["budgets"] == null
            ? []
            : List<Budget>.from(
                json["budgets"]!.map((x) => Budget.fromJson(x))),
    frequencyCategoryModel: json["frequencycategory"] == null
            ? []
            : List<FrequencyCategoryModel>.from(
                json["frequencycategory"]!.map((x) => FrequencyCategoryModel.fromJson(x))),
        totalBudget: json["totalBudget"],
        totalRemaining: json["totalRemaining"]?.toDouble(),
        percentageRemaining: json["percentageRemaining"],
      );

  Map<String, dynamic> toJson() => {
        "category": category == null
            ? []
            : List<dynamic>.from(category!.map((x) => x.toJson())),
        "budgets": budgets == null
            ? []
            : List<dynamic>.from(budgets!.map((x) => x.toJson())),
    "frequencycategory": frequencyCategoryModel == null
            ? []
            : List<dynamic>.from(frequencyCategoryModel!.map((x) => x.toJson())),
        "totalBudget": totalBudget,
        "totalRemaining": totalRemaining,
        "percentageRemaining": percentageRemaining,
      };
}

class Budget {
  final ChartConfig? chartConfig;
  final bool? isDeleted;
  final String? plaidTransactionId;
  final String? category;
  final double? amount;
  final String? description;
  final DateTime? date;
  final String? bankAccount;
  final bool? isRecurring;
  final dynamic recurrenceInterval;
  final String? id;
  final String? logo;
  final dynamic nextOccurrence;

  Budget({
    this.chartConfig,
    this.isDeleted,
    this.plaidTransactionId,
    this.category,
    this.amount,
    this.description,
    this.date,
    this.bankAccount,
    this.isRecurring,
    this.logo,
    this.recurrenceInterval,
    this.id,
    this.nextOccurrence,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        chartConfig: json["chartConfig"] == null
            ? null
            : ChartConfig.fromJson(json["chartConfig"]),
        isDeleted: json["isDeleted"],
        plaidTransactionId: json["plaidTransactionId"],
        category: json["category"],
        amount: json["amount"]?.toDouble(),
        description: json["description"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        bankAccount: json["bankAccount"],
        isRecurring: json["isRecurring"],
        recurrenceInterval: json["recurrenceInterval"],
        id: json["_id"],
        logo: json["logo_url"],
        nextOccurrence: json["nextOccurrence"],
      );

  Map<String, dynamic> toJson() => {
        "chartConfig": chartConfig?.toJson(),
        "isDeleted": isDeleted,
        "plaidTransactionId": plaidTransactionId,
        "category": category,
        "amount": amount,
        "description": description,
        "date": date?.toIso8601String(),
        "bankAccount": bankAccount,
        "isRecurring": isRecurring,
        "recurrenceInterval": recurrenceInterval,
        "_id": id,
        "logo_url": logo,
        "nextOccurrence": nextOccurrence,
      };
}
class FrequencyCategoryModel {
  final dynamic categoryName;
  final dynamic? budgetAmount;
  final dynamic? budgetSpend;
  final dynamic? budgetRemaining;
  final dynamic? transactionCount;
  final dynamic? date;


  FrequencyCategoryModel({

    this.categoryName,
    this.budgetAmount,
    this.budgetSpend,
    this.budgetRemaining,
    this.transactionCount,
    this.date,

  });

  factory FrequencyCategoryModel.fromJson(Map<String, dynamic> json) => FrequencyCategoryModel(
    categoryName: json["categoryName"],
    budgetAmount: json["budgetAmount"],
    budgetSpend: json["budgetSpend"],
    budgetRemaining: json["budgetRemaining"],
    transactionCount: json["transactionCount"],
        date: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
      );

  Map<String, dynamic> toJson() => {

        "categoryName": categoryName,

        "budgetAmount": budgetAmount,
        "budgetSpend": budgetSpend,
        "transactionCount": transactionCount,
        "budgetRemaining": budgetRemaining,
        "startDate": date?.toIso8601String(),

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

class Category {
  final String? id;
  final String? categoryName;
  final int? budgetAmount;
  final double? budgetSpend;
  final double? budgetRemaining;

  Category({
    this.id,
    this.categoryName,
    this.budgetAmount,
    this.budgetSpend,
    this.budgetRemaining,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        categoryName: json["categoryName"],
        budgetAmount: json["budgetAmount"],
        budgetSpend: json["budgetSpend"]?.toDouble(),
        budgetRemaining: json["budgetRemaining"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "budgetAmount": budgetAmount,
        "budgetSpend": budgetSpend,
        "budgetRemaining": budgetRemaining,
      };
}
