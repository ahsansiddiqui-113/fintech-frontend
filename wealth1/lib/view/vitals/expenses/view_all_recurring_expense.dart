import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/models/expense/expense_transaction.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';
import '../transations/transation_receipt.dart';

class ViewAllRecurringExpense extends StatelessWidget {
  final bool showRecurringOnly;
  ViewAllRecurringExpense({this.showRecurringOnly = true, Key? key})
      : super(key: key);

  final ExpensesController controller = Get.put(ExpensesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Recurring Expense'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return buildlistShimmerEffect();
        } else if (controller.expense.value == null) {
          return Center(
            child: Empty(
              title: 'Recurring Expense',
              width: 140,
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  // TextFormField(
                  //   controller: controller.searchController,
                  //   style: const TextStyle(color: Colors.white),
                  //   decoration: InputDecoration(
                  //     prefixIcon:
                  //         const Icon(CupertinoIcons.search, color: Colors.grey),
                  //     suffixIcon: Obx(() => IconButton(
                  //           icon: Icon(
                  //             Icons.clear,
                  //             color: controller.searchQuery.value.isNotEmpty
                  //                 ? Colors.grey
                  //                 : Colors.transparent,
                  //           ),
                  //           onPressed: controller.searchQuery.value.isNotEmpty
                  //               ? () {
                  //                   controller.searchController.clear();
                  //                   controller.searchQuery.value = '';
                  //                 }
                  //               : null,
                  //         )),
                  //     hintText: 'Search',
                  //     hintStyle: const TextStyle(color: Colors.grey),
                  //     filled: true,
                  //     fillColor: Colors.black,
                  //     border: const OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     ),
                  //     enabledBorder: const OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //       borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  //     ),
                  //     focusedBorder: const OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //       borderSide: BorderSide(
                  //         color: Color.fromRGBO(46, 173, 165, 1),
                  //         width: 0.5,
                  //       ),
                  //     ),
                  //   ),
                  //   onChanged: (value) {
                  //     controller.searchQuery.value = value;
                  //   },
                  // ),
                  const SizedBox(height: 16),

                  // 📋 Expense List
                  Obx(() {
                    // Step 1: Apply search filter from controller
                    var filtered = controller.filteredExpenses;

                    // Step 2: Apply recurring filter if needed
                    if (showRecurringOnly) {
                      filtered =
                          filtered.where((e) => e.isRecurring == true).toList();
                    } else {
                      filtered = filtered
                          .where((e) => e.isRecurring == false)
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Empty(title: 'Recurring Expense', width: 70));
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final expensess = filtered[index];
                        return _buildTransactionItem(expensess);
                      },
                      separatorBuilder: (context, index) => const Divider(
                        thickness: 0.25,
                        height: 2,
                        color: Colors.grey,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildTransactionItem(Expense expense) {
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 0.25),
              ),
              child: ClipOval(
                child: Image.network(
                  expense.logo_url ?? ImagePaths.expensewallet,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/defult_logo.png'),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    // controller.formatDate(expense.date.toString()),
                    formatDateAndTime(expense.date.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${formatShortNumber(double.parse(expense.amount.toString()))}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
