import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';

import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/controller/investment/investment_controller.dart';
import 'package:wealthnx/controller/investment/overview/overview_controller.dart';
import 'package:wealthnx/view/vitals/accounts/accounts_page.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/coins_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_coin_today_list/crypto_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stocks/stock_coin_today_list/stock_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/widgets/crypto_list_section.dart';

import 'package:wealthnx/view/vitals/investment/widgets/my_portfolio.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/view/genral_news/press_release_news_view_screen.dart';
import 'package:wealthnx/view/webview_news/news_details_webview.dart';
import 'package:wealthnx/widgets/custom_list_item.dart';
import 'package:wealthnx/widgets/empty.dart';
import 'package:timeago/timeago.dart' as timeago;

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final CheckPlaidConnectionController _checkPlaidConnectionController =
      Get.find<CheckPlaidConnectionController>();
  final InvestmentController _investmentController =
      Get.find<InvestmentController>();
  final OverviewController _overviewController = Get.find<OverviewController>();
  final PressReleaseNewsController _pressNewsController =
      Get.put(PressReleaseNewsController());
  final CommonController _commonController = Get.put(CommonController());
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    Get.find<CheckPlaidConnectionController>().checkConnection();
    _pressNewsController.fetchPaginatedNews(isFirstLoad: true);
    _overviewController.fetchOverviewSummary();
    _overviewController.selectedTab.value = '1 M';
    _overviewController.selectedCryptoTab.value = '1 M';
    _overviewController.selectedStockTab.value = '1 M';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_investmentController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.white));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTotalInvestmentSection(),
            addHeight(21),
            buildChartSection(),
            addHeight(21),
            buildPortfolioSection(context),
            addHeight(21),
            buildTodayListSection(),
            addHeight(0),
            // joinDiscordCard(
            //     text: 'Join Our Community',
            //     subText:
            //         'Join our Discord Community to get access to new features before anyone & help us improve WealthNX',
            //     onTap: () {}),
            // addHeight(21),
            _pressNewsController.buildNewsSection(context, type: ""),
          ],
        ),
      );
    });
  }

  Widget buildTotalInvestmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Investment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () {
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
                  // Show the actual text when not loading
                  return Text(
                    '\$${_overviewController.totalInvestment_overview.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
              },
            ),
            Obx(
              () => Text(
                '${_overviewController.chartResponse.value?.body.percentageChangeOverview.toStringAsFixed(2) ?? '0.00'}% (${_overviewController.selectedTab.value})',
                style: TextStyle(
                  color: ((_overviewController.chartResponse.value?.body
                                  .percentageChangeOverview ??
                              0) <
                          0)
                      ? Colors.red
                      : Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
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
          buildSpendGraph(),
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

  Widget buildTodayListSection() {
    return Column(
      children: [
        SectionName(
          title: 'Today\'s List',
          titleOnTap: '',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        SectionName(
          title: 'Crypto',
          titleOnTap: 'View All',
          fontSize: responTextWidth(12),
          onTapColor: Color(0xFFB6B6B6),
          onTap: () => Get.to(() => CryptoCoinTodayList()),
        ),
        const SizedBox(height: 16),
        CryptoListSection(filterTag: 'overview'),
        SectionName(
          title: 'Stocks',
          titleOnTap: 'View All',
          fontSize: responTextWidth(12),
          onTapColor: Color(0xFFB6B6B6),
          onTap: () => Get.to(() => CoinsScreen()),
        ),
        const SizedBox(height: 16),
        StockCoinTodayList(filterTag: 'overview'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildPortfolioSection(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_homeController.isLoadingPortfolio.value) ...[
            coinTypeShimmer(context),
          ] else if (_checkPlaidConnectionController.isConnected.value ==
              false) ...[
            GestureDetector(
                onTap: () {
                  Get.to(() => AccountsPage());
                },
                child: Image.asset('assets/images/overviewempty.png'))
          ] else if (_homeController.myPortfolio.isEmpty) ...[
            Center(
              child: Empty(
                title: 'Portfolio',
                height: responTextHeight(70),
              ),
            ),
          ] else ...[
            SectionName(
              title: 'My Portfolio',
              titleOnTap: 'View All',
              onTap: () {
                // Get.to(() => MyPortfolioScreen());
              },
            ),
            addHeight(14),
            SizedBox(
                height: MediaQuery.of(context).viewPadding.bottom + 107,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _homeController.myPortfolio.length,
                    itemBuilder: (context, index) {
                      return CoinItem(
                        icon: _homeController.myPortfolio[index].image,
                        symbol: _homeController.myPortfolio[index].name,
                        sym: _homeController.myPortfolio[index].tickerSymbol,
                        change:
                            _homeController.myPortfolio[index].updatedAmount,
                        value: _homeController.myPortfolio[index].amount,
                        title: 'Home',
                      );

                      // homePortfolio(_homeController.myPortfolio[index]);
                    })),
            addHeight(21),
            Image.asset(
              ImagePaths.overview,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ],
        ],
      );
    });
  }

  Widget buildSpendGraph() {
    return Obx(() {
      if (_overviewController.isLoading.value) {
        return buildInvestChartShimmerEffect();
      }

      if (_overviewController.errorMessage.value.isNotEmpty) {
        return isEmptyInvest();
      }

      final chartResponse = _overviewController.chartResponse.value;
      if (chartResponse == null || chartResponse.body.overview.isEmpty) {
        return isEmptyInvest();
      }

      final overviewData = chartResponse.body.overview.toList();
      final xLabels = overviewData.map((e) => e.monthName).toList();

      final spots = overviewData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.total.abs());
      }).toList();

      final totalSum = overviewData.fold<double>(
        0,
        (sum, item) => sum + item.total.abs(),
      );
      print('Total Sum: $xLabels  $totalSum');

      return Container(
        height: (totalSum == 0.0) ? 150 : 200,
        child: (totalSum == 0.0)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InvestEmptyChart(spots: spots, xLabels: xLabels),
              )
            : ExpenseChart(
                spots: spots,
                xLabels: xLabels,
                timePeriod: _overviewController.selectedTab.value,
                val: _overviewController.totalInvestment_overview,
              ),
      );
    });
  }

  Widget buildNewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionName(
          title: 'News',
          titleOnTap: 'View All',
          onTap: () {
            _pressNewsController.fetchPaginatedNews(isFirstLoad: true);
            Get.to(() => PressReleaseNewsViewScreen(
                  type: 'Crypto',
                ));
          },
        ),
        addHeight(16),
        Obx(() {
          if (_pressNewsController.isLoading.value &&
              _pressNewsController.newsList.isEmpty) {
            return ListView.builder(
              itemCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildInvestChartShimmerEffect(),
                );
              },
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pressNewsController.newsList.length >= 2
                ? 2
                : _pressNewsController.newsList.length,
            itemBuilder: (context, index) {
              final news = _pressNewsController.newsList[index];

              String truncateToWords(String text, int maxWords) {
                final words = text.split(' ');
                if (words.length <= maxWords) return text;
                return words.take(maxWords).join(' ') + '...';
              }

              final truncatedTitle = truncateToWords(news.title.toString(), 6);

              return GestureDetector(
                onTap: () => Get.to(() => WebViewPage(
                      url: news.url ?? '',
                      title: news.title ?? 'News Details',
                    )),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: responTextWidth(180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      onError: (url, error) => const AssetImage(
                        'assets/images/placeholder.png',
                      ),
                      image: NetworkImage(news.image.toString()),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        context.gc(AppColor.black).withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(responTextWidth(12)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                context.gc(AppColor.transparent),
                                context.gc(AppColor.black).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: _commonController.textWidget(
                            context,
                            title: truncatedTitle,
                            fontSize: responTextWidth(16),
                            fontWeight: FontWeight.w400,
                            color: Color(0xffF4F4F4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Positioned(
                        top: responTextHeight(10),
                        right: responTextWidth(10),
                        child: _commonController.textWidget(
                          context,
                          title: timeago
                              .format(DateTime.parse(news.publishedDate!)),
                          fontSize: responTextWidth(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
