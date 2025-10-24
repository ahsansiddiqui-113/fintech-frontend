import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/income/income_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

import '../../models/expense/expense_category.dart';
import '../../services/crypto_news_services.dart';

class IncomeController extends GetxController {
  var dwmyDropdown = "1 M".obs;
  var isLoading = false.obs;
  var isLoadingIncome = false.obs;
  var income = Rxn<IncomeModel>();
  var incomeToEdit = Rxn<Map<String, dynamic>>();

  var transactions = Rxn<IncomeModel>();
  var filteredTransactions = <Income>[].obs;

  final TextEditingController searchController = TextEditingController();

  final RxBool hasFetchedIncome =
      false.obs;
  var totalIncomeAmount = 0.0.obs;
  var isVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      incomeToEdit.value = Get.arguments['incomeToEdit'];
    }
    fetchExpenseCategories();
    fetchIncome();
    fetchIncomeSummary();
  }

  void filterTransactions() {

    final searchTerm = searchController.text.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      filteredTransactions.clear();
      filteredTransactions.addAll(transactions.value?.body?.incomes ?? []);
    } else {
      final allIncomes = transactions.value?.body?.incomes ?? [];
      final filtered = allIncomes.where((txn) {
        if (txn.name == null) return false;
        return txn.name!.toLowerCase().contains(searchTerm);
      }).toList();
      filteredTransactions.clear();
      filteredTransactions.addAll(filtered);
    }
  }

  Future<void> fetchIncome({bool force = false}) async {
    if (hasFetchedIncome.value && !force) return;

    try {
      isLoadingIncome(true);

      final response = await BaseClient().get(AppEndpoints.incomes);

      if (response != null) {
        // final jsonData = jsonDecode(response.body);
        income.value = IncomeModel.fromJson(response);
        totalIncomeAmount.value = income.value?.body?.totalIncomeAmount ?? 0;
        print("Response............ Income: ${ response}");

        transactions.value = income.value;
        filteredTransactions.clear();
        filteredTransactions.addAll(income.value?.body?.incomes ?? []);
        transactions.refresh();
        filteredTransactions.refresh();
        errorMessage.value = '';
        hasFetchedIncome.value = true;
      }
    } catch (e) {
      print("Exception while fetching income: $e");
    } finally {
      isLoadingIncome(false);
    }
  }



  Future<List<Map<String, dynamic>>> fetchIncomeSummary() async {
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
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/income-summary?range=$dwmyData'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

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
        errorMessage.value = jsonData['message'] ?? 'Failed to fetch data';
        return [];
      }
    } else {
      // throw Exception('Failed to load data: ${response.statusCode}');
      errorMessage.value = 'Failed to load data: ${response.statusCode}';
      return [];
    }
  }

  void updateDropdown(String value) {
    dwmyDropdown.value = value;
  }

  // expense category summary
  final ApiService _apiService = ApiService();
  var expenseCategories = <ExpenseCategory>[].obs;
  var isExpenseLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchExpenseCategories() async {
    try {
      isExpenseLoading.value = true;
      errorMessage.value = '';
      final data = await _apiService.fetchExpenseCategoryBreakdown(
          apiEndPoint: "/incomes/category-breakdown");
      expenseCategories.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExpenseLoading.value = false;
    }
  }

  void setVisibility(){
    isVisible.value = !isVisible.value;
  }
}
