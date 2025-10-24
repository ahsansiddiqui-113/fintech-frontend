import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/models/investment/overview_investment/overview_investment_model.dart'; // New model import

class OverviewController extends GetxController {
  final Rx<ChartResponse?> chartResponse = Rx<ChartResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedTab = '1 M'.obs;
  final RxString selectedStockTab = '1 M'.obs;
  final RxString selectedCryptoTab = '1 M'.obs;

  final RxDouble totalInvestment_overview = 0.0.obs;
  final RxDouble totalInvestment_crypto = 0.0.obs;
  final RxDouble totalInvestment_stocks = 0.0.obs;
  final RxDouble totalInvestment_funds = 0.0.obs;
  final RxDouble totalInvestment_others = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverviewSummary();
    fetchStockSummary();
    fetchCryptoSummary();
  }

  Future<void> fetchOverviewSummary() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String range = _getRangeFromTab(selectedTab.value);

      final response = await _makeApiCall(range);
      final chartResponse = ChartResponse.fromJson(jsonDecode(response.body));

      if (chartResponse.status) {
        this.chartResponse.value = chartResponse;
        totalInvestment_overview.value = chartResponse.body.totalInvestOverview;
        totalInvestment_crypto.value = chartResponse.body.totalInvestCrypto;
        totalInvestment_stocks.value = chartResponse.body.totalInvestStocks;
        totalInvestment_funds.value = chartResponse.body.totalInvestFunds;
        totalInvestment_others.value = chartResponse.body.totalInvestOthers;
        // return chartResponse;
      } else {
        // throw Exception(chartResponse.message);
        errorMessage.value = chartResponse.message;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ChartResponse> fetchStockSummary() async {
    return _fetchSummary(selectedStockTab.value);
  }

  Future<ChartResponse> fetchCryptoSummary() async {
    return _fetchSummary(selectedCryptoTab.value);
  }

  Future<ChartResponse> _fetchSummary(String tab) async {
    try {
      String range = _getRangeFromTab(tab);
      final response = await _makeApiCall(range);
      return ChartResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    }
  }

  Future<http.Response> _makeApiCall(String range) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('userId');

    if (authToken == null || userId == null) {
      // throw Exception('User not authenticated');
      print("User not authenticated");
    }

    return await http.get(
      Uri.parse(
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/investments/chart?range=$range'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
  }

  String _getRangeFromTab(String tab) {
    switch (tab) {
      case '1 M':
        return '1M';
      case '3 M':
        return '3M';
      case '6 M':
        return '6M';
      // case '6 M':
      //   return '6M';
      case '1 Y':
        return '1Y';
      case 'YTD':
        return 'YTD';
      default:
        return '1M';
    }
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    fetchOverviewSummary();
  }

  void changeStockTab(String tab) {
    selectedStockTab.value = tab;
    fetchStockSummary();
  }

  void changeCryptoTab(String tab) {
    selectedCryptoTab.value = tab;
    fetchCryptoSummary();
  }

  Widget buildTab(String title) {
    final isSelected = selectedTab.value == title;
    return GestureDetector(
      onTap: () {
        if (selectedTab == this.selectedTab)
          changeTab(title);
        else if (selectedTab == selectedStockTab)
          changeStockTab(title);
        else
          changeCryptoTab(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF313131) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),

          border: Border.all(
            color: isSelected ? const Color(0xFF313131) : Colors.transparent,
            width: 0.25,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
