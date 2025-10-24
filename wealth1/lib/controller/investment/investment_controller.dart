import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/investment/investment_overview_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

import '../../services/crypto_news_services.dart';
import '../genral_news/press_release_news_controller.dart';

class InvestmentController extends GetxController {
  final isLoading = false.obs;

  final investmentOverview = Rx<InvestmentOverview?>(null);

  final RxString selectedTab = 'Crypto'.obs;

  @override
  void onInit() {
    super.onInit();

    fetchInvestmentOverview();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  Widget buildTab(String title) {
    return Obx(() {
      final isSelected = selectedTab.value == title;
      return GestureDetector(
        onTap: () {
          final PressReleaseNewsController pressReleaseController =
              Get.find<PressReleaseNewsController>();
          cryptoType = title;

          pressReleaseController.fetchPaginatedNews(isFirstLoad: true);

          print('Change Tab: $title');
          changeTab(title);

        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(46, 173, 165, 1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(46, 173, 165, 1)
                  : Colors.grey,
              width: 0.5,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Future<void> fetchInvestmentOverview() async {
    try {
      isLoading(true);

      final response = await BaseClient().get(
        '${AppEndpoints.investmentPortfolio}',
      );

      print('Responce Investment: ${response}');

      if (response != null) {
        // final data = jsonDecode(response.body);
        investmentOverview.value = InvestmentOverview.fromJson(response);
      }
    } catch (e) {
      print("Exception while fetching expense: $e");
    } finally {
      isLoading(false);
    }
  }
}
