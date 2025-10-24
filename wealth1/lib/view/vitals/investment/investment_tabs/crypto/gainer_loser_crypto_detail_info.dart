import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/live_chart/crypto_live_chart.dart';
import 'package:wealthnx/view/vitals/investment/widgets/news_section.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_option.dart';
import 'package:wealthnx/models/investment/crypto_investment/market_coin_list_model.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';
import 'package:wealthnx/widgets/load_more.dart';

class GainerLoserCryptoDetailInfo extends StatelessWidget {
  GainerLoserCryptoDetailInfo({
    Key? key,
    this.id,
    this.title,
    this.icon,
    this.sym,
    this.change,
    this.value,
    this.typePortfolio,
    this.high,
    this.low,
    this.priceChg24,
    this.priceChgPer,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.ath,
    this.atl,
    this.athDate,
    this.atlDate,
    this.marketCap,
    this.marketChg24,
    this.fdv,
    this.volume,
  }) : super(key: key);

  final String? id;
  final String? title;
  final String? icon;
  final String? sym;
  final double? change;
  final double? value;
  final String? typePortfolio;
  final String? high;
  final String? low;
  final String? priceChg24;
  final String? priceChgPer;
  final String? circulatingSupply;
  final String? totalSupply;
  final String? maxSupply;
  final String? ath;
  final String? atl;
  final String? athDate;
  final String? atlDate;
  final String? marketCap;
  final String? marketChg24;
  final String? fdv;
  final String? volume;

