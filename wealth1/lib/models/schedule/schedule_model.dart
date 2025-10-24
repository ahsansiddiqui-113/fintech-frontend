class RecurringExpensesResponse {
  final bool status;
  final String message;
  final RecurringExpensesBody body;

  RecurringExpensesResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory RecurringExpensesResponse.fromJson(Map<String, dynamic> json) {
    return RecurringExpensesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      body: RecurringExpensesBody.fromJson(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'body': body.toJson(),
    };
  }
}

class RecurringExpensesBody {
  final DateTime date;
  final double monthlyAmount;
  final double dailyAmount;
  final int totalSubscription;
  final List<RecurringItem> recurringList;

  RecurringExpensesBody({
    required this.date,
    required this.monthlyAmount,
    required this.dailyAmount,
    required this.totalSubscription,
    required this.recurringList,
  });

  factory RecurringExpensesBody.fromJson(Map<String, dynamic> json) {
    return RecurringExpensesBody(
      date: DateTime.parse(json['date']),
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
      dailyAmount: (json['daily_amount'] ?? 0).toDouble(),
      totalSubscription: json['total_subscription'] ?? 0,
      recurringList: (json['recuring_list'] as List<dynamic>? ?? [])
          .map((e) => RecurringItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'monthly_amount': monthlyAmount,
      'daily_amount': dailyAmount,
      'total_subscription': totalSubscription,
      'recuring_list': recurringList.map((e) => e.toJson()).toList(),
    };
  }
}

class RecurringItem {
  final String name;
  final String logoUrl;
  final bool isRecurring;
  final String recurrenceInterval;
  final String id;
  final String plaidTransactionId;
  final String category;
  final String tagType;
  final double amount;
  final String description;
  final DateTime date;
  final List<PrevYearTran> prevYearTrans;

  RecurringItem({
    required this.name,
    required this.logoUrl,
    required this.isRecurring,
    required this.recurrenceInterval,
    required this.id,
    required this.plaidTransactionId,
    required this.category,
    required this.tagType,
    required this.amount,
    required this.description,
    required this.date,
    required this.prevYearTrans,
  });

  factory RecurringItem.fromJson(Map<String, dynamic> json) {
    return RecurringItem(
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      recurrenceInterval: json['recurrenceInterval'] ?? '',
      id: json['id'] ?? '',
      plaidTransactionId: json['plaidTransactionId'] ?? '',
      category: json['category'] ?? '',
      tagType: json['tag_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      prevYearTrans: (json['prev_year_tarns'] as List<dynamic>? ?? [])
          .map((e) => PrevYearTran.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'id': id,
      'plaidTransactionId': plaidTransactionId,
      'category': category,
      'tag_type': tagType,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'prev_year_tarns': prevYearTrans,
    };
  }
}

class PrevYearTran {
  final String name;
  final String logoUrl;
  final bool isRecurring;
  final String recurrenceInterval;
  final String id;
  final String plaidTransactionId;
  final String category;
  final double amount;
  final DateTime date;

  PrevYearTran({
    required this.name,
    required this.logoUrl,
    required this.isRecurring,
    required this.recurrenceInterval,
    required this.id,
    required this.plaidTransactionId,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory PrevYearTran.fromJson(Map<String, dynamic> json) {
    return PrevYearTran(
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      recurrenceInterval: json['recurrenceInterval'] ?? '',
      id: json['id'] ?? '',
      plaidTransactionId: json['plaidTransactionId'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'id': id,
      'plaidTransactionId': plaidTransactionId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

