import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/networth/net_worth_new_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/view/chats/line_chart.dart';
import 'package:wealthnx/view/vitals/networth/networth_breakdown/networth_breakdown.dart';
import 'package:wealthnx/view/vitals/networth/networth_shimmer_effect.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

import 'networth_assets_all_sscreen.dart';
import 'networth_libilites_all_sscreen.dart';

class NetWorth extends StatefulWidget {
  NetWorth({super.key});

  @override
  State<NetWorth> createState() => _NetWorthState();
}

class _NetWorthState extends State<NetWorth> {
  final NetWorthController _controller = Get.find<NetWorthController>();

  final graphController = Get.put(NetWorthNewController());

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];

  final RxInt selectedTab = 0.obs;
  late Future<List<Map<String, dynamic>>> _netWorthFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _netWorthFuture = _controller.fetchNetworthChartSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Net Worth',
          onBackPressed: () {
            _controller.totalSpend.value =
                _controller.networth.value?.body?.totalNetWorth ?? 0;
            Get.back();
          },
          actions: [
            if (connectivityController.isConnected.value == false) ...[
              toggleBtnDemoReal(context)
            ],
          ]),
      body: Obx(() {
        if (_controller.isLoading.value) {
          // return const Center(
          //     child: CircularProgressIndicator(color: Colors.white));
          return NetworthShimmerEffect();
        } else if (_controller.networth.value == null) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Net Worth Section
                  const Text(
                    'Total Net Worth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${0.0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${0.0} (30days)',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 15),

                  addHeight(24),

                  // Net Worth Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        isEmptyVitals(title: 'Networth'),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(tabTitles.length, (index) {
                            final isSelected = selectedTab.value == index;

                            return GestureDetector(
                              onTap: () {
                                selectedTab.value = index;
                                Get.put(NetWorthController())
                                    .dwmyDropdown
                                    .value = tabTitles[index];
                                print(
                                    "selectedTab.value: ${selectedTab.value}");
                                _controller.totalSpend.value = _controller
                                        .networth.value?.body?.totalNetWorth ??
                                    0;
                                _netWorthFuture =
                                    _controller.fetchNetworthChartSummary();
                                // _controller.fetchNetworthChartSummary();
                                setState(() {});
                                // _controllerExpence.updateDropdown(tabTitles[index]);
                                // _controllerExpence.fetchExpenceSummary();
                                // setState(() {});
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

                  addHeight(24),

                  // Bar Chart
                  Container(
                    height: 200,
                    child: DoubleExpenseBarChart(
                      data: [
                        DoubleExpenseBarGraph(
                            month: "Dec 2024", firstValue: 10, secondValue: 10),
                        DoubleExpenseBarGraph(
                            month: "Jan 2025", firstValue: 10, secondValue: 10),
                        DoubleExpenseBarGraph(
                            month: "Feb 2025", firstValue: 10, secondValue: 10),
                        DoubleExpenseBarGraph(
                            month: "Mar 2025", firstValue: 10, secondValue: 10),
                        DoubleExpenseBarGraph(
                            month: "Apr 2025", firstValue: 10, secondValue: 10),
                        DoubleExpenseBarGraph(
                            month: "May 2025", firstValue: 10, secondValue: 10),
                        // ... more months
                      ],
                      firstBarColor: Color(0xFF2BDFD2),
                      secondBarColor: Color(0xFF1D9A91),
                    ),
                  ),
                  addHeight(),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Assets   ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2BDFD2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Liabilities   ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D9A91),
                                borderRadius: BorderRadius.circular(2),
                              )),
                        ],
                      ),
                      Container()
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Liabilities Section
                  SectionName(
                    title: 'Libilities',
                    titleOnTap: '',
                  ),
                  Empty(
                    title: 'Libilities',
                    width: 70,
                  ),
                  addHeight(24),
                  SectionName(
                    title: 'Assets',
                    titleOnTap: '',
                  ),
                  Empty(
                    title: ' Assets',
                    width: 70,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        } else {
          final networth = _controller.networth.value?.body;

          return SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => NetworthBreakdown(
                          totalBudget: (_controller.networth.value?.body
                                          ?.totalNetWorth ??
                                      0.0) >=
                                  0
                              ? '\$${_controller.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : _controller.networth.value?.body?.totalNetWorth?.toInt()}'
                              : '-\$${_controller.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : _controller.networth.value?.body?.totalNetWorth?.abs().toDouble().toStringAsFixed(2)}',
                        )),
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
                              const Text(
                                'Net Worth',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              // Text(
                              //   (_controller.totalSpend.value ?? 0.0) >= 0
                              //       ? '\$${_controller.totalSpend.value.toInt() == 0.0 ? '0.00' : _controller.totalSpend.value.toInt()}'
                              //       : '-\$${_controller.totalSpend.value.toInt() == 0.0 ? '0.00' : _controller.totalSpend.value.abs().toDouble().toStringAsFixed(2)}',
                              //   style: const TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              textWidget(context, title: () {
                                final netWorth =
                                    _controller.totalSpend.value ?? 0;

                                if (netWorth == 0) {
                                  return '\$0.00';
                                } else if (netWorth > 0) {
                                  return '\$${numberFormat.format(netWorth)}';
                                } else {
                                  return '-\$${numberFormat.format(netWorth.abs())}';
                                }
                              }(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)
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
                                        left: -10,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              'assets/images/exp3.png'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              'assets/images/exp2.png'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 30,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              'assets/images/exp1.png'),
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

                  // Net Worth Chart

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSpendGraph(),
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
                                  selectedTab.value = index;
                                  Get.put(NetWorthController())
                                      .dwmyDropdown
                                      .value = tabTitles[index];
                                  // _controller.fetchNetworthChartSummary();
                                  _controller.totalSpend.value = _controller
                                          .networth
                                          .value
                                          ?.body
                                          ?.totalNetWorth ??
                                      0;
                                  _netWorthFuture =
                                      _controller.fetchNetworthChartSummary();
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
                        )
                      ],
                    ),
                  ),
                  addHeight(21),
                  // Chart
                  Obx(
                    () => graphController.isLoading.value
                        ? buildChartShimmerEffect()
                        : graphController.errorMessage.isNotEmpty
                            ? Center(
                                child: Text(graphController.errorMessage.value,
                                    style: TextStyle(color: Colors.red)))
                            : SizedBox(
                                height: 255,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 40, 40, 40)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: DoubleExpenseBarChart(
                                          data: graphController.netWorthList
                                              .map((item) =>
                                                  DoubleExpenseBarGraph(
                                                    month: item.monthName,
                                                    firstValue:
                                                        item.asset.abs(),
                                                    secondValue:
                                                        item.liabilities.abs(),
                                                  ))
                                              .toList(),
                                          firstBarColor:
                                              context.gc(AppColor.primary),
                                          secondBarColor:
                                              context.gc(AppColor.darkPrimary),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16, bottom: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'Assets   ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .gc(AppColor.primary),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            addHeight(24),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Liabilities   ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: context.gc(
                                                          AppColor.darkPrimary),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    )),
                                              ],
                                            ),
                                            Container()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),

                  addHeight(21),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: const Color(0xFF1C1C1C),
                      border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40),
                      ),
                    ),
                    child: Column(
                      children: [
                        SectionName(
                          title: 'Assets',
                          titleOnTap:
                              (networth?.assets?.length) == 0 ? '' : 'View All',
                          onTap: () {
                            Get.to(() => ViewAllNetWorth());
                          },
                        ),
                        addHeight(16),
                        (networth?.assets?.length == 0)
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Empty(
                                  title: 'Assets',
                                  width: 70,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: ((networth?.assets?.length ?? 0) > 3)
                                    ? 3
                                    : networth?.assets?.length,
                                itemBuilder: (context, index) {
                                  final networthlib = networth?.assets?[index];

                                  return buildIncomeDetailItem(
                                    context,
                                    listtype: 'Assets',
                                    index: index,
                                    title: networthlib?.name.toString(),
                                    amount:
                                        '\$${networthlib?.amount?.toStringAsFixed(2)}',
                                    length:
                                        ((networth?.assets?.length ?? 0) > 3)
                                            ? 3
                                            : networth?.assets?.length,
                                    subtitle:
                                        '...${networthlib?.accountNumber?.substring(0, 3)} ${networthlib?.bankName}',
                                    persentage: '',
                                    icon: AppEndpoints.profileBaseUrl +
                                            (networthlib?.bankLogo ??
                                                ImagePaths.dfasstes) ??
                                        ImagePaths.dfasstes,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  addHeight(21),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: const Color(0xFF1C1C1C),
                      border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40),
                      ),
                    ),
                    child: Column(
                      children: [
                        SectionName(
                          title: 'Libilities',
                          titleOnTap: (networth?.liabilities?.length) == 0
                              ? ''
                              : 'View All',
                          onTap: () {
                            Get.to(NetworthLibilitesAllSscreen());
                          },
                        ),
                        addHeight(16),
                        (networth?.liabilities?.length == 0)
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Empty(
                                  title: 'Libilities',
                                  width: 70,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount:
                                    ((networth?.liabilities?.length ?? 0) > 3)
                                        ? 3
                                        : networth?.liabilities?.length,
                                itemBuilder: (context, index) {
                                  final networthlib =
                                      networth?.liabilities?[index];

                                  return buildIncomeDetailItem(
                                    context,
                                    index: index,
                                    listtype: 'Libilities',
                                    title: networthlib?.type.toString(),
                                    amount:
                                        '\$${networthlib?.amount?.toStringAsFixed(2)}',
                                    length:
                                        ((networth?.liabilities?.length ?? 0) >
                                                3)
                                            ? 3
                                            : networth?.liabilities?.length,
                                    subtitle:
                                        '...${networthlib?.accountNumber?.substring(0, 3)} ${networthlib?.bankName}',
                                    persentage: '',
                                    icon: AppEndpoints.profileBaseUrl +
                                            (networthlib?.bankLogo ??
                                                ImagePaths.expensewallet) ??
                                        ImagePaths.expensewallet,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
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
      future: _netWorthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildChartShimmerEffect();
        } else if (snapshot.hasError) {
          return isEmptyVitals(title: 'Total Spend');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return isEmptyVitals(title: 'Total Spend');
        }

        final responseData = snapshot.data!;
        final chartData = responseData.toList();
        final xLabels = chartData.map((e) => e['monthName'] as String).toList();

        // Create FlSpot list without abs() to preserve negative values
        final List<FlSpot> spots = List.generate(chartData.length, (index) {
          final total = (chartData[index]['total'] as num).toDouble();
          return FlSpot(index.toDouble(),
              total); // Removed abs() to allow negative values
        });

        // Calculate total sum for checking if data is meaningful
        final totalSum = responseData.fold<double>(
          0,
          (sum, item) =>
              sum + (item['total'] as num).toDouble(), // Use raw values for sum
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: (totalSum == 0.0 && spots.isEmpty) ? 150 : 200,
              child: spots.isEmpty
                  ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                  : ExpenseChart(
                      spots: spots,
                      xLabels: xLabels,
                      timePeriod: _controller.dwmyDropdown.value,
                      val: _controller.totalSpend,
                    ),
            ),
          ],
        );
      },
    );
  }
}