  @override
  Widget build(BuildContext context) {
    final CryptoDetailInfoController _cryptoController =
        Get.find<CryptoDetailInfoController>();

    final _chartController = Get.put(ChartController());

    // final CryptoDetailInfoController _cryptoDetailController =
    //     Get.find<CryptoDetailInfoController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Image.network(
                icon ?? '',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image,
                    color: Colors.white,
                  );
                },
              ),
            ),
            Flexible(
              child: Text(
                '  $title ',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              '($sym)',
              style: TextStyle(
                  color: const Color(0xFFC6C6C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [Container(), Container()],
      ),
      body: Obx(() {
        // print('Data Details: ${coin}');
        if (_cryptoController.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        } else if (_cryptoController.error.value.isNotEmpty) {
          return Center(
              child: Text(
            'No data available',
            style: TextStyle(color: Colors.white),
          ));
        } else {
          final coin = _cryptoController.coinDetails.value;
          final gainerLoser = _cryptoController.marketCoinList;

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ------ Top Section -------
                  _buildTopSection(_chartController, gainerLoser),
                  SizedBox(height: 20),

                  //------ Graph Section ------
                  Container(height: 300, child: CryptoCandleChartView()),
                  SizedBox(height: 13),

                  //------ Filter Section ------
                  // FilterChart(selectedTab: 'YTD'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _chartController.buildRangeTab('1 D'),
                      Spacer(),
                      _chartController.buildRangeTab('7 D'),
                      Spacer(),
                      _chartController.buildRangeTab('1 M'),
                      Spacer(),
                      _chartController.buildRangeTab('6 M'),
                      Spacer(),
                      _chartController.buildRangeTab('1 Y'),
                      Spacer(),
                      _chartController.buildRangeTab('YTD'),
                    ],
                  ),
                  SizedBox(height: 30),

                  //------ Your Position ------
                  if (typePortfolio == 'portfolio') ...[
                    _buildYourPositionSection(),
                    SizedBox(height: 30),
                  ],

                  //------ Market Section ------
                  _buildMarketStatsSection(gainerLoser),
                  SizedBox(height: 20),

                  //------ About Section ------
                  _buildAboutSection(coin),
                  SizedBox(height: 20),

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

  Widget _buildTopSection(
      ChartController _chartController, List<MarketCoinListModel> gainerLoser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   '\$${_chartController.chartData.last.high ?? '0.0'}',
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 24,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            Text(
              '\$${value?.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '(${change?.toStringAsFixed(2)}%)',
                  style: TextStyle(
                      color:
                          (change!.toDouble() > 0) ? Colors.green : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  '  Past hour',
                  style: TextStyle(
                      color: const Color(0xFFC6C6C6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        Row(
          children: [
            Column(
              children: [
                SectionOption(
                    fontSize: 10.5,
                    heading: '24h High',
                    title:
                        '${gainerLoser.isNotEmpty && gainerLoser[0].high24H != null ? gainerLoser[0].high24H : 'N/A'}'),
                SizedBox(height: 8),
                SectionOption(
                    fontSize: 10.5,
                    heading: '24h Low',
                    title:
                        '${gainerLoser.isNotEmpty && gainerLoser[0].low24H != null ? gainerLoser[0].low24H : 'N/A'}'),
              ],
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SectionOption(
                    fontSize: 10.5,
                    heading: '24h Vol(${sym?.toUpperCase()})',
                    title:
                        '${gainerLoser.isNotEmpty && gainerLoser[0].totalVolume != null ? formatNumberWithSuffix(gainerLoser[0].totalVolume.toString()) : 'N/A'}'),
                SizedBox(height: 8),
                SectionOption(
                    fontSize: 10.5,
                    heading: '24h Vol(USD)',
                    title:
                        '${gainerLoser.isNotEmpty && gainerLoser[0].totalVolume != null ? formatNumberWithSuffix(gainerLoser[0].totalVolume.toString()) : 'N/A'}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYourPositionSection() {
    return Column(
      children: [
        SectionName(title: 'Your Position', titleOnTap: ''),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Quantity',
                title: '0.0732',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Equity',
                title: '\$1.47',
              ),
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
                heading: 'Average Cost',
                title: '\$0.066',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Portfolio Diversity',
                title: '1.47%',
              ),
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
                heading: 'Today\'s return',
                title: '\$-0.02195 (+6.43%)',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Total return',
                title: '\$-0.02195 (+6.43%)',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketStatsSection(List<MarketCoinListModel> gainerLoser) {
    return Column(
      children: [
        SectionName(title: 'Market Stats', titleOnTap: ''),
        const SizedBox(height: 10),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     SizedBox(
        //       width: 150,
        //       child: SectionOption(
        //         heading: 'open',
        //         title: '\$${marketD?.high24H}',
        //       ),
        //     ),
        //     SizedBox(
        //       width: 150,
        //       child: SectionOption(
        //         heading: 'Close',
        //         title: '\$-0.021',
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'High',
                title:
                    '\$${gainerLoser[0].high24H == null ? 'N/A' : gainerLoser[0].high24H}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Low',
                title:
                    '\$${gainerLoser[0].low24H == null ? 'N/A' : gainerLoser[0].low24H}',
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Price Change 24h',
                title:
                    '\$${gainerLoser[0].priceChange24H == null ? 'N/A' : gainerLoser[0].priceChange24H}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Price Change %',
                title:
                    '\$${gainerLoser[0].priceChangePercentage24H == null ? 'N/A' : gainerLoser[0].priceChangePercentage24H}',
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Circulating Supply',
                title:
                    '\$${gainerLoser[0].circulatingSupply == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].circulatingSupply.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Total Supply',
                title:
                    '\$${gainerLoser[0].totalSupply == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].totalSupply.toString())}',
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Max Supply',
                title:
                    '\$${gainerLoser[0].marketCap == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].marketCap.toString())}',
              ),
            ),
            // SizedBox(
            //   width: 150,
            //   child: SectionOption(
            //     heading: 'Total Supply',
            //     title: '\$-0.021',
            //   ),
            // ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Ath',
                title:
                    '\$${gainerLoser[0].ath == null ? 'N/A' : gainerLoser[0].ath}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Ath Date',
                title:
                    '${gainerLoser[0].athDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(gainerLoser[0].athDate.toString()))}', // Update with actual data
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Atl',
                title:
                    '\$${gainerLoser[0].atl == null ? 'N/A' : gainerLoser[0].atl}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Atl Date',
                title:
                    '${gainerLoser[0].atlDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(gainerLoser[0].atlDate.toString()))}', // Update with actual data
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Market Cap',
                title:
                    '\$${gainerLoser[0].marketCap == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].marketCap.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Market Change 24h',
                title:
                    '\$${gainerLoser[0].marketCapChange24H == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].marketCapChange24H.toString())}', // Update with actual data
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'FDV',
                title:
                    '\$${gainerLoser[0].fullyDilutedValuation == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].fullyDilutedValuation.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Volume',
                title:
                    '\$${gainerLoser[0].totalVolume == null ? 'N/A' : formatNumberWithSuffix(gainerLoser[0].totalVolume.toString())}', // Update with actual data
              ),
            ),
          ],
        ),
        // Add more market stats rows as needed
      ],
    );
  }

  Widget _buildAboutSection(coin) {
    return Column(
      children: [
        SectionName(title: 'About', titleOnTap: ''),
        const SizedBox(height: 10),
        Align(
            alignment: Alignment.centerLeft,
            child: LoadMoreText(
              text: coin.description?.en ?? 'No description available',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            )

            //  Text(
            //   coin.description?.en ?? 'No description available',
            //   style: const TextStyle(
            //     color: Color(0xFFC6C6C6),
            //     fontSize: 14,
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
            ),
        const SizedBox(height: 10),
        Divider(thickness: 0.25, height: 2),
      ],
    );
  }

  Widget _buildNewsSection() {
    final controller = Get.put(ChartController());

    return Column(
      children: [
        SectionName(title: 'News', titleOnTap: ''),
        const SizedBox(height: 10),
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
                            controller.fetchNews(newsId: "", cryptoNews: true);
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
                              date:  formatDateAndTime(publishedDate!.toString()),
                              // date: DateFormat('dd/MM/yyyy hh:mm a')
                              //     .format(publishedDate!)
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
