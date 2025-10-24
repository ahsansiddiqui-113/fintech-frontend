import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/expense/expence_barchart_model.dart';
import 'package:wealthnx/models/expense/expense_transaction.dart';
import 'package:wealthnx/utils/app_urls.dart';
import '../../models/expense/expense_category.dart';
import '../../models/expense/expense_recurring_model.dart';
import '../../services/crypto_news_services.dart';

class ExpensesController extends GetxController {
  var isLoading = false.obs;
  var isLoadingExpence = false.obs;
  var expense = Rxn<ExpenseTransactionModel>();
  var expenseRecurring = Rxn<ExpenseRecurringModel>();
  final Rx<ExpenceBarModel?> expenceBarModel = Rx<ExpenceBarModel?>(null);
  var dwmyDropdown = "1 M".obs;
  final RxBool hasFetchedExpence = false.obs;
  var totalExpenceAmount = 0.0.obs;
  var isVisible = false.obs;

  // Search-related properties
  // final searchController = TextEditingController();
  var searchQuery = ''.obs;

  // Computed list of filtered expenses
  List<Expense> get filteredExpenses {
    final expenses = expense.value?.body?.expenses ?? [];
    if (searchQuery.value.isEmpty) {
      return expenses;
    }
    return expenses
        .where((exp) => exp.description!
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  List<ExpenseRecurring> get filteredExpensesRecurring {
    final expenses = expenseRecurring.value?.body?.expenses ?? [];
    if (searchQuery.value.isEmpty) {
      return expenses;
    }
    return expenses
        .where((exp) => exp.description!
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchExpenseCategories();
    fetchExpense();
    fetchExpenceSummary();
    // fetchRecurringExpense();
    // Listen to search query changes to update filtered list
    // searchController.addListener(() {
    //   searchQuery.value = searchController.text;
    // });
  }

  @override
  void onClose() {
    // searchController.dispose();
    super.onClose();
  }

  String formatDate(String isoDateString) {
    try {
      DateTime dateTime = DateTime.parse(isoDateString).toLocal();
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void setVisibility(){
    isVisible.value = !isVisible.value;
  }

  Future<List<Map<String, dynamic>>> fetchExpenceSummary() async {
    var dwmyData = "1M".obs;
    if (dwmyDropdown.value == '1 M') {
      dwmyData = '1M'.obs;
    } else if (dwmyDropdown.value == '3 M') {
      dwmyData = '3M'.obs;
    } else if (dwmyDropdown.value == '6 M') {
      dwmyData = '6M'.obs;
    } else if (dwmyDropdown.value == '1 Y') {
      dwmyData = '1Y'.obs;
    } else if (dwmyDropdown.value == 'YTD') {
      dwmyData = 'YTD'.obs;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('userId');

    if (authToken == null || userId == null) {
      // throw Exception('User not authenticated');
      print("User not authenticated");
    }

    final response = await http.get(
      Uri.parse(
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/expenses/summary-advanced?range=$dwmyData'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
    print(response.request);
    print(".................${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true) {
        final List<dynamic> body = jsonData['body'];
        return body
            .map((item) => {
                  'monthName': item['monthName'],
                  'total': item['total'],
                })
            .toList();
      } else {
        // throw Exception(jsonData['message'] ?? 'Failed to fetch data');
        errorMessage.value  = jsonData['message'] ?? 'Failed to fetch data';
        return [];
      }
    } else {
      // throw Exception('Failed to load data: ${response.statusCode}');
      errorMessage.value =   'Failed to load data: ${response.statusCode}';
      return [];
    }
  }

  Future<void> fetchExpense() async {
    try {
      isLoadingExpence(true);

      final response = await BaseClient().get('${AppEndpoints.expenses}');

      print('Response Expenses: ${response}');

      if (response != null) {
        expense.value = ExpenseTransactionModel.fromJson(response);
        totalExpenceAmount.value = expense.value?.body?.totalExpense ?? 0;
      }
    } catch (e) {
      print("Exception while fetching expense: $e");
    } finally {
      isLoadingExpence(false);
    }
  }

  // Future<void> fetchRecurringExpense() async {
  //   try {
  //     isLoadingExpence(true);

  //     final response = await BaseClient().get('${AppEndpoints.expenseRecur}');

  //     print('Response Expenses Recurring: ${response}');

  //     if (response != null) {
  //       expenseRecurring.value = ExpenseRecurringModel.fromJson(response);
  //       print("Expense Recurring: ${expenseRecurring.value?.body?.expenses}");
  //     }
  //   } catch (e) {
  //     print("Exception while fetching expense: $e");
  //   } finally {
  //     isLoadingExpence(false);
  //   }
  // }

  void updateDropdown(String value) {
    dwmyDropdown.value = value;
  }

  // Expense category summary
  final ApiService _apiService = ApiService();
  var expenseCategories = <ExpenseCategory>[].obs;
  var isExpenseLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchExpenseCategories() async {
    try {
      isExpenseLoading.value = true;
      errorMessage.value = '';
      final data = await _apiService.fetchExpenseCategoryBreakdown(
          apiEndPoint: "/expenses/category-breakdown");
      expenseCategories.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExpenseLoading.value = false;
    }
  }
}
