import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/cashflow/cashflow_graph_model.dart';
import 'package:wealthnx/models/cashflow/cashflow_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

class CashFlowController extends GetxController {
  var isLoading = true.obs;
  var cashflow = Rxn<CashFlowModel>();
  var dwmyDropdown = "1 M".obs;
  var totalCashFlowAmount = 0.0.obs;

  var incometransactions = Rxn<CashFlowModel>();
  var filteredincomeTransactions = <CategoryBreakdown>[].obs;

  var expencetransactions = Rxn<CashFlowModel>();
  var filteredexpenceTransactions = <CategoryBreakdown>[].obs;

  final TextEditingController searchincomeController = TextEditingController();
  final TextEditingController searchexpenseController = TextEditingController();
  var isVisible = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchCashFlowDetails();
    fetchCashflowSummary();
  }

  Future<void> fetchCashFlowDetails() async {
    try {
      isLoading(true);

      final response = await BaseClient().get(AppEndpoints.cashflow);
      if (response != null) {
        cashflow.value = CashFlowModel.fromJson(response);
        totalCashFlowAmount.value = cashflow.value?.body?.cashflow ?? 0;
        incometransactions.value = cashflow.value;
        expencetransactions.value = cashflow.value;

        filteredincomeTransactions.clear();
        filteredexpenceTransactions.clear();

        filteredincomeTransactions
            .addAll(cashflow.value?.body?.incomeBreakdown ?? []);
        filteredexpenceTransactions
            .addAll(cashflow.value?.body?.expenseBreakdown ?? []);

        incometransactions.refresh();
        expencetransactions.refresh();

        filteredincomeTransactions.refresh();
        filteredexpenceTransactions.refresh();
      } else {
        print("Failed to load Cashflow data");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      isLoading(false);
    }
  }

//Income Search
  void filterIncomeTransactions() {
    final searchTerm = searchincomeController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      filteredincomeTransactions
          .assignAll(incometransactions.value?.body?.incomeBreakdown ?? []);
    } else {
      filteredincomeTransactions.assignAll(
        (incometransactions.value?.body?.incomeBreakdown ?? []).where((txn) =>
            txn.description?.toLowerCase().contains(searchTerm) ?? false),
      );
    }
    filteredincomeTransactions.refresh(); // ✅ Ensure UI updates after filtering
  }

//Expence Search
  void filterExpenceTransactions() {
    final searchTerm = searchexpenseController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      filteredexpenceTransactions
          .assignAll(expencetransactions.value?.body?.expenseBreakdown ?? []);
    } else {
      filteredexpenceTransactions.assignAll(
        (expencetransactions.value?.body?.expenseBreakdown ?? []).where((txn) =>
            txn.description?.toLowerCase().contains(searchTerm) ?? false),
      );
    }
    filteredexpenceTransactions
        .refresh(); // ✅ Ensure UI updates after filtering
  }

  Future<List<Map<String, dynamic>>> fetchCashflowSummary() async {
    print("dwmyDropdown: ${dwmyDropdown.value}");
    // print("dwmyDropdown: ${dwmyDropdown.value}");
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
      debugPrint('User not authenticated');

      // throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse(
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/cashflow-summary?range=$dwmyData'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
    log(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true) {
        final model = CashFlowGraphModel.fromJson(jsonData);
        // final List<dynamic> body = jsonData['body'];
        // return body
        //     .map((item) => {
        //           'throw ExceptionmonthName':
        //               item['monthName'], // Extracts "Feb" from "Feb 2025"
        //           'total': item['total'],
        //         })
        //     .toList();
        return model.body.map((entry) => entry.toJson()).toList();
      } else {
        debugPrint('${jsonData['message']} ?? Failed to fetch data');
        return [];
        // throw Exception(jsonData['message'] ?? 'Failed to fetch data');
      }
    } else {
      debugPrint('Failed to load data: ${response.statusCode}');
      return [];
      // throw Exception('Failed to load data: ${response.statusCode}');
      // return [];
    }
  }

  String formatMonth(String yearMonth) {
    final date = DateTime.parse('$yearMonth-01');
    return DateFormat('MMMM').format(date);
  }

  void updateDropdown(String value) {
    dwmyDropdown.value = value;
  }

  void setVisibility() {
    isVisible.value = !isVisible.value;
  }
}
