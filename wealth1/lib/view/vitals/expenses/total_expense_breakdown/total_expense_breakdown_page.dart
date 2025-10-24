import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/expenses/total_expense_breakdown/total_expense_breakdown_shimmer.dart';

import '../../../../controller/expenses/add_break_down_controller.dart';
import '../../../../widgets/custom_app_bar.dart';

class TotalExpenseBreakdownPage extends StatelessWidget {
  TotalExpenseBreakdownPage({super.key});
  final controller = Get.put(ExpenseBreakdownController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Total Expense'),
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

  Widget _buildBody(ExpenseBreakdownController controller) {
    if (controller.isLoading.value) {
      // return const Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       CircularProgressIndicator(color: Colors.teal),
      //       SizedBox(height: 16),
      //       Text(
      //         'Loading expenses...',
      //         style: TextStyle(color: Colors.white70, fontSize: 16),
      //       ),
      //     ],
      //   ),
      // );
      return TotalExpenseShimmer();
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
              onPressed: () => controller.fetchExpenseData(),
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
              'No Expenses Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your expenses by adding some transactions.',
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

    // Sort categories by amount in descending order and take top 5 for legend
    final topCategories = controller.categories.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final displayCategories = topCategories.take(5).toList();

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
                    curve: Curves.bounceInOut,
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 70,
                      sections: controller.buildPieChartSections(),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.grey[900],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.7),
                        width: 0.5,
                      ),
                      // borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(Get.width * 0.07),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Obx(() => Text(
                              '\$${controller.totalExpense.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.11,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
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
                                .color, // Use the same color as the pie chart), // same color as pie chart
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
                          '\$${category.amount.toStringAsFixed(0)}',
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
        const SizedBox(height: 53),
        // Transactions List
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  final isLastItem =
                      index == controller.transactions.length - 1;

                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12, top: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: transaction.color.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                transaction.icon,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${transaction.date}   ${transaction.time}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${transaction.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLastItem)
                        Divider(
                          color: Colors.white24,
                          thickness: 0.5,
                          height: 0,
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
class ExpenseCategory {
  final String name;
  final double amount;
  final Color color;
  final String id;
  final String date;
  final String originalName;

  ExpenseCategory(
    this.name,
    this.amount,
    this.color,
    this.id,
    this.date,
    this.originalName,
  );
}

class Transaction {
  final String title;
  final String date;
  final String time;
  final double amount;
  final IconData icon;
  final Color color;

  Transaction(
      this.title, this.date, this.time, this.amount, this.icon, this.color);
}
