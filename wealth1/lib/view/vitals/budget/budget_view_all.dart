import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class BudgetViewAll extends StatelessWidget {
  BudgetViewAll({super.key, required this.title});

  final String? title;
  final BudgetController _budgetController = Get.put(BudgetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: title),
      body: Obx(() {
        if (_budgetController.isLoading.value) {
          return _budgetController.buildShimmerEffect();
        } else if (_budgetController.budgetResponse.value == null) {
          return Empty(
            title: 'Budget',
            width: 140,
          );
        } else {
          final budgets = _budgetController.budgetResponse.value?.body;

          return Container(
            margin:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: budgets?.category?.length,
                    itemBuilder: (context, index) {
                      final budget = budgets?.category?[index];
                      return buildBudgetItem(
                        context,
                        budget?.categoryName ?? '',
                        budget?.budgetRemaining?.toInt() ?? 0,
                        budget?.budgetSpend?.toInt() ?? 0,
                        budget?.budgetAmount ?? 0,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget buildBudgetItem(BuildContext context, String categoryName,
      int remaining, int spent, int total, int index) {
    double progress = 0;
    double progressPre = 0;

    if (spent == 0 || total == 0) {
      progress = 0;
      progressPre = 0;
    } else {
      progress = spent / total;
      final progressPre = (spent / total) * 100;


      print('TOtal: $total');
      print('Spent Precent: $spent');
      print('Progress: $progress');
      print('Progress Precent: $progressPre');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$categoryName',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          addHeight(7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limit: \$$total',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                'Spend: \$$spent',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining: \$$remaining',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    progressPre.toStringAsFixed(0) == "Infinity" ? "Infinity" : '${progressPre.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // color: context.gc(AppColor.primary),
              value:progress >= 1 ? 1 : progress,

              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>((progressPre >= 80)
                  ? context.gc(AppColor.redColor)
                  : context.gc(AppColor.primary)),
            ),
          ),
          addHeight(5),
          Divider(),
        ],
      ),
    );
  }
}
