import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/transations/transations_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/models/transations/transations_model.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class TransactionsPage extends StatelessWidget {
  TransactionsPage({super.key});

  final TransactionsController _controller = Get.find<TransactionsController>();

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Transactions', actions: [
        if (connectivityController.isConnected.value == false) ...[
          toggleBtnDemoReal(context)
        ],
      ]),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: marginSide()),
        child: Column(
          children: [
            // Search bar
            Container(
              // height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller.searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search',
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
                onChanged: (value) => _controller.filterTransactions(),
              ),
            ),
            addHeight(16),
            Expanded(
              child: Obx(() {
                if (_controller.isLoadingTran.value) {
                  return _controller.buildShimmerEffect();
                } else if (_controller.filteredTransactions.isEmpty) {
                  return Empty(
                    title: 'Transactions',
                    width: 140,
                  );
                } else {
                  final groupedTransactions = _controller.groupedTransactions;

                  print("Total Length: ${groupedTransactions.length}");
                  return ListView.builder(
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, groupIndex) {
                      String dateLabel =
                          groupedTransactions.keys.elementAt(groupIndex);
                      List<TransBody> dateTransactions =
                          groupedTransactions[dateLabel]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          //   child: Text(
                          //     dateLabel,
                          //     style: TextStyle(
                          //       color: Colors.grey,
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.w400,
                          //     ),
                          //   ),
                          // ),

                          // Transactions under this date
                          ...dateTransactions.map((txn) => GestureDetector(
                                onTap: () {
                                  Get.to(() => TransationReceipt(
                                        id: txn.id,
                                        name: txn.title,
                                        amount: txn.amount.toString(),
                                        date: txn.date.toString(),
                                        category: txn.category,
                                      ));
                                },
                                child: buildIncomeDetailItem(
                                  context,
                                  index: groupIndex,
                                  title: '${txn.title}',
                                  amount: (txn.amount == null)
                                      ? '\$0.00'
                                      : (txn.amount!.toInt() < 0
                                          ? '-\$${numberFormat.format(txn.amount!.toInt().abs())}'
                                          : '\$${numberFormat.format(txn.amount!.toInt())}'),
                                  // amount: '\$${txn.amount?.toInt()}',
                                  length: groupedTransactions.length,
                                  subtitle:
                                      formatDateAndTime(txn.date.toString()),
                                  persentage: '',
                                  icon: txn.logoUrl ?? ImagePaths.expensewallet,
                                  logo: txn.logoUrl ?? ImagePaths.dfaccount,
                                ),
                              )),
                        ],
                      );
                    },
                  );
                }
              }),
            ),
            addHeight(40)
          ],
        ),
      ),
    );
  }
}
