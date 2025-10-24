class SessionHistoryModel {
  final String? createdAt;
  final String? lastActive;
  final String? sessionId;
  final String? title;

  SessionHistoryModel({
    this.createdAt,
    this.lastActive,
    this.sessionId,
    this.title,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      createdAt: json['created_at'],
      lastActive: json['last_active'],
      sessionId: json['session_id'],
      title: json['title'],
    );
  }
}
