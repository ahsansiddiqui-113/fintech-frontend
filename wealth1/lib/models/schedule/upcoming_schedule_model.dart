import 'package:wealthnx/models/schedule/schedule_model.dart';

class UpcomingExpensesResponse {
  final bool status;
  final String message;
  final UpcomingExpensesBody body;

  UpcomingExpensesResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory UpcomingExpensesResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingExpensesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      body: UpcomingExpensesBody.fromJson(json['body'] ?? {}),
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

class UpcomingExpensesBody {
  final List<RecurringItem> upcomingSchedules;
  final int totalUpcoming;
  final double next30DaysAmount;
  final String generatedOn;

  UpcomingExpensesBody({
    required this.upcomingSchedules,
    required this.totalUpcoming,
    required this.next30DaysAmount,
    required this.generatedOn,
  });

  factory UpcomingExpensesBody.fromJson(Map<String, dynamic> json) {
    return UpcomingExpensesBody(
      upcomingSchedules: (json['upcoming_schedules'] as List? ?? [])
          .map((e) => RecurringItem.fromJson(e))
          .toList(),
      totalUpcoming: json['total_upcoming'] ?? 0,
      next30DaysAmount:
      (json['next_30_days_amount'] as num?)?.toDouble() ?? 0.0,
      generatedOn: json['generated_on'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upcoming_schedules':
      upcomingSchedules.map((e) => e.toJson()).toList(),
      'total_upcoming': totalUpcoming,
      'next_30_days_amount': next30DaysAmount,
      'generated_on': generatedOn,
    };
  }
}

