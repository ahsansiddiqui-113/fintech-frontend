import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart' hide ChartMode;
import 'package:wealthnx/controller/investment/stocks/stock_live_data/stock_live_data_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/candle_chart/candle_chart.dart';
import 'package:wealthnx/view/vitals/investment/widgets/news_section.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_option.dart';
import 'package:wealthnx/models/investment/stock_investment/stock_live_data_model.dart';
import 'package:wealthnx/models/investment/stock_investment/stock_profile_model.dart';
import 'package:wealthnx/widgets/empty.dart';
import 'package:wealthnx/widgets/load_more.dart';

import '../../../../view/genral_news/crypto_news_all_screen.dart';

class StockCoinDetailScreen extends StatelessWidget {
  StockCoinDetailScreen({
    Key? key,
    this.title,
    this.icon,
    this.sym,
    this.change,
    this.value,
    this.typePortfolio,
  }) : super(key: key) {
    Get.put(StockCoinDetailController(sym));
  }

  final String? title;
  final String? icon;
  final String? sym;
  final double? change;
  final double? value;
  final String? typePortfolio;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StockCoinDetailController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Image.network(
                icon.toString(),
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, color: Colors.white);
                },
              ),
            ),
            Flexible(
              child: Text(
                '  $title ',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              '($sym)',
              style: const TextStyle(
                  color: Color(0xFFC6C6C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [Container(), Container()],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.companyProfile.value == null) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (controller.error.value.isNotEmpty) {
          return Center(
              child: Text('Error: ${controller.error.value}',
                  style: const TextStyle(color: Colors.white)));
        } else {
          final company = controller.companyProfile.value;
          final historical = controller.historicalData.value;

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ------ Top Section -------
                  _buildTopSection(historical),
                  const SizedBox(height: 20),

                  //------ Graph Section ------
                  // // SizedBox(height: 300, child:   CandlePage()),
                  //
                  // Container(
                  //     height: 300,
                  //     child: controller.selectedTab.value == "Li"
                  //         ? CandlePage(isLine: true)
                  //         : controller.selectedTab.value == "Can"
                  //             ? CandlePage(isLine: false)
                  //             : CandlePage(isLine: false)),
                  //
                  // const SizedBox(height: 13),
                  //
                  // //------ Filter Section ------
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     controller.buildTab('1 D'),
                  //     controller.buildTab('7 D'),
                  //     controller.buildTab('1 M'),
                  //     controller.buildTab('6 M'),
                  //     controller.buildTab('1 Y'),
                  //     controller.buildTab('YTD'),
                  //     controller.buildTab('Li'),
                  //     controller.buildTab('Can'),
                  //   ],
                  // ),
// ------ Graph Section ------
                  SizedBox(
                    height: 300,
                    child: Obx(() {
                      final isLine = controller.chartMode.value == ChartMode.line;
                      return CandlePage(isLine: isLine);
                    }),
                  ),

                  const SizedBox(height: 13),

// ------ Filter Section ------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // time range tabs
                      controller.buildTimeTab('1 D'),
                      controller.buildTimeTab('7 D'),
                      controller.buildTimeTab('1 M'),
                      controller.buildTimeTab('6 M'),
                      controller.buildTimeTab('1 Y'),
                      controller.buildTimeTab('YTD'),

                      // chart mode tabs
                controller.buildModeTab(ChartMode.line),
                controller.buildModeTab(ChartMode.candle)
                    ],
                  ),

                  const SizedBox(height: 30),

                  //------ Your Position ------
                  if (typePortfolio == 'portfolio') ...[
                    _buildPositionSection(),
                    SizedBox(height: 30),
                  ],

                  //------ Market Section ------
                  _buildMarketSection(company, historical),
                  addHeight(21),

                  Image.asset(
                    ImagePaths.stockdetl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  addHeight(21),

                  //------ About Section ------
                  _buildAboutSection(company),
                  addHeight(21),

                  //------ News Section ------
                  _buildNewsSection(),
                  SizedBox(height: 60),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildTopSection(CoinDetailModel? historical) {
    final latestData = historical?.historical?.firstOrNull;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${latestData?.close?.toStringAsFixed(2) ?? value?.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '(${change?.toStringAsFixed(2)}%)',
                  style: TextStyle(
                      color: ((change ?? 0) >= 0) ? Colors.green : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  '  Past hour',
                  style: const TextStyle(
                      color: Color(0xFFC6C6C6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Column(
              children: [
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h High',
                  title: latestData?.high?.toStringAsFixed(2) ?? 'N/A',
                ),
                const SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Low',
                  title: latestData?.low?.toStringAsFixed(2) ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Vol',
                  title: latestData?.volume?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: 'Change',
                  title: latestData?.change?.toStringAsFixed(2) ?? 'N/A',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ... keep all other existing _build methods ...

  // ... (keep all your existing _buildTopSection, _buildPositionSection,
  // _buildMarketSection, _buildAboutSection, _buildNewsSection methods exactly as they were)
  // They don't need any changes

  Widget _buildPositionSection() {
    return Column(
      children: [
        SectionName(title: 'Your Position', titleOnTap: ''),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(heading: 'Quantity', title: '0.0732'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(heading: 'Equity', title: '\$1.47'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(heading: 'Average Cost', title: '\$0.066'),
            ),
            SizedBox(
              width: 150,
              child:
                  SectionOption(heading: 'Portfolio Diversity', title: '1.47%'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Today\'s return', title: '\$-0.02195 (+6.43%)'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Total return', title: '\$-0.02195 (+6.43%)'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketSection(
      CompanyProfileModel? company, CoinDetailModel? historical) {
    final latestData = historical?.historical?.firstOrNull;

    return Column(
      children: [
        SectionName(title: 'Market Stats', titleOnTap: ''),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'High',
                  title:
                      '\$${latestData?.high == null ? 'N/A' : latestData?.high?.toStringAsFixed(2)}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Low',
                  title:
                      '\$${latestData?.low == null ? 'N/A' : latestData?.low?.toStringAsFixed(2)}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'open',
                  title:
                      '\$${latestData?.open == null ? 'N/A' : latestData?.open?.toStringAsFixed(2)}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Close',
                  title:
                      '\$${latestData?.close == null ? 'N/A' : latestData?.close?.toStringAsFixed(2)}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: '24 Range',
                  title:
                      '\$${company?.range == null ? 'N/A' : company?.range}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: '52-WK Range', title: '\$${company?.range}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Volume (24h)',
                  title:
                      '\$${latestData?.volume == null ? 'N/A' : latestData?.volume?.toStringAsFixed(0)}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Avg. Volume',
                  title:
                      '\$${company?.averageVolume == null ? 'N/A' : company?.averageVolume?.toStringAsFixed(0)}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Market Cap', title: '${company?.marketCap}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(heading: 'Turnover', title: '\$4334'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Shares Outstanding',
                  title:
                      '${latestData?.volume == null ? 'N/A' : latestData?.volume?.toStringAsFixed(0)}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'VWAP',
                  title:
                      '\$${latestData?.vwap == null ? 'N/A' : latestData?.vwap?.toStringAsFixed(0)}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Adjust Close',
                  title:
                      '${latestData?.adjClose == null ? 'N/A' : latestData?.adjClose?.toStringAsFixed(2)}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Dividend',
                  title:
                      '${company?.lastDividend == null ? 'N/A' : company?.lastDividend}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Exchange',
                  title:
                      '${company?.exchange == null ? 'N/A' : company?.exchange}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Div. Yield',
                  title:
                      '${company?.lastDividend == null ? 'N/A' : company?.lastDividend}'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: 'Change OverTime',
                  title:
                      '\$${latestData?.changeOverTime == null ? 'N/A' : latestData?.changeOverTime}'),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                  heading: '% Range',
                  title:
                      '\$${company?.range == null ? 'N/A' : company?.range}'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(CompanyProfileModel? company) {
    return Column(
      children: [
        SectionName(title: 'About', titleOnTap: ''),
        const SizedBox(height: 10),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     '${company?.description == null ? 'N/A' : company?.description}',
        //     style: const TextStyle(
        //       color: Color(0xFFC6C6C6),
        //       fontSize: 14,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.centerLeft,
          child: LoadMoreText(
            text:
                '${company?.description == null ? 'No description available' : company?.description}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // const SizedBox(height: 10),
        // Divider(thickness: 0.25, height: 2),
      ],
    );
  }

  Widget _buildNewsSection() {
    final controller = Get.put(ChartController());
    return Column(
      children: [
        SectionName(
            title: 'News',
            titleOnTap: '',
            onTap: () {
              // Get.put(ChartController()).newsList.clear();
              // String coinParms = "${sym}".toUpperCase();
              // // String coinParms = '${stock.symbol}USD'.toUpperCase();
              // print(coinParms);
              //
              // Get.put(ChartController())
              //     .fetchNews(newsId: coinParms, cryptoNews: false);
              // Get.to(() => CryptoNewsAllScreen(
              //       cryptoNews: false,
              //       newsId: coinParms,
              //       // newsId: "",
              //       // cryptoNews: true,
              //     ));
            }),
        // const SizedBox(height: 10),
        Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            controller.fetchNews(newsId: "", cryptoNews: false);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : controller.newsList.isEmpty
                    ? Container(
                        child: Empty(
                        title: 'News',
                        width: 70,
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: controller.newsList.length >= 2
                            ? 2
                            : controller.newsList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final news = controller.newsList[index];

                          // Date format conversion
                          DateTime? publishedDate;
                          try {
                            publishedDate =
                                DateTime.parse(news.publishedDate.toString());
                          } catch (e) {
                            publishedDate = null;
                          }

                          String displayDate = "";
                          if (publishedDate != null) {
                            final now = DateTime.now();
                            final difference =
                                now.difference(publishedDate).inDays;

                            if (difference == 0) {
                              displayDate = "Today";
                            } else if (difference == 1) {
                              displayDate = "Yesterday";
                            } else {
                              displayDate =
                                  "${publishedDate.day}-${publishedDate.month}-${publishedDate.year}";
                            }
                          }
                          DateTime published_Date =
                              DateTime.parse(news.publishedDate.toString());

                          return NewsSection(
                              heading: '${news.symbol} News: ${news.title}',
                              title: news.publisher.toString(),
                              icon: news.image != null
                                  ? news.image.toString()
                                  : ImagePaths.cnn,
                              // date: DateFormat('dd/MM/yyyy hh:mm a')
                              //     .format(publishedDate!)
                            date: formatDateAndTime(publishedDate!.toString()),
                          );
                          /*Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: news.image != null
                              ? Image.network(
                                  news.image!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(
                            news.title.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(news.publisher.toString()),
                              Text(
                                displayDate,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final url = Uri.parse(news.url.toString());
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              Get.snackbar('Error', 'Could not launch URL');
                            }
                          },
                        ),
                      );*/
                        },
                      )),
      ],
    );
  }
}
