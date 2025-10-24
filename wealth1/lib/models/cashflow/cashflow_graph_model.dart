class CashFlowGraphModel {
  final bool status;
  final String message;
  final List<CashFlowEntry> body;

  CashFlowGraphModel({
    required this.status,
    required this.message,
    required this.body,
  });

  factory CashFlowGraphModel.fromJson(Map<String, dynamic> json) {
    return CashFlowGraphModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => CashFlowEntry.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'body': body.map((e) => e.toJson()).toList(),
    };
  }
}

class CashFlowEntry {
  final String monthName;
  final double total;

  CashFlowEntry({
    required this.monthName,
    required this.total,
  });

  factory CashFlowEntry.fromJson(Map<String, dynamic> json) {
    return CashFlowEntry(
      monthName: json['monthName'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthName': monthName,
      'total': total,
    };
  }
}
