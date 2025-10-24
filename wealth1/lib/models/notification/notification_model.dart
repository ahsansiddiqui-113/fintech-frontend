class NotificationResponse {
  final bool status;
  final String message;
  final NotificationBody body;

  NotificationResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      body: NotificationBody.fromJson(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'body': body.toJson(),
  };
}

class NotificationBody {
  final List<AppNotification> notifications;
  final Pagination pagination;

  NotificationBody({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationBody.fromJson(Map<String, dynamic> json) {
    return NotificationBody(
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'notifications': notifications.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

class AppNotification {
  final bool isRead;
  final bool isArchived;
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String relatedScheduleId;
  final NotificationData data;
  final String actionUrl;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.isRead,
    required this.isArchived,
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.relatedScheduleId,
    required this.data,
    required this.actionUrl,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      isRead: json['isRead'] ?? false,
      isArchived: json['isArchived'] ?? false,
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedScheduleId: json['relatedScheduleId'] ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
      actionUrl: json['actionUrl'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'isRead': isRead,
    'isArchived': isArchived,
    '_id': id,
    'userId': userId,
    'type': type,
    'title': title,
    'message': message,
    'relatedScheduleId': relatedScheduleId,
    'data': data.toJson(),
    'actionUrl': actionUrl,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class NotificationData {
  final String scheduleName;
  final int amount;
  final DateTime dueDate;
  final String category;
  final String recurrenceInterval;

  NotificationData({
    required this.scheduleName,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.recurrenceInterval,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      scheduleName: json['scheduleName'] ?? '',
      amount: (json['amount'] is int)
          ? json['amount']
          : int.tryParse(json['amount'].toString()) ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      category: json['category'] ?? '',
      recurrenceInterval: json['recurrenceInterval'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'scheduleName': scheduleName,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'category': category,
    'recurrenceInterval': recurrenceInterval,
  };
}

class Pagination {
  final int total;
  final int limit;
  final int skip;
  final int unreadCount;

  Pagination({
    required this.total,
    required this.limit,
    required this.skip,
    required this.unreadCount,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
      skip: json['skip'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'limit': limit,
    'skip': skip,
    'unreadCount': unreadCount,
  };
}