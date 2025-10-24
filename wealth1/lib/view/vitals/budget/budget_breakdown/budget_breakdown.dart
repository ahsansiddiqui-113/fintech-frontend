import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/view/vitals/budget/add_budget.dart';

import '../../../../controller/comman_controller.dart';
import '../../../../utils/app_helper.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../../../widgets/custom_list_item.dart';
import '../../../../controller/budget/budget_controller.dart';

class BudgetBreakdownPage extends StatelessWidget {
  BudgetBreakdownPage({super.key, this.totalBudget});
  final String? totalBudget;

  final BudgetController controller = Get.isRegistered<BudgetController>()
      ? Get.find<BudgetController>()
      : Get.put(BudgetController());
  final CommonController _commonController = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Total Budget'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromRGBO(78, 78, 78, 0.46),
              width: 0.7,
            ),
          ),
          child: Obx(() => _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoadingBudget.value && controller.categories.isEmpty) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text('Error Loading Data',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final cats = controller.categories;
    if (cats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text('No Budgets Found',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
              'Start tracking your budgets by adding some transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Compute once to keep legend colors aligned
    final sections = controller.buildPieChartSections();

    // Legend: take top 5 by amount
    final legendSorted = [...cats]
      ..sort((a, b) => b.budgetAmount.compareTo(a.budgetAmount));
    final display = legendSorted.take(5).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
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
                      sections: sections,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.7), width: 0.5),
                    ),
                    padding: EdgeInsets.all(Get.width * 0.07),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Budget',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          '${totalBudget}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.11,
                              fontWeight: FontWeight.w500),
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
                children: List.generate(display.length, (i) {
                  final c = display[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: controller.getPieCategoryColor(
                                c.budgetAmount, cats),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.formatCategoryName(c.categoryName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        addWidth(6),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(c.budgetAmount),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: 53),

        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _commonController.textWidget(Get.context!,
                title: 'Budget List',
                fontSize: responTextWidth(16),
                fontWeight: FontWeight.w600),
            const Spacer(),
            _commonController.textWidget(Get.context!,
                title: 'Budget',
                fontSize: responTextWidth(12.7),
                fontWeight: FontWeight.w400),
            SizedBox(width: Get.width * 0.08),
            _commonController.textWidget(Get.context!,
                title: 'Remaining',
                fontSize: responTextWidth(12.7),
                fontWeight: FontWeight.w400),
          ],
        ),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final b = cats[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => AddBudget(
                        title: 'Edit Budget',
                        amount: b.budgetAmount.toString(),
                        id: b.id,
                        category: controller.formatCategoryName(b.categoryName),
                        iconData: controller.getIconForCategory(b.categoryName),
                        IconColors: controller.getCategoryColor(b.categoryName),
                      ));
                },
                child: buildBudgetItemCustom(
                  index: index,
                  icon: controller.getIconForCategory(b.categoryName),
                  id: b.id,
                  category: controller.formatCategoryName(b.categoryName),
                  iconColor: controller.getCategoryColor(b.categoryName),
                  title: controller.formatCategoryName(b.categoryName),
                  budget: cats[index].budgetAmount.toString(),
                  remaining: cats[index].budgetRemaining.toStringAsFixed(0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
