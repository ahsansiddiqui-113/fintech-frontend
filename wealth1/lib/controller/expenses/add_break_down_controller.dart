import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'dart:convert';

import '../../../../widgets/custom_app_bar.dart';
import '../../view/vitals/expenses/total_expense_breakdown/total_expense_breakdown_page.dart';

class ExpenseBreakdownController extends GetxController {
  // Observable variables
  var categories = <ExpenseCategory>[].obs;
  var transactions = <Transaction>[].obs;
  var isLoading = true.obs;
  var errorMessage = RxnString();
  var totalExpense = 0.0.obs;

  // API Configuration
  // final String userId = "689196514e2edc046594e74c";
  // final String apiUrl =
  //     "https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users";
  // final String authToken =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTE5NjUxNGUyZWRjMDQ2NTk0ZTc0YyIsImVtYWlsIjoibW9kYXNzaXJoYWJpYjlAZ21haWwuY29tIiwiaWF0IjoxNzU1MDc2MTE3LCJleHAiOjMxNzI5OTUxODUxN30.7Tvy3UT8IEAYjfjBPyD8n6urdNA3DWFjK1gGu_iV1Zo";

  @override
  void onInit() {
    super.onInit();
    fetchExpenseData();
  }

  Future<void> fetchExpenseData() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      };

      final request = http.Request('GET',
          Uri.parse('${AppEndpoints.baseUrl}/$userId/expenses/categories'));
      request.headers.addAll(headers);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);

        if (jsonData['status'] == true) {
          _processApiData(jsonData['body']);
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _processApiData(Map<String, dynamic> data) {
    try {
      totalExpense.value = (data['totalExpense'] ?? 0.0).toDouble();

      final List<dynamic> expensesCategories =
          data['expenses_categories'] ?? [];

      categories.value = expensesCategories.map((categoryData) {
        return ExpenseCategory(
          formatCategoryName(categoryData['category'] ?? ''),
          (categoryData['amount'] ?? 0.0).toDouble(),
          getCategoryColor(categoryData['category'] ?? ''),
          categoryData['id'] ?? '',
          categoryData['date'] ?? '',
          categoryData['category'] ?? '',
        );
      }).toList();

      // Create transactions from categories for display
      transactions.value = categories.map((category) {
        final date = DateTime.tryParse(category.date) ?? DateTime.now();
        return Transaction(
          category.name,
          formatDate(date),
          formatTime(date),
          category.amount,
          getIconForCategory(category.originalName),
          category.color,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = 'Error processing data: ${e.toString()}';
    }
  }

  String formatCategoryName(String category) {
    return category
        .toLowerCase()
        .split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  Color getCategoryColor(String category) {
    final colors = [
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF50D773), // Green
      const Color(0xFFFFB84D), // Orange
      const Color(0xFFE74C3C), // Red
      // const Color(0xFF9B59B6), // Purple
      // const Color(0xFF1ABC9C), // Teal
      // const Color(0xFFE67E22), // Dark Orange
      const Color(0xFFAA8EC6), // Light Purple
    ];

    final hash = category.hashCode;
    return colors[hash.abs() % colors.length];
  }

  IconData getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'GENERAL_SERVICES':
        return Icons.miscellaneous_services;
      case 'GENERAL_MERCHANDISE':
        return Icons.shopping_cart;
      case 'FOOD_AND_DRINK':
        return Icons.restaurant;
      case 'TRAVEL':
        return Icons.flight;
      case 'ENTERTAINMENT':
        return Icons.movie;
      case 'PERSONAL_CARE':
        return Icons.spa;
      case 'LOAN_PAYMENTS':
        return Icons.payment;
      case 'TRANSPORTATION':
        return Icons.directions_car;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    // System: 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  List<PieChartSectionData> buildPieChartSections() {
    if (totalExpense.value == 0 || categories.isEmpty) {
      return [];
    }

    // Define fixed 5 colors (Red, Blue, Green, Yellow, Cyan)
    final List<Color> fixedColors = [
      Color(0xFF1A93D9),
      Color(0xFF57ED6D),
      Color(0xFFEFCA39),
      Color(0xFFE37F51),
      Color(0xFFD93977),
    ];

    // Sort categories by amount and take top 5
    final topCategories = categories.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final displayCategories = topCategories.take(5).toList();

    return List.generate(displayCategories.length, (index) {
      final category = displayCategories[index];
      final percentage = category.amount / totalExpense.value * 100;

      return PieChartSectionData(
        color: fixedColors[index], // Fixed unique color
        showTitle: false,
        value: category.amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 10,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    });
  }

  void addNewExpense(String title, double amount, String category) {
    // Add to transactions
    transactions.insert(
      0,
      Transaction(
        title,
        formatDate(DateTime.now()),
        formatTime(DateTime.now()),
        amount,
        getIconForCategory(category),
        getCategoryColor(category),
      ),
    );

    // Update category amount
    final categoryIndex =
        categories.indexWhere((cat) => cat.originalName == category);
    if (categoryIndex != -1) {
      final existingCategory = categories[categoryIndex];
      categories[categoryIndex] = ExpenseCategory(
        existingCategory.name,
        existingCategory.amount + amount,
        existingCategory.color,
        existingCategory.id,
        existingCategory.date,
        existingCategory.originalName,
      );
    }

    // Update total expense
    totalExpense.value += amount;
  }
}
