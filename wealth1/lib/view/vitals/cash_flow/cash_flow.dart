import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/view/vitals/cash_flow/cashflow_shimmer.dart';
import 'package:wealthnx/view/vitals/cash_flow/cashflow_view_all.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';

import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class CashFlowScreen extends StatefulWidget {
  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  final CashFlowController controller = Get.find<CashFlowController>();

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];
  final RxInt selectedTab = 0.obs;
  late Future<List<Map<String, dynamic>>> _cashFlowFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchCashFlowDetails();
    _cashFlowFuture = controller.fetchCashflowSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Cash Flow',
          onBackPressed: () {
            controller.totalCashFlowAmount.value =
                controller.cashflow.value?.body?.cashflow ?? 0;
            Get.back();
          },
          actions: [
            if (connectivityController.isConnected.value == false) ...[
              toggleBtnDemoReal(context)
            ],
          ]),
      body: Obx(() {
        if (controller.isLoading.value) {
          // return const Center(child: CircularProgressIndicator());
          return CashFlowShimmer();
        } else if (controller.cashflow.value == null) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Cash Flow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$0.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 16,
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(ImagePaths.tt),
                      fit: BoxFit.contain,
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNetWorthItem(
                            context,
                            'Cash In',
                            ' Increased Recently',
                            '${0.0}%',
                            '\$${0.0}',
                            'assets/images/cashIn.png',
                            Icons.arrow_upward,
                            Colors.green),
                        _buildNetWorthItem(
                            context,
                            'Cash Out',
                            ' decreased Recently',
                            '${0.0.toStringAsFixed(2)}%',
                            '\$${0.0}',
                            'assets/images/cashOut.png',
                            Icons.arrow_downward,
                            Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // buildCashFlowChart(context),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        controller.cashflow.value == null
                            ? isEmptyVitals(title: 'Cash Flow')
                            : _buildSpendGraph(),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // spacing: 22,
                          children: List.generate(tabTitles.length, (index) {
                            final isSelected = selectedTab.value == index;

                            return GestureDetector(
                              onTap: () {
                                selectedTab.value = index;
                                print('Index aa: $index');
                                controller.dwmyDropdown.value =
                                    tabTitles[index];
                                controller.totalCashFlowAmount.value =
                                    controller.cashflow.value?.body?.cashflow ??
                                        0;
                                _cashFlowFuture =
                                    controller.fetchCashflowSummary();
                                // controller.fetchCashflowSummary();
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
                      ],
                    ),
                  ),
                  // controller.cashflow.value == null
                  //     ? isEmptyVitals(title: 'Cash Flow')
                  //     : _buildSpendGraph(),
                  const SizedBox(height: 24),

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
                          title: '${DateFormat('MMMM').format(DateTime.now())}',
                          titleOnTap: '2025',
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Income',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "${0.toStringAsFixed(0)}% Increase",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${0}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            Divider(thickness: 0.5, height: 2),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Expense',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "${0.toStringAsFixed(0)}% Decrease",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${0}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SectionName(
                    title: 'Income',
                    titleOnTap: '',
                    onTap: () {},
                  ),
                  Empty(
                    title: 'Income',
                    width: 70,
                  ),
                  // const SizedBox(height: 12),
                  SectionName(
                    title: 'Expense',
                    titleOnTap: '',
                    onTap: () {},
                  ),
                  Empty(
                    title: 'Expense',
                    width: 70,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        } else {
          final cashflow = controller.cashflow.value?.body;

          final incomelength = ((cashflow?.incomeBreakdown?.length ?? 0) > 4)
              ? cashflow?.incomeBreakdown?.sublist(0, 4).length
              : cashflow?.incomeBreakdown?.length;

          final expenselength = ((cashflow?.expenseBreakdown?.length ?? 0) > 4)
              ? cashflow?.expenseBreakdown?.sublist(0, 4).length
              : cashflow?.expenseBreakdown?.length;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Cash Flow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Row(
                    children: [
                      // Text(
                      //   controller.cashflow.value == null
                      //       ? '\$0.0'
                      //       : '\$${controller.totalCashFlowAmount.value.abs().toInt()}',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      textWidget(context, title: () {
                        final cashFlow = controller.cashflow.value == null
                            ? 0
                            : controller.totalCashFlowAmount.value;

                        if (cashFlow == 0) {
                          return '\$0.00';
                        } else if (cashFlow > 0) {
                          return '\$${numberFormat.format(cashFlow)}';
                        } else {
                          return '-\$${numberFormat.format(cashFlow.abs())}';
                        }
                      }(),
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)
                      // SizedBox(width: 5),
                      // Icon(
                      //   ((cashflow?.netCashFlow?.toInt() ?? 0) >= 0)
                      //       ? Icons.arrow_upward
                      //       : Icons.arrow_downward,
                      //   color: ((cashflow?.netCashFlow?.toInt() ?? 0) >= 0)
                      //       ? Colors.green
                      //       : Colors.red,
                      //   size: 16,
                      // )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(ImagePaths.tt),
                      fit: BoxFit.contain,
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          // padding: EdgeInsets.only(left: 20),
                          child: _buildNetWorthItem(
                              context,
                              'Cash In',
                              ' Increased Recently',
                              '${controller.cashflow.value == null ? 0 : cashflow?.incomeChangePercent!.toInt()}%',
                              '\$${controller.cashflow.value == null ? 0 : cashflow?.totalIncome?.toInt()}',
                              'assets/images/cashIn.png',
                              Icons.arrow_upward,
                              Colors.green),
                        ),
                        _buildNetWorthItem(
                            context,
                            'Cash Out',
                            ' decreased Recently',
                            '${(controller.cashflow.value == null ? 0 : cashflow?.expenseChangePercent)?.toInt()}%',
                            '\$${controller.cashflow.value == null ? 0 : cashflow?.totalExpenses?.toInt()}',
                            'assets/images/cashOut.png',
                            Icons.arrow_downward,
                            Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // buildCashFlowChart(context),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        controller.cashflow.value == null
                            ? isEmptyVitals(title: 'Cash Flow')
                            : _buildSpendGraph(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // spacing: 22,
                            children: List.generate(tabTitles.length, (index) {
                              final isSelected = selectedTab.value == index;

                              return GestureDetector(
                                onTap: () {
                                  selectedTab.value = index;
                                  controller.dwmyDropdown.value =
                                      tabTitles[index];
                                  controller.totalCashFlowAmount.value =
                                      controller
                                              .cashflow.value?.body?.cashflow ??
                                          0;
                                  _cashFlowFuture =
                                      controller.fetchCashflowSummary();
                                  // controller.fetchCashflowSummary();
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
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          title: '${DateFormat('MMMM').format(DateTime.now())}',
                          titleOnTap: '2025',
                          onTap: () {},
                        ),
                        addHeight(21),
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Income',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "${controller.cashflow.value == null ? 0.0 : cashflow?.incomeChangePercent?.toStringAsFixed(0)}% Increase",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${controller.cashflow.value == null ? 0.0 : cashflow?.totalIncome?.toInt()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            Divider(thickness: 0.5, height: 2),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Expense',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "${controller.cashflow.value == null ? 0.0 : cashflow?.expenseChangePercent?.toStringAsFixed(0)}% Decrease",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${controller.cashflow.value == null ? 0.0 : cashflow?.totalExpenses?.toInt()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SectionName(
                          title: 'Income',
                          titleOnTap: (cashflow?.incomeBreakdown?.length) == 0
                              ? ''
                              : 'View All',
                          onTap: () {
                            (cashflow?.incomeBreakdown?.length) == 0
                                ? null
                                : Get.to(
                                    () => CashflowViewAll(title: 'Income'));
                          },
                        ),
                        addHeight(21),
                        controller.cashflow.value == null
                            ? Empty(
                                title: 'Income',
                                width: 70,
                              )
                            : (cashflow?.incomeBreakdown?.length) == 0
                                ? Empty(
                                    title: 'Income',
                                    width: 70,
                                  )
                                : Container(
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: incomelength,
                                        itemBuilder: (context, index) {
                                          final cashFlow =
                                              cashflow?.incomeBreakdown?[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Get.to(() => TransationReceipt(
                                                  id: cashFlow.id,
                                                  name: cashFlow.name,
                                                  amount: cashFlow.amount
                                                      .toString(),
                                                  date: cashFlow.createdAt
                                                      .toString(),
                                                  category: cashFlow.category));
                                            },
                                            child: buildIncomeDetailItem(
                                                context,
                                                index: index,
                                                listtype: 'Income',
                                                title: '${cashFlow?.name}',
                                                amount: '\$${cashFlow?.amount}',
                                                length: incomelength,
                                                subtitle: formatDateAndTime(
                                                    cashFlow!.createdAt
                                                        .toString()),
                                                persentage: '',
                                                icon: cashFlow.logo ??
                                                    ImagePaths.expensewallet),
                                          );
                                        }),
                                  ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          title: 'Expense',
                          titleOnTap: cashflow!.expenseBreakdown!.isEmpty
                              ? ''
                              : 'View All',
                          onTap: () {
                            (cashflow.expenseBreakdown!.isEmpty)
                                ? null
                                : Get.to(
                                    () => CashflowViewAll(title: 'Expense'));
                          },
                        ),
                        addHeight(21),
                        controller.cashflow.value == null
                            ? Empty(
                                title: 'Expense',
                                width: 70,
                              )
                            : (cashflow.expenseBreakdown!.isEmpty)
                                ? Empty(
                                    title: 'Expense',
                                    width: 70,
                                  )
                                : Container(
                                    margin: EdgeInsets.symmetric(vertical: 0),
                                    height: (65 * expenselength!.toDouble()),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: expenselength,
                                        itemBuilder: (context, index) {
                                          final cashFlow =
                                              cashflow.expenseBreakdown?[index];

                                          return GestureDetector(
                                            onTap: () {
                                              Get.to(() => TransationReceipt(
                                                  id: cashFlow.id,
                                                  name: cashFlow.name,
                                                  amount: cashFlow.amount
                                                      .toString(),
                                                  date: cashFlow.createdAt
                                                      .toString(),
                                                  category: cashFlow.category));
                                            },
                                            child: buildIncomeDetailItem(
                                                context,
                                                index: index,
                                                listtype: 'Expense',
                                                title: '${cashFlow?.name}',
                                                amount: '\$${cashFlow?.amount}',
                                                length: expenselength,
                                                subtitle: formatDateAndTime(
                                                    cashFlow!.createdAt
                                                        .toString()),
                                                persentage: '',
                                                icon: cashFlow.logo ??
                                                    ImagePaths.expensewallet),
                                          );
                                        }),
                                  ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildSpendGraph() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _cashFlowFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildChartShimmerEffect();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final responseData = snapshot.data!;
        final chartData = responseData.toList();
        final xLabels = chartData.map((e) => e['monthName'] as String).toList();

        final List<FlSpot> spots = List.generate(chartData.length, (index) {
          final total = (chartData[index]['total'] as num).toDouble();
          return FlSpot(
              index.toDouble(), total); // Using abs() since totals are negative
        });

        final totalSum = responseData.fold<double>(
          0,
          (sum, item) => sum + (item['total'] as num).abs().toDouble(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: (totalSum == 0.0) ? 80 : 30,
            ),
            Container(
              height: (totalSum == 0.0) ? 150 : 200,
              child: (totalSum == 0.0)
                  ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                  : ExpenseChart(
                      spots: spots,
                      xLabels: xLabels,
                      timePeriod: controller.dwmyDropdown.value,
                      val: controller.totalCashFlowAmount,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCashFlowChart(BuildContext context) {
    final responseData = [
      {"monthName": "Apr", "total": 0},
      {"monthName": "Mar", "total": 0},
      {"monthName": "Feb", "total": 0},
      {"monthName": "Jan", "total": 0},
      {"monthName": "Dec", "total": 0},
      {"monthName": "Nov", "total": 0},
    ];

    final chartData = responseData.reversed.toList();
    final xLabels = chartData.map((e) => e['monthName'] as String).toList();
    final List<FlSpot> spots = List.generate(chartData.length, (index) {
      final total = (chartData[index]['total'] as num).toDouble();
      return FlSpot(index.toDouble(), total);
    });

    final totalSum = responseData.fold<double>(
      0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 40, 40, 40)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Cash Flow',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              Obx(() => PopupMenuButton<String>(
                    offset: const Offset(0, 30),
                    color: Colors.black,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.dwmyDropdown.value,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      'Daily',
                      'Weekly',
                      'Monthly',
                      'Yearly',
                    ].map((String option) {
                      return PopupMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    }).toList(),
                    onSelected: (value) {
                      controller.updateDropdown(value);
                    },
                  )),
            ],
          ),
          SizedBox(height: (totalSum == 0.0) ? 80 : 30),
          Container(
            height: (totalSum == 0.0) ? 150 : 200,
            child: (totalSum == 0.0)
                ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                : ExpenseChart(
                    spots: spots,
                    xLabels: xLabels,
                    timePeriod: controller.dwmyDropdown.value,
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNetWorthItem(
    BuildContext context,
    String title,
    String belowtext,
    String perbelowtext,
    String value,
    String icon,
    IconData image,
    Color color) {
  return Container(
    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icon(icon, color: Colors.white, size: 16),
            Image.asset(
              icon,
              width: 15,
              height: 15,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${perbelowtext}',
                      style: TextStyle(
                          color: title == 'Cash In'
                              ? context.gc(AppColor.greenColor)
                              : context.gc(AppColor.redColor),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                    Text(
                      '$belowtext',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.only(bottom: 20, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: color,
              ),
              child: Icon(
                image,
                color: Colors.black,
                size: 14,
              ),
            ),
          ],
        )
      ],
    ),
  );
}
