import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/controller/investment/investment_controller.dart';
import 'package:wealthnx/controller/investment/overview/overview_controller.dart';
import 'package:wealthnx/services/crypto_news_services.dart';
import 'package:wealthnx/view/vitals/accounts/accounts_page.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/coins_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stocks/stock_coin_today_list/stock_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/widgets/my_portfolio.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/widgets/empty.dart';

class StocksTab extends StatefulWidget {
  const StocksTab({super.key});

  @override
  State<StocksTab> createState() => _StocksTabState();
}

class _StocksTabState extends State<StocksTab> {
  final connectivityController = Get.find<CheckPlaidConnectionController>();
  final InvestmentController _investmentController =
      Get.find<InvestmentController>();
  final OverviewController _overviewController = Get.find<OverviewController>();

  // final PressReleaseNewsController _pressNewsController =
  //     Get.put(PressReleaseNewsController());
  final PressReleaseNewsController _pressNewsController =
      Get.put(PressReleaseNewsController(newsType: "Stock"), tag: "news_stock");

  @override
  void initState() {
    super.initState();
    _pressNewsController.fetchPaginatedNews(isFirstLoad: true);
    _overviewController.fetchStockSummary();
    _overviewController.selectedTab.value = '1 M';
    _overviewController.selectedCryptoTab.value = '1 M';
    _overviewController.selectedStockTab.value = '1 M';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_investmentController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      final investOverview =
          _investmentController.investmentOverview.value?.body;

      if (investOverview == null) {
        return _buildEmptyStockView(context);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStockBalanceSection(),
            addHeight(21),
            buildChartSection(),
            addHeight(21),
            buildPortfolioSection(investOverview),
            addHeight(21),
            Image.asset(
              ImagePaths.stockAna,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            addHeight(21),
            buildTodaysListSection(),
            _pressNewsController.buildNewsSection(context, type: "Stock"),
          ],
        ),
      );
    });
  }

  Widget buildStockBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Balance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              if (_overviewController.isLoading.value) {
                // Show shimmer effect while loading
                return Shimmer.fromColors(
                  baseColor: Colors.black,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    height: 30,
                    width: 120, // Adjust width as needed
                    color: Colors.white,
                  ),
                );
              } else {
               return Text(
                  '\$${_overviewController.totalInvestment_stocks.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
            }),
            Text(
              '${_overviewController.chartResponse.value?.body.percentageChangeStocks.toStringAsFixed(2) ?? '0.00'}% (${_overviewController.selectedTab.value})',
              style: TextStyle(
                color: ((_overviewController.chartResponse.value?.body
                                .percentageChangeStocks ??
                            0) <
                        0)
                    ? Colors.red
                    : Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildChartSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 0.25,
        ),
      ),
      child: Column(
        children: [
          buildStockChart(),
          addHeight(16),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _overviewController.buildTab('1 M'),
                _overviewController.buildTab('3 M'),
                _overviewController.buildTab('6 M'),
                _overviewController.buildTab('1 Y'),
                _overviewController.buildTab('YTD'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStockChart() {
    return Obx(() {
      if (_overviewController.isLoading.value) {
        return buildInvestChartShimmerEffect();
      }

      if (_overviewController.errorMessage.value.isNotEmpty) {
        return isEmptyInvest();
      }

      final stockData = _overviewController.chartResponse.value;
      if (stockData == null || stockData.body.stocks.isEmpty) {
        return isEmptyInvest();
      }

      final chartData = stockData.body.stocks.toList();
      final xLabels = chartData.map((e) => e.monthName).toList();

      final spots = chartData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.total.abs());
      }).toList();

      final totalSum = chartData.fold<double>(
        0,
        (sum, item) => sum + item.total.abs(),
      );

      return Container(
        height: (totalSum == 0.0) ? 150 : 200,
        child: (totalSum == 0.0)
            ? InvestEmptyChart(spots: spots, xLabels: xLabels)
            : ExpenseChart(
                spots: spots,
                xLabels: xLabels,
                timePeriod: _overviewController.selectedTab.value,
                val: _overviewController.totalInvestment_stocks,
              ),
      );
    });
  }

  Widget buildPortfolioSection(dynamic investOverview) {
    return Column(
      children: [
        SectionName(
          title: 'My Portfolio',
          titleOnTap: '',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        MyPortfolio(
          investType: 'Home',
          portfolio: investOverview,
          selectedT: 'Stock',
        ),
      ],
    );
  }

  Widget buildTodaysListSection() {
    return Column(
      children: [
        SectionName(
          title: 'Today\'s lists',
          titleOnTap: 'View All',
          onTap: () => Get.to(() => CoinsScreen()),
        ),
        const SizedBox(height: 16),
        StockCoinTodayList(),
      ],
    );
  }

  Widget _buildEmptyStockView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stock Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${'0.00'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
           const SizedBox(height: 21),
          Container(
            // padding: const EdgeInsets.symmetric(vertical: 16),
            // decoration: BoxDecoration(
            //   // color: Colors.grey[800],
            //   border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
            //   borderRadius: BorderRadius.circular(12),
            // ),

            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 0.25,
              ),
            ),
            child: Column(
              children: [
                buildEmptyInvestGraph(context),
                addHeight(16),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _overviewController.buildTab('1 D'),
                      _overviewController.buildTab('1 M'),
                      _overviewController.buildTab('3 M'),
                      _overviewController.buildTab('6 M'),
                      _overviewController.buildTab('1 Y'),
                      _overviewController.buildTab('YTD'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          connectivityController.isConnected.value == false
              ? GestureDetector(
                  onTap: () {
                    Get.to(() => const AccountsPage());
                  },
                  child: Image.asset('assets/images/overviewempty.png'),
                )
              : Column(
                children: [
                  SectionName(
                    title: 'My Portfolio',
                    titleOnTap: '',
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  Empty(title: 'Portfolio', width: 70),
                ],
              ),
          const SizedBox(height: 24),
          SectionName(
            title: 'Today\'s lists',
            titleOnTap: 'View All',
            onTap: () => Get.to(() => CoinsScreen()),
          ),
          const SizedBox(height: 12),
          StockCoinTodayList(),

          _pressNewsController.buildNewsSection(context, type: "Stock"),
        ],
      ),
    );
  }
}
