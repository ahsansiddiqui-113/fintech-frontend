import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';

import 'package:wealthnx/view/vitals/income/income_shimmer.dart';
import 'package:wealthnx/view/vitals/income/view_all_icome.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class IncomeScreen extends StatefulWidget {
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final IncomeController controller = Get.put(IncomeController());

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];

  final RxInt selectedTab = 0.obs;

  late Future<List<Map<String, dynamic>>> _incomeFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _incomeFuture = controller.fetchIncomeSummary();
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchIncome();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Income',
          onBackPressed: () {
            controller.totalIncomeAmount.value =
                controller.income.value?.body?.totalIncomeAmount ?? 0;
            Get.back();
          },
          actions: [
            if (connectivityController.isConnected.value == false) ...[
              toggleBtnDemoReal(context)
            ],
          ]),
      body: Obx(() {
        if (controller.isLoading.value || (controller.income.value == null)) {
          // return const Center(
          //     child: CircularProgressIndicator(
          //   color: Colors.white,
          // ));
          return IncomeShimmer();
        } else {
          final income = controller.income.value?.body;
          final incomeLength = ((income?.incomes?.length ?? 0) > 4)
              ? income?.incomes?.sublist(0, 4).length
              : income?.incomes?.length;

          print('Income Length: ${controller.income.value?.body?.incomes}');

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Income Section
                const Text(
                  'Total Income',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                // const SizedBox(height: 8),
                Obx(
                    // () => Text(
                    //   (controller.income.value == null)
                    //       ? '\$0.0'
                    //       : '\$${controller.totalIncomeAmount.toInt() ?? '0.0'}',
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    () => textWidget(context, title: () {
                          final income = controller.income.value == null
                              ? 0
                              : controller.totalIncomeAmount.value;

                          if (income == 0) {
                            return '\$0.00';
                          } else if (income > 0) {
                            return '\$${numberFormat.format(income)}';
                          } else {
                            return '-\$${numberFormat.format(income.abs())}';
                          }
                        }(), fontSize: 28, fontWeight: FontWeight.w500)),

                // Income Statistics Graph
                addHeight(24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      (controller.income.value == null)
                          ? (controller.isLoading.value)
                              ? isEmptyVitals(title: 'Income Stats')
                              : buildChartShimmerEffect()
                          : buildSpendGraph(),
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
                                controller.totalIncomeAmount.value = controller
                                        .income
                                        .value
                                        ?.body
                                        ?.totalIncomeAmount ??
                                    0;
                                _incomeFuture = controller.fetchIncomeSummary();
                              },
                              child: Container(
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
                const SizedBox(height: 24),
                // Income Details
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
                        title: 'Income Transactions',
                        titleOnTap: incomeLength == 0 ? '' : 'View All',
                        onTap: () {
                          incomeLength == 0
                              ? null
                              : Get.to(() =>
                                  ViewAllIncome(title: 'Income Transactions'));
                        },
                      ),
                      addHeight(21),
                      if (incomeLength == 0 ||
                          controller.income.value == null) ...[
                        Container(
                            margin: EdgeInsets.only(top: 12),
                            child:
                                Empty(title: 'Income Transactions', width: 70))
                      ] else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: incomeLength,
                          itemBuilder: (context, index) {
                            final incomeasset = income?.incomes?[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => TransationReceipt(
                                      id: incomeasset.id,
                                      name: incomeasset.name,
                                      amount: incomeasset.amount.toString(),
                                      date: incomeasset.createdAt.toString(),
                                      category: incomeasset.type,
                                    ));
                              },
                              child: buildIncomeDetailItem(
                                context,
                                index: index,
                                listtype: 'Income',
                                title: '${incomeasset?.name}',
                                amount: '\$${incomeasset?.amount?.toInt()}',
                                length: incomeLength,
                                subtitle: formatDateAndTime(
                                    incomeasset!.createdAt.toString()),
                                persentage: '',
                                icon: incomeasset.logo ??
                                    ImagePaths.expensewallet,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                // addHeight(40),
              ],
            ),
          );
        }
      }),
      // bottomNavigationBar: buildAddButton(
      //   title: 'Add Income',
      //   onPressed: () {
      //     Get.to(() => IncomeAddedScreen());
      //   },
      // ),
    );
  }

  Widget buildSpendGraph() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _incomeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildChartShimmerEffect();
        } else if (snapshot.hasError) {
          return isEmptyVitals(title: 'Income Stats');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return isEmptyVitals(title: 'Income Stats');
        }

        final responseData = snapshot.data!;
        final chartData = responseData.reversed.toList();
        final xLabels = chartData.map((e) => e['monthName'] as String).toList();

        final List<FlSpot> spots = List.generate(chartData.length, (index) {
          final total = (chartData[index]['total'] as num).toDouble();
          return FlSpot(index.toDouble(),
              total.abs()); // Using abs() since totals are negative
        });

        final totalSum = responseData.fold<double>(
          0,
          (sum, item) => sum + (item['total'] as num).abs().toDouble(),
        );

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: (totalSum == 0.0) ? 150 : 200,
                child: (totalSum == 0.0)
                    ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                    : ExpenseChart(
                        spots: spots,
                        xLabels: xLabels,
                        timePeriod: controller.dwmyDropdown.value,
                        val: controller.totalIncomeAmount,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
