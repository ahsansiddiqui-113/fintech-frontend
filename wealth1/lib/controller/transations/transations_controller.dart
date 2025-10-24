import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/models/transations/transations_model.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class TransactionsController extends GetxController {
  var isLoadingTran = false.obs;
  var transactions = Rxn<TransationsModel>();
  var filteredTransactions = <TransBody>[].obs;
  var errorMessage = ''.obs;
  var hasFetched = false.obs;
  var hasFetchedTrans = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(filterTransactions);
  }

  void showBlurDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation1, __, ___) {
        return FadeTransition(
          opacity: animation1,
          child: Stack(
            children: [
              // 🔹 Fullscreen Dialog UI
              Scaffold(
                  backgroundColor: Colors.transparent,
                  body: GestureDetector(
                    onTap: () {
                      // Get.to(Account)
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: marginSide()),
                        child: Center(
                          child: Image.asset(
                            ImagePaths.vitalnotcon,
                            fit: BoxFit.contain,
                            // height: responTextHeight(16),
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  // Future<void> fetchPlaidNotConnectedCaseTransations() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final authToken = prefs.getString('auth_token') ?? '';
  //   final userId = prefs.getString('userId') ?? '';

  //   try {
  //     print('Starting fetch...');
  //     isLoadingTran.value = true;
  //     errorMessage.value = '';

  //     final response = await http
  //         .post(
  //           Uri.parse(
  //               'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/plaid/transactions'),
  //           headers: {
  //             'Authorization': 'Bearer $authToken',
  //             'Content-Type': 'application/json',
  //           },
  //           body: jsonEncode({}), // Ensure empty body is sent correctly
  //         )
  //         .timeout(const Duration(minutes: 1));

  //     print('Response status: ${response.statusCode}');
  //     print(
  //         'Response body: ${response.body.length > 1000 ? response.body.substring(0, 1000) : response.body}');

  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //       final model = TransationsModel.fromJson(jsonData);

  //       print('Parsed transactions: ${model.body?.length ?? 0} items');
  //     } else if (response.statusCode == 404) {
  //       return showBlurDialog(Get.context!);
  //     }
  //   } catch (e) {
  //     isLoadingTran.value = false;
  //   } finally {
  //     isLoadingTran.value = false;
  //   }
  // }

  Future<void> fetchTransations(
      {bool force = false, int retryCount = 0, int maxRetries = 2}) async {
    if (hasFetchedTrans.value && !force) return;

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    print('=== FETCH TRANSACTIONS ===');
    print('Auth Token: ${authToken.isNotEmpty ? authToken : 'Missing'}');
    print('User Id: $userId');
    print('Has Fetched: ${hasFetched.value}');
    print('Force: $force');
    print('Retry Count: $retryCount/$maxRetries');
    print('Current Loading State: ${isLoadingTran.value}');

    if (hasFetched.value && !force) {
      print('Skipping fetch - already fetched and not forced');
      return;
    }

    if (isLoadingTran.value) {
      print('Skipping fetch - already loading');
      return;
    }

    try {
      print('Starting fetch...');
      isLoadingTran.value = true;
      errorMessage.value = '';

      final response = await http
          .post(
            Uri.parse(
                'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/$userId/plaid/transactions'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({}), // Ensure empty body is sent correctly
          )
          .timeout(const Duration(minutes: 1));

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body.length > 1000 ? response.body.substring(0, 1000) : response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = TransationsModel.fromJson(jsonData);

        print('Parsed transactions: ${model.body?.length ?? 0} items');

        transactions.value = model;
        filteredTransactions.clear();
        filteredTransactions.addAll(model.body ?? []);
        transactions.refresh();
        filteredTransactions.refresh();
        hasFetched.value = true;
        errorMessage.value = '';

        print('✅ Transactions loaded: ${filteredTransactions.length} items');
      } else if (response.statusCode == 500 && retryCount < maxRetries) {
        print(
            '⚠️ Server error (500). Retrying in 2s... (${retryCount + 1}/$maxRetries)');
        await Future.delayed(Duration(seconds: 2));
        return fetchTransations(
            force: force, retryCount: retryCount + 1, maxRetries: maxRetries);
      } else {
        errorMessage.value =
            'Failed to load transactions. Status: ${response.statusCode}';
        print('❌ API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (retryCount < maxRetries &&
          e.toString().contains('TimeoutException')) {
        print(
            '⚠️ Timeout error. Retrying in 2s... (${retryCount + 1}/$maxRetries)');
        await Future.delayed(Duration(seconds: 2));
        return fetchTransations(
            force: force, retryCount: retryCount + 1, maxRetries: maxRetries);
      }
      errorMessage.value = 'Error: $e';
      print('❌ Exception while fetching Transactions: $e');
    } finally {
      isLoadingTran.value = false;
      print('=== FETCH COMPLETE ===');
      print(
          'Final state - Loading: ${isLoadingTran.value}, HasFetched: ${hasFetched.value}, Transactions: ${transactions.value?.body?.length ?? 0}');
    }
  }

  void filterTransactions() {
    final searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      filteredTransactions.assignAll(transactions.value?.body ?? []);
    } else {
      filteredTransactions.assignAll(
        (transactions.value?.body ?? []).where(
            (txn) => txn.title?.toLowerCase().contains(searchTerm) ?? false),
      );
    }
    filteredTransactions.refresh(); // ✅ Ensure UI updates after filtering
  }

  // ✅ Add method to reset data (useful for debugging)
  void resetData() {
    hasFetched.value = false;
    transactions.value = null;
    filteredTransactions.clear();
    errorMessage.value = '';
    isLoadingTran.value = false;
  }

  String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    if (now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day) {
      return 'Today';
    } else {
      return DateFormat('dd MMMM yyyy').format(localDate);
    }
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String formatTime(String dateStr) {
    final dateTime = DateTime.parse(dateStr).toLocal();
    return DateFormat.jm().format(dateTime);
  }

  Map<String, List<TransBody>> get groupedTransactions {
    final Map<String, List<TransBody>> grouped = {};
    for (var txn in filteredTransactions) {
      if (txn.date != null) {
        String label = formatTransactionDate(txn.date!);
        grouped.putIfAbsent(label, () => []).add(txn);
      } else {
        print('⚠️ Skipping transaction with null date: ${txn.toJson()}');
      }
    }
    print('Grouped Transactions: ${grouped.keys.length} groups');
    grouped.forEach((key, value) {
      print('  Group "$key": ${value.length} transactions');
      value.forEach((txn) => print(
          '    - ${txn.title}, Amount: ${txn.amount}, Date: ${txn.date}'));
    });
    return grouped;
  }

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    searchController.removeListener(filterTransactions);
    searchController.clear();
    super.onClose();
  }
}
