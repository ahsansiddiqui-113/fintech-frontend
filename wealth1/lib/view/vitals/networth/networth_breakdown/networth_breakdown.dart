import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/view/vitals/expenses/expense_shimmer_effect_screen.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

import '../../../../utils/app_helper.dart';
import '../../../../utils/app_urls.dart';
import '../../../../widgets/custom_app_bar.dart';

// Stateless Widget
class NetworthBreakdown extends StatelessWidget {
  NetworthBreakdown({super.key, this.totalBudget});
  String? totalBudget;
  final controller = Get.put(NetWorthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Net Worth'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color.fromRGBO(78, 78, 78, 0.46).withOpacity(0.46),
              width: 0.7,
            ),
          ),
          child: Obx(() => _buildBody(controller)),
        ),
      ),
    );
  }

  Widget _buildBody(NetWorthController controller) {
    if (controller.isLoading.value) {
      // return const Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       CircularProgressIndicator(color: Colors.teal),
      //       SizedBox(height: 16),
      //       Text(
      //         'Loading networth...',
      //         style: TextStyle(color: Colors.white70, fontSize: 16),
      //       ),
      //     ],
      //   ),
      // );
      return ExpenseShimmerEffectScreen();
    }

    if (controller.errorMessage.value != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.fetchNetWorth(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No Networth Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your budgets by adding some transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sort categories by spend amount in descending order and take top 5 for legend
    final topCategories = controller.categories.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final displayCategories = topCategories.take(5).toList();

    print("Length : ${topCategories.length}");

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        // Chart and Legend Section
        Row(
          children: [
            // Pie Chart
            const SizedBox(width: 20),
            SizedBox(
              width: 158,
              height: 158,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 70,
                      sections: controller.buildPieChartSections(),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.7),
                        width: 0.5,
                      ),
                    ),
                    padding: EdgeInsets.all(Get.width * 0.07),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Networth',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${totalBudget}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Legend

            Expanded(
              flex: 2,
              child: Column(
                children: List.generate(displayCategories.length, (index) {
                  final category = displayCategories[index];

                  print('print index: $index');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: controller
                                .buildPieChartSections()[index]
                                .color, // Use the same color as the pie chart
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        addWidth(8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(category.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            )
          ],
        ),
        const SizedBox(height: 40),

        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final networth = controller.categories[index];
                  return Column(
                    children: [
                      Column(
                        children: [
                          buildIncomeDetailItem(context,
                              index: index,
                              title: networth.name,
                              amount: '\$${networth.amount.toInt()}',
                              length: controller.categories.length,
                              subtitle:
                                  '...${networth.accountNumber.substring(0, 3)} ${networth.bankName}',
                              persentage: '',
                              icon: (networth.bankLogo == 'null' ||
                                      networth.bankLogo == null)
                                  ? networth.bankLogo
                                  : AppEndpoints.profileBaseUrl +
                                      networth.bankLogo)
                        ],
                      ),
                    ],
                  );
                },
              )),
        )
      ],
    );
  }
}

// Model Classes
class NetworthCategory {
  final String type;
  final String name;
  final Color color;
  final double amount;
  final String percentage;
  final String accountId;
  final String bankName;
  final String bankLogo;
  final String accountNumber;

  NetworthCategory(
    this.type,
    this.name,
    this.color,
    this.amount,
    this.percentage,
    this.accountId,
    this.bankName,
    this.bankLogo,
    this.accountNumber,
  );
}
