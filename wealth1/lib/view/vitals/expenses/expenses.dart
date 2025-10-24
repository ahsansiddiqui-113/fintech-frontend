import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/view/vitals/expenses/expense_shimmer_effect_screen.dart';
import 'package:wealthnx/view/vitals/expenses/expense_transactions.dart';
import 'package:wealthnx/view/vitals/expenses/total_expense_breakdown/total_expense_breakdown_page.dart';
import 'package:wealthnx/view/vitals/expenses/view_all_recurring_expense.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/models/expense/expense_transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

import '../../../widgets/custom_list_item.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final controller = Get.put(ExpensesController());

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];
  final RxInt selectedTab = 0.obs;

  late Future<List<Map<String, dynamic>>> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _expenseFuture = controller.fetchExpenceSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Expense',
          onBackPressed: () {
            controller.totalExpenceAmount.value =
                controller.expense.value?.body?.totalExpense ?? 0;
            Get.back();
          },
          actions: [
            if (connectivityController.isConnected.value == false) ...[
              toggleBtnDemoReal(context)
            ],
          ]),
      body: Obx(() {
        if (controller.isLoadingExpence.value ||
            controller.expense.value == null) {
          return ExpenseShimmerEffectScreen();
        } else {
          final expense = controller.expense.value?.body;
          // final expenseRecurring = controller.expenseRecurring.value?.body;
          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.to(() => TotalExpenseBreakdownPage()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 2,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/total_expense.svg',
                                  height: 10,
                                  width: 10,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Total Expense',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            // Text(
                            //   (controller.expense.value == null)
                            //       ? '\$0.00'
                            //       : '\$${controller.totalExpenceAmount.toInt()}',
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            textWidget(context, title: () {
                              final expense = controller.expense.value == null
                                  ? 0
                                  : controller.totalExpenceAmount.value;

                              if (expense == 0) {
                                return '\$0.00';
                              } else if (expense > 0) {
                                return '\$${numberFormat.format(expense)}';
                              } else {
                                return '-\$${numberFormat.format(expense.abs())}';
                              }
                            }(), fontSize: 18, fontWeight: FontWeight.w500)
                          ],
                        ),
                        Spacer(),
                        // SizedBox(width: 24, height: 24, child: null),
                        SizedBox(
                          width: 100,
                          // flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  fit: StackFit.passthrough,
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.transparent,
                                      // backgroundImage:
                                      //     AssetImage('assets/images/exp_1.png'),
                                    ),
                                    Positioned(
                                      left: 0,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/exp_3.png'),
                                      ),
                                    ),
                                    Positioned(
                                      left: 15,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/exp_2.png'),
                                      ),
                                    ),
                                    Positioned(
                                      left: 30,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/exp_1.png'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 24,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        // Icon(Icons.arrow_forward_ios, size: 24),
                      ],
                    ),
                  ),
                ),
                addHeight(21),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      (controller.expense.value == null)
                          ? isEmptyVitals(title: 'Expense')
                          : _buildSpendGraph(),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(tabTitles.length, (index) {
                            final isSelected = selectedTab.value == index;

                            return GestureDetector(
                              onTap: () {
                                selectedTab.value = index;
                                controller.dwmyDropdown.value =
                                    tabTitles[index];
                                controller.totalExpenceAmount.value = controller
                                        .expense.value?.body?.totalExpense ??
                                    0;
                                _expenseFuture =
                                    controller.fetchExpenceSummary();
                                // _controllerExpence.updateDropdown(tabTitles[index]);
                                // _controllerExpence.fetchExpenceSummary();
                                setState(() {});
                              },
                              child: Container(
                                // margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF313131)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF313131)
                                        : Colors.transparent,
                                    width: 0.25,
                                  ),
                                ),
                                child: Text(
                                  tabTitles[index],
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w400
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),
                addHeight(21),
                Image.asset(
                  'assets/images/expense_card.png',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // suggestionCard(
                //     text: 'Better Understand you finances',
                //     subText:
                //         'Did you face difficulties while manage expense learn how Wealth Genie can help you',
                //     onTap: () {}),
                addHeight(21),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 40, 40, 40)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SectionName(
                        title: 'Recurring Expense',
                        titleOnTap: 'View All',
                        onTap: () {
                          Get.to(
                              ViewAllRecurringExpense(showRecurringOnly: true));
                        },
                      ),
                      // addHeight(21),
                      (controller.expense.value == null ||
                              controller.expense.value?.body?.expenses ==
                                  null ||
                              expense!.expenses!.isEmpty)
                          ? Container(
                              margin: EdgeInsets.only(top: 12),
                              child:
                                  Empty(title: 'Recurring Expense', width: 70))
                          : _buildRecurringExpenses(
                              expenseTrans: expense.expenses),
                    ],
                  ),
                ),
                addHeight(21),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SectionName(
                        title: 'Expense Transactions',
                        titleOnTap:
                            expense!.expenses!.isEmpty ? '' : 'View All',
                        onTap: () {
                          expense.expenses!.isEmpty
                              ? null
                              : Get.to(() => ExpenseTransactions());
                        },
                      ),
                      // addHeight(10),
                      (controller.expense.value == null)
                          ? Container(
                              margin: EdgeInsets.only(top: 16),
                              child: Empty(
                                  title: 'Expense Transactions', width: 70))
                          : _buildExpenseTransactions(
                              expenseTrans: expense.expenses),
                    ],
                  ),
                ),
                addHeight(40)
              ],
            ),
          );
        }
      }),
      // bottomNavigationBar: Obx(
      //   () => buildAddButton(
      //     title: 'Add Expense',
      //     onPressed:
      //         controller.isLoading.value || controller.expense.value == null
      //             ? null
      //             : () => () {
      //                   Get.to(() => AddExpenses());
      //                 },
      //   ),
      // ),
    );
  }

  Widget _buildSpendGraph() {
    final controller = Get.find<ExpensesController>();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _expenseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildChartShimmerEffect();
        } else if (snapshot.hasError) {
          return isEmptyVitals(title: 'Expense');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return isEmptyVitals(title: 'Expense');
        }

        final responseData = snapshot.data!;
        final chartData = responseData.toList();
        final xLabels = chartData.map((e) => e['monthName'] as String).toList();

        final List<FlSpot> spots = List.generate(chartData.length, (index) {
          final total = (chartData[index]['total'] as num).toDouble();
          return FlSpot(index.toDouble(), total);
        });

        final totalSum = responseData.fold<double>(
          0,
          (sum, item) => sum + (item['total'] as num).abs().toDouble(),
        );

        print('Total Sum: $xLabels');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: totalSum == 0.0 ? 239 : 239,
              child: totalSum == 0.0
                  ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                  : ExpenseChart(
                      spots: spots,
                      xLabels: xLabels,
                      timePeriod: controller.dwmyDropdown.value,
                      val: controller.totalExpenceAmount,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecurringExpenses({List<Expense>? expenseTrans}) {
    final nonRecurringExpenses = expenseTrans
            ?.where((expense) => expense.isRecurring != false)
            .take(4)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (controller.isLoading.value)
          buildlistShimmerEffect()
        else if (nonRecurringExpenses.isEmpty)
          Empty(title: 'Recurring Expense', width: 70)
        else
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nonRecurringExpenses.length > 4
                ? 4
                : nonRecurringExpenses.length,
            itemBuilder: (context, index) {
              final expense = nonRecurringExpenses[index];
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
                  subtitle: formatDateAndTime(expense.date.toString()),
                  persentage: '',
                  logo: expense.logo_url ?? ImagePaths.dfexpense,
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 0.25,
              height: 2,
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseTransactions({List<Expense>? expenseTrans}) {
    // Filter out recurring expenses and limit to 4 items
    final nonRecurringExpenses = expenseTrans
            ?.where((expense) => expense.isRecurring != true)
            .take(4)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (controller.isLoading.value)
          buildlistShimmerEffect()
        else if (nonRecurringExpenses.isEmpty)
          Empty(title: 'Expense Transactions', width: 70)
        else
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nonRecurringExpenses.length,
            itemBuilder: (context, index) {
              final expense = nonRecurringExpenses[index];
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
                  subtitle: formatDateAndTime(expense.date.toString()),
                  persentage: '',
                  logo: expense.logo_url ?? ImagePaths.dfexpense,
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 0.25,
              height: 2,
            ),
          ),
      ],
    );
  }
}
