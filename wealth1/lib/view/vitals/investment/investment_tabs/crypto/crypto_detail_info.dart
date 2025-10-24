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
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';
import 'package:wealthnx/widgets/load_more.dart';

import '../../../../../view/genral_news/crypto_news_all_screen.dart';

class CryptoDetailInfo extends StatelessWidget {
  CryptoDetailInfo({
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
    // _cryptoController.fetchCoinDetails(id ?? '');

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
      body: Obx(
        () => Stack(children: [
          // print('Data Details: ${coin}');
          if (_cryptoController.isLoading.value) ...[
            Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            )),
          ] else if (_cryptoController.error.value.isNotEmpty) ...[
            Center(
                child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            )),
          ] else ...[
            //  coin = _cryptoController.coinDetails.value;

            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ------ Top Section -------
                    if (typePortfolio != 'portfolio') ...[
                      _buildTopSection(_chartController),
                      SizedBox(height: 20),
                    ],

                    if (typePortfolio == 'portfolio') ...[
                      _buildTopPortfolioSection(_cryptoController),
                      SizedBox(height: 20),
                    ],
                    // //------ Graph Section ------
                    //
                    // Container(
                    //     height: 300,
                    //     child: _chartController.selectedTab.value == "Li"
                    //         ? CryptoCandleChartView(isLine: true)
                    //         : _chartController.selectedTab.value == "Can"
                    //             ? CryptoCandleChartView(isLine: false)
                    //             : CryptoCandleChartView(isLine: false)),
                    // SizedBox(height: 13),
                    //
                    // //------ Filter Section ------
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     _chartController.buildTab('1 D'),
                    //     _chartController.buildTab('7 D'),
                    //     _chartController.buildTab('1 M'),
                    //     _chartController.buildTab('6 M'),
                    //     _chartController.buildTab('1 Y'),
                    //     _chartController.buildTab('YTD'),
                    //     _chartController.buildTab('Li'),
                    //     _chartController.buildTab('Can'),
                    //   ],
                    // ),
                    // ------ Graph Section ------
                    SizedBox(
                      height: 300,
                      child: Obx(() => CryptoCandleChartView(
                        isLine: _chartController.chartMode.value == ChartMode.line,
                      )),
                    ),
                    const SizedBox(height: 13),

// ------ Filter Section ------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _chartController.buildRangeTab('1 D'),
                        _chartController.buildRangeTab('7 D'),
                        _chartController.buildRangeTab('1 M'),
                        _chartController.buildRangeTab('6 M'),
                        _chartController.buildRangeTab('1 Y'),
                        _chartController.buildRangeTab('YTD'),
                        _chartController.buildModeTab(ChartMode.line),
                        _chartController.buildModeTab(ChartMode.candle),
                      ],
                    ),

                    SizedBox(height: 30),

                    //------ Your Position ------
                    if (typePortfolio == 'portfolio') ...[
                      _buildYourPositionSection(),
                      SizedBox(height: 30),
                    ],

                    //------ Market Section ------

                    if (typePortfolio != 'portfolio') ...[
                      _buildMarketStatsSection(),
                      SizedBox(height: 20),
                    ],

                    Image.asset(
                      ImagePaths.cryptodetl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    addHeight(21),

                    if (typePortfolio == 'portfolio') ...[
                      _buildPortfolioMarketStatsSection(_cryptoController),
                      SizedBox(height: 20),
                    ],
                    //------ About Section ------
                    _buildAboutSection(_cryptoController.coinDetails.value),
                    SizedBox(height: 20),

                    //------ News Section ------
                    _buildNewsSection(),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ]
        ]),
      ),
    );
  }

  Widget _buildTopSection(ChartController _chartController) {
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
                  title: '${high == null ? 'N/A' : high}',
                ),
                SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Low',
                  title: '${low == null ? 'N/A' : low}',
                ),
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
                      '${volume == null ? 'N/A' : formatNumberWithSuffix(volume.toString())}',
                ),
                SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Vol(USD)',
                  title:
                      '${volume == null ? 'N/A' : formatNumberWithSuffix(volume.toString())}',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPortfolioSection(
      CryptoDetailInfoController _cryptoController) {
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
                      '${_cryptoController.marketCoinList[0].high24H == null ? 'N/A' : _cryptoController.marketCoinList[0].high24H}',
                ),
                SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Low',
                  title:
                      '${_cryptoController.marketCoinList[0].low24H == null ? 'N/A' : _cryptoController.marketCoinList[0].low24H}',
                ),
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
                      '${_cryptoController.marketCoinList[0].totalVolume == null ? 'N/A' : formatNumberWithSuffix(_cryptoController.marketCoinList[0].totalVolume.toString())}',
                ),
                SizedBox(height: 8),
                SectionOption(
                  fontSize: 10.5,
                  heading: '24h Vol(USD)',
                  title:
                      '${_cryptoController.marketCoinList[0].totalVolume == null ? 'N/A' : formatNumberWithSuffix(_cryptoController.marketCoinList[0].totalVolume.toString())}',
                ),
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

  Widget _buildMarketStatsSection() {
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
                title: '\$${high == null ? 'N/A' : high}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Low',
                title: '\$${low == null ? 'N/A' : low}',
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
                title: '${priceChg24 == null ? 'N/A' : priceChg24}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Price Change %',
                title: '${priceChgPer == null ? 'N/A' : priceChgPer}',
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
                    '\$${circulatingSupply == null ? 'N/A' : formatNumberWithSuffix(circulatingSupply.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Total Supply',
                title:
                    '\$${totalSupply == null ? 'N/A' : formatNumberWithSuffix(totalSupply.toString())}',
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
                    '\$${marketCap == null ? 'N/A' : formatNumberWithSuffix(marketCap.toString())}',
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
                title: '\$${ath == null ? 'N/A' : ath}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Ath Date',
                title:
                    '${athDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(athDate.toString()))}', // Update with actual data
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
                title: '\$${atl == null ? 'N/A' : atl}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Atl Date',
                title:
                    '${atlDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(atlDate.toString()))}', // Update with actual data
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
                    '\$${marketCap == null ? 'N/A' : formatNumberWithSuffix(marketCap.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Market Change 24h',
                title:
                    '\$${marketChg24 == null ? 'N/A' : formatNumberWithSuffix(marketChg24.toString())}', // Update with actual data
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
                    '\$${fdv == null ? 'N/A' : formatNumberWithSuffix(fdv.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Volume',
                title:
                    '\$${volume == null ? 'N/A' : formatNumberWithSuffix(volume.toString())}', // Update with actual data
              ),
            ),
          ],
        ),
        // Add more market stats rows as needed
      ],
    );
  }

  Widget _buildPortfolioMarketStatsSection(
      CryptoDetailInfoController marketController) {
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
                    '\$${marketController.marketCoinList[0].high24H == null ? 'N/A' : marketController.marketCoinList[0].high24H}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Low',
                title:
                    '\$${marketController.marketCoinList[0].low24H == null ? 'N/A' : marketController.marketCoinList[0].low24H}',
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
                    '${marketController.marketCoinList[0].priceChange24H == null ? 'N/A' : marketController.marketCoinList[0].priceChange24H}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Price Change %',
                title:
                    '${marketController.marketCoinList[0].priceChangePercentage24H == null ? 'N/A' : marketController.marketCoinList[0].priceChangePercentage24H}',
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
                    '\$${marketController.marketCoinList[0].circulatingSupply == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].circulatingSupply.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Total Supply',
                title:
                    '\$${marketController.marketCoinList[0].totalSupply == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].totalSupply.toString())}',
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
                    '\$${marketController.marketCoinList[0].marketCap == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].marketCap.toString())}',
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
                heading: 'Ath',
                title:
                    '\$${marketController.marketCoinList[0].ath == null ? 'N/A' : marketController.marketCoinList[0].ath}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Ath Date',
                title:
                    '${marketController.marketCoinList[0].athDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(marketController.marketCoinList[0].athDate.toString()))}', // Update with actual data
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
                    '\$${marketController.marketCoinList[0].atl == null ? 'N/A' : marketController.marketCoinList[0].atl}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Atl Date',
                title:
                    '${marketController.marketCoinList[0].atlDate == null ? 'N/A' : DateFormat('d MMM, y').format(DateTime.parse(marketController.marketCoinList[0].atlDate.toString()))}', // Update with actual data
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
                    '\$${marketController.marketCoinList[0].marketCap == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].marketCap.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Market Change 24h',
                title:
                    '\$${marketController.marketCoinList[0].marketCapChange24H == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].marketCapChange24H.toString())}', // Update with actual data
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
                    '\$${marketController.marketCoinList[0].fullyDilutedValuation == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].fullyDilutedValuation.toString())}',
              ),
            ),
            SizedBox(
              width: 150,
              child: SectionOption(
                heading: 'Volume',
                title:
                    '\$${marketController.marketCoinList[0].totalVolume == null ? 'N/A' : formatNumberWithSuffix(marketController.marketCoinList[0].totalVolume.toString())}', // Update with actual data
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
                              // date: DateFormat('dd/MM/yyyy hh:mm a')
                              //     .format(publishedDate!)
                            date: formatDateAndTime(news.publishedDate.toString()),
                          );
                        },
                      )),
      ],
    );
  }
}
