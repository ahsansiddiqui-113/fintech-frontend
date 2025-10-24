import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';

import 'package:wealthnx/models/expense/expense_transaction.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

import '../transations/transation_receipt.dart';

class ExpenseTransactions extends StatefulWidget {
  @override
  State<ExpenseTransactions> createState() => _ExpenseTransactionsState();
}

class _ExpenseTransactionsState extends State<ExpenseTransactions> {
  final ExpensesController controller =
      Get.find<ExpensesController>(); // ✅ no duplicate put
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      controller.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // ✅ UI owns & disposes it safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Expense Transactions'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return buildlistShimmerEffect();
        } else if (controller.expense.value == null) {
          return Center(
              child: Empty(title: 'Expense Transactions', width: 140));
        } else {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController, // ✅ local controller
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(CupertinoIcons.search, color: Colors.grey),
                      suffixIcon: Obx(() => IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: controller.searchQuery.value.isNotEmpty
                                  ? Colors.grey
                                  : Colors.transparent,
                            ),
                            onPressed: controller.searchQuery.value.isNotEmpty
                                ? () {
                                    _searchController.clear();
                                    controller.searchQuery.value = '';
                                  }
                                : null,
                          )),
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(46, 173, 165, 1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = controller.filteredExpenses[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => TransationReceipt(
                                    id: expense.id,
                                    name: expense.description,
                                    amount: expense.amount.toString(),
                                    date: expense.date.toString(),
                                    category: expense.category,
                                  ));
                            },
                            child: buildIncomeDetailItem(
                              context,
                              index: index,
                              listtype: 'Expense',
                              title: '${expense.description}',
                              amount: expense.amount.toString(),
                              length: controller.filteredExpenses.length,
                              subtitle:
                                  formatDateAndTime(expense.date.toString()),
                              persentage: '',
                              logo: expense.logo_url ?? ImagePaths.dfexpense,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(
                            thickness: 0.25, height: 2, color: Colors.grey),
                      )),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
