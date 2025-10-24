import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
import 'package:wealthnx/models/net_worth/net_worth';
// import 'dart:convert';
// import 'package:wealthnx/models/networth/networth_model.dart';
import 'package:wealthnx/services/crypto_news_services.dart';

class NetWorthNewController extends GetxController {
  final ApiService _apiService = ApiService();
  var netWorthList = <NetWorthSummary>[].obs;
  var netWorthEmptyList = <NetWorthSummary>[
    NetWorthSummary(
      asset: 00.0,
      liabilities: 20.0,
      monthName: 'Jan',
    ),
    NetWorthSummary(
      asset: 20.0,
      liabilities: 20.0,
      monthName: 'Feb',
    ),
    NetWorthSummary(
      asset: 20.0,
      liabilities: 20.0,
      monthName: 'Mar',
    ),
    NetWorthSummary(
      asset: 20.0,
      liabilities: 20.0,
      monthName: 'Apr',
    ),
    NetWorthSummary(
      asset: 20.0,
      liabilities: 20.0,
      monthName: 'May',
    ),NetWorthSummary(
      asset: 20.0,
      liabilities: 20.0,
      monthName: 'June',
    ),

  ].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNetWorthData(); // Pass userId if needed
  }

  Future<void> fetchNetWorthData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _apiService.fetchNetWorthSummary();
      netWorthList.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      // Get.snackbar('Error', errorMessage.value,
      //     snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
