class ExpenseCategory {
  final String category;
  final double percentage;

  ExpenseCategory({
    required this.category,
    required this.percentage,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      category: json['category'] ?? '',
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}