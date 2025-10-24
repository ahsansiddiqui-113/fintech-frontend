import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

import '../../../utils/app_helper.dart';

class CashflowViewAll extends StatelessWidget {
  CashflowViewAll({super.key, this.title});
  String? title;

  final CashFlowController controller = Get.find<CashFlowController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: title.toString()),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else if (controller.cashflow.value == null) {
          return const Center(child: Text('Failed to load Cashflow'));
        }

        final cashflow = controller.filteredincomeTransactions;
        final cashflowexpense = controller.filteredexpenceTransactions;

        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                (title == 'Income')
                    ? Column(
                        children: [
                          // Search bar
                          Container(
                            // height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                                controller: controller.searchincomeController,
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
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color.fromRGBO(46, 173, 165, 1)),
                                  ),
                                  prefixIcon: IconButton(
                                    icon:
                                        Icon(Icons.search, color: Colors.grey),
                                    onPressed: () {},
                                  ),
                                ),
                                onChanged: (value) {
                                  controller.filterIncomeTransactions();
                                }),
                          ),
                          addHeight(16),
                          SizedBox(
                            height: 80 * (cashflow.length ?? 0).toDouble(),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cashflow.length,
                              itemBuilder: (context, index) {
                                final cashFlow = cashflow[index];

                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => TransationReceipt(
                                        id: cashFlow.id,
                                        name: cashFlow.name,
                                        amount: cashFlow.amount.toString(),
                                        date: cashFlow.createdAt.toString(),
                                        category: cashFlow.category));
                                  },
                                  child: buildIncomeDetailItem(context,
                                      index: index,
                                      listtype: 'Income',
                                      title: '${cashFlow.name}',
                                      amount: '\$${cashFlow.amount}',
                                      length: cashflow.length,
                                      subtitle: formatDateAndTime(
                                          cashFlow.createdAt.toString()),
                                      persentage: '',
                                      icon: cashFlow.logo ??
                                          ImagePaths.expensewallet),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            // height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                                controller: controller.searchexpenseController,
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
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color.fromRGBO(46, 173, 165, 1)),
                                  ),
                                  prefixIcon: IconButton(
                                    icon:
                                        Icon(Icons.search, color: Colors.grey),
                                    onPressed: () {},
                                  ),
                                ),
                                onChanged: (value) {
                                  controller.filterExpenceTransactions();
                                }),
                          ),
                          addHeight(16),
                          SizedBox(
                            height:
                                80 * (cashflowexpense.length ?? 0).toDouble(),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cashflowexpense.length,
                              itemBuilder: (context, index) {
                                final cashFlow = cashflowexpense[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => TransationReceipt(
                                        id: cashFlow.id,
                                        name: cashFlow.name,
                                        amount: cashFlow.amount.toString(),
                                        date: cashFlow.createdAt.toString(),
                                        category: cashFlow.category));
                                  },
                                  child: buildIncomeDetailItem(context,
                                      index: index,
                                      listtype: 'Expense',
                                      title: '${cashFlow.name}',
                                      amount: '\$${cashFlow.amount}',
                                      length: cashflowexpense.length,
                                      subtitle: formatDateAndTime(
                                          cashFlow.createdAt.toString()),
                                      persentage: '',
                                      icon: cashFlow.logo ??
                                          ImagePaths.expensewallet),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
