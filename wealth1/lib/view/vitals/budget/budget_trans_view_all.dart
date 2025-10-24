import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

import '../../../models/budget/budget_model.dart';

class BudgetTransViewAll extends StatelessWidget {
  BudgetTransViewAll({super.key, required this.title});

  final String? title;
  final BudgetController _budgetController = Get.put(BudgetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: title),
      body: Obx(() {
        if (_budgetController.isLoading.value || _budgetController.budgetResponse.value == null) {
          return _budgetController.buildShimmerEffect();
        } else if (_budgetController.budgetResponse.value == null) {
          return Empty(
            title: 'Budget Transaction',
            width: 140,
          );
        } else {
          return Container(
            margin:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF000000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                      controller: _budgetController.searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        fillColor: Colors.amber,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(width: 0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(46, 173, 165, 1)),
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ),
                      onChanged: (value) {
                        _budgetController.filterTransactions();
                      }),
                ),

                addHeight(16),
                Expanded(child: buildBudgetList(_budgetController)),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget buildBudgetList(BudgetController controller) {
    final groupedBudgets = controller.groupedBudgets;

    return ListView.builder(
      itemCount: groupedBudgets.length,
      itemBuilder: (context, groupIndex) {
        String dateLabel = groupedBudgets.keys.elementAt(groupIndex);
        List<Budget> dateBudgets = groupedBudgets[dateLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budgets under this date
            ...dateBudgets.map((budget) => GestureDetector(
                  onTap: () {
                    Get.to(() => TransationReceipt(
                          id: budget.id,
                          name: budget.description,
                          amount: budget.amount.toString(),
                          date: budget.date.toString(),
                          category: budget.category,
                        ));
                  },
                  child: buildIncomeDetailItem(
                    context,
                    index: groupIndex,
                    listtype: 'Budget',
                    title: '${budget.description}',
                    amount: '\$${budget.amount?.toInt()}',
                    length: groupedBudgets.length,
                    subtitle: formatDateAndTime(budget.date.toString()),
                    persentage: '',
                    logo: budget.logo ?? ImagePaths.dfbudget,
                  ),
                )),
          ],
        );
      },
    );
  }
}
