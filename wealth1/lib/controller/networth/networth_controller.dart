import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/networth/networth_model.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/networth/networth_breakdown/networth_breakdown.dart';

class NetWorthController extends GetxController {
  final RxBool isVisibleLib = false.obs;
  final RxBool isVisibleAssets = false.obs;
  final RxString dwmyDropdown = "1 M".obs;
  final Rx<NetWorthResponse?> networth = Rx<NetWorthResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isVisible = false.obs;

  var categories = <NetworthCategory>[].obs;
  var errorMessage = RxnString();
  var totalSpend = 0.0.obs;

  final RxList<dynamic> filteredAssets = <dynamic>[].obs;
  final RxList<dynamic> filteredLiabilities = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  Future<void> _boot() async {
    await fetchNetWorth();
    await fetchNetworthChartSummary();
  }

  Future<void> fetchNetWorth() async {
    try {
      isLoading(true);
      final response = await BaseClient().get(AppEndpoints.networth);
      if (response != null) {
        networth.value = NetWorthResponse.fromJson(response);

        totalSpend.value =
            (networth.value?.body?.totalNetWorth ?? 1).toDouble();

        categories.value = networth.value!.body!.assets!.map((catData) {
          return NetworthCategory(
            formatCategoryName(catData.type ?? ''),
            formatCategoryName(catData.name ?? ''),
            getCategoryColor(catData.name ?? ''),
            catData.amount ?? 0.0,
            catData.percentage ?? '',
            catData.accountId ?? '',
            catData.bankName ?? '',
            catData.bankLogo ?? '',
            catData.accountNumber ?? '',
          );
        }).toList();

        // initialize filtered list
        filteredAssets.assignAll(networth.value?.body?.assets ?? []);
        filteredLiabilities.assignAll(networth.value?.body?.liabilities ?? []);
      }
    } catch (e) {
      print('Failed to load net worth data');
    } finally {
      isLoading(false);
    }
  }

  // 🔎 Search method
  void filterAssets(String query) {
    final allAssets = networth.value?.body?.assets ?? [];

    if (query.isEmpty) {
      filteredAssets.assignAll(allAssets);
    } else {
      final lower = query.toLowerCase();
      final filtered = allAssets.where((a) {
        final name = (a.name ?? '').toLowerCase();
        final bank = (a.bankName ?? '').toLowerCase();
        final acc = (a.accountNumber ?? '').toLowerCase();
        return name.contains(lower) ||
            bank.contains(lower) ||
            acc.contains(lower);
      }).toList();
      filteredAssets.assignAll(filtered);
    }
  }

  void filterLiabilities(String query) {
    final allLibs = networth.value?.body?.liabilities ?? [];
    if (query.isEmpty) {
      filteredLiabilities.assignAll(allLibs);
      return;
    }
    final q = query.toLowerCase();
    filteredLiabilities.assignAll(allLibs.where((l) {
      final type = (l.type ?? '').toLowerCase();
      final name = (l.name ?? '').toLowerCase();
      final bank = (l.bankName ?? '').toLowerCase();
      final acc = (l.accountNumber ?? '').toLowerCase();
      return type.contains(q) ||
          name.contains(q) ||
          bank.contains(q) ||
          acc.contains(q);
    }).toList());
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
      const Color(0xFFAA8EC6), // Light Purple
    ];

    final hash = category.hashCode;
    return colors[hash.abs() % colors.length];
  }

  void setVisibility(){
    isVisible.value = !isVisible.value;
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

  List<PieChartSectionData> buildPieChartSections() {
    if (totalSpend.value == 0 || categories.isEmpty) {
      return [];
    }

    // Fixed 5 colors
    final List<Color> fixedColors = [
      Color(0xFF1A93D9),
      Color(0xFF57ED6D),
      Color(0xFFEFCA39),
      Color(0xFFE37F51),
      Color(0xFFD93977),
    ];

    // Sort categories by spend and take top 5
    final topCategories = categories.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final displayCategories = topCategories.take(5).toList();

    return List.generate(displayCategories.length, (index) {
      final category = displayCategories[index];
      final percentage = totalSpend.value;

      return PieChartSectionData(
        color: fixedColors[index],
        showTitle: false,

        value: category.amount == 0 ? 1 : category.amount.toDouble(),
        title: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
            .format(category.amount), //'${percentage.toStringAsFixed(0)}%',
        radius: 10,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    });
  }

  //-------Chart Functions

  Future<List<Map<String, dynamic>>> fetchNetworthChartSummary() async {
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
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/networth/summary-advanced?range=$dwmyData'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    print("......................");

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

  // Future<List<Map<String, dynamic>>> fetchNetworthSummary() async {
  //   var dwmyData = "1M".obs;
  //   if (dwmyDropdown.value == '1 M') {
  //     dwmyData = '1M'.obs;
  //   } else if (dwmyDropdown.value == '3 M') {
  //     dwmyData = '3M'.obs;
  //   } else if (dwmyDropdown.value == '6 M') {
  //     dwmyData = '6M'.obs;
  //   } else if (dwmyDropdown.value == '1 Y') {
  //     dwmyData = '1Y'.obs;
  //   } else if (dwmyDropdown.value == 'YTD') {
  //     dwmyData = 'YTD'.obs;
  //   }

  //   final prefs = await SharedPreferences.getInstance();
  //   final authToken = prefs.getString('auth_token');
  //   final userId = prefs.getString('userId');

  //   if (authToken == null || userId == null) {
  //     throw Exception('User not authenticated');
  //   }

  //   final response = await http.get(
  //     Uri.parse(
  //         'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/networth/summary?range=$dwmyData'),
  //     headers: {
  //       'Authorization': 'Bearer $authToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //     if (jsonData['status'] == true) {
  //       final List<dynamic> body = jsonData['body'];
  //       return body
  //           .map((item) => {
  //                 'monthName':
  //                     item['monthName'], // Extracts "Feb" from "Feb 2025"
  //                 'liabilities': item['liabilities'],
  //               })
  //           .toList();
  //     } else {
  //       throw Exception(jsonData['message'] ?? 'Failed to fetch data');
  //     }
  //   } else {
  //     throw Exception('Failed to load data: ${response.statusCode}');
  //   }
  // }

  void toggleAssetsVisibility() {
    isVisibleAssets.toggle();
  }

  void toggleLiabilitiesVisibility() {
    isVisibleLib.toggle();
  }

  void setCashFlowDropdown(String value) {
    dwmyDropdown.value = value;
  }

  double getPercentAsset() {
    if (networth.value?.body?.totalNetWorth == null ||
        networth.value?.body?.totalAssets == null ||
        networth.value!.body!.totalAssets! == 0) {
      return 0;
    }
    return (networth.value!.body!.totalNetWorth!.toDouble() /
            networth.value!.body!.totalAssets!.toDouble()) *
        100;
  }

  double getPercentLiability() {
    if (networth.value?.body?.totalLiabilities == null ||
        networth.value?.body?.totalAssets == null ||
        networth.value!.body!.totalAssets! == 0) {
      return 0;
    }
    return (networth.value!.body!.totalLiabilities!.toDouble() /
            networth.value!.body!.totalAssets!.toDouble()) *
        100;
  }
}
