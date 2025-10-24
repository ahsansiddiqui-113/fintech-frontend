import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/controller/investment/crypto/today_crypto_list/market_coin_list_controller.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_detail_info.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/gainer_loser_crypto_detail_info.dart';

import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';

class CryptoListSection extends StatelessWidget {
  CryptoListSection({super.key, this.filterTag});

  String? filterTag;

  final MarketCoinController _marketController =
  Get.find<MarketCoinController>();

  final CryptoDetailInfoController controller =
  Get.find<CryptoDetailInfoController>();

  final _chartController = Get.put(ChartController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation tabs - only show if not overview
        if (filterTag != 'overview') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _marketController.buildTab('Trending'),
              _marketController.buildTab('Gainers'),
              _marketController.buildTab('Losers'),
              _marketController.buildTab('New'),
              _marketController.buildTab('All'),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Content based on selected tab or overview mode
        SizedBox(
          child: Obx(() {
            if (_marketController.isLoading.value) {
              return buildlistShimmerEffect();
            } else if (_marketController.errorMessage.isNotEmpty) {
              return Center(
                child: Empty(
                  title: 'Empty List',
                  height: responTextHeight(70),
                ),
              );
            } else if (_marketController.marketCoinList.isEmpty &&
                (filterTag != 'overview' || _marketController.trendingCoinList.isEmpty)) {
              return Center(
                child: Empty(
                  title: 'Empty List',
                  height: responTextHeight(70),
                ),
              );
            } else {
              // Handle overview case - show top 3 trending
              if (filterTag == 'overview') {
                return selectedOverviewTrendingWidget();
              }

              // Handle normal tab selection
              if (_marketController.selectedTab.value == 'All') {
                return selectedAllWidget();
              } else if (_marketController.selectedTab.value == 'Trending') {
                return selectedTrendingWidget();
              } else if (_marketController.selectedTab.value == 'New') {
                return selectedAllWidget();
              } else if (_marketController.selectedTab.value == 'Gainers') {
                return selectedGainerWidget();
              } else if (_marketController.selectedTab.value == 'Losers') {
                return selectedLoserWidget();
              }
              return Container();
            }
          }),
        ),
      ],
    );
  }

  // New widget for overview page - shows top 3 trending coins
  Widget selectedOverviewTrendingWidget() {
    // Use trendingCoinList for overview, limit to 3
    final trendingCoins = _marketController.trendingCoinList.length > 3
        ? _marketController.trendingCoinList.sublist(0, 3)
        : _marketController.trendingCoinList;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: trendingCoins.length,
      itemBuilder: (context, index) {
        final marketcoin = trendingCoins[index];
        return GestureDetector(
          onTap: () {
            print('Title: ${marketcoin.id}');
            print('Symbol: ${marketcoin.symbol}');

            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: true);
            Get.to(
                  () => CryptoDetailInfo(
                typePortfolio: 'todaylist',
                id: marketcoin.id,
                title: marketcoin.name,
                icon: marketcoin.image,
                sym: marketcoin.symbol,
                change: marketcoin.athChangePercentage,
                value: marketcoin.currentPrice,
                high: marketcoin.high24H?.toStringAsFixed(2),
                low: marketcoin.low24H?.toStringAsFixed(2),
                priceChg24: (marketcoin.priceChange24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChange24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChange24H?.abs().toStringAsFixed(2)}',
                priceChgPer: (marketcoin.priceChangePercentage24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChangePercentage24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChangePercentage24H?.abs().toStringAsFixed(2)}',
                circulatingSupply:
                marketcoin.circulatingSupply?.toStringAsFixed(2),
                totalSupply: marketcoin.totalSupply?.toStringAsFixed(2),
                maxSupply: marketcoin.maxSupply?.toStringAsFixed(2),
                ath: marketcoin.ath?.toStringAsFixed(2),
                atl: marketcoin.atl?.toStringAsFixed(2),
                athDate: marketcoin.athDate.toString(),
                atlDate: marketcoin.atlDate.toString(),
                marketCap: marketcoin.marketCap?.toStringAsFixed(2),
                marketChg24: marketcoin.marketCapChange24H?.toStringAsFixed(2),
                fdv: marketcoin.fullyDilutedValuation?.toStringAsFixed(2),
                volume: marketcoin.totalVolume?.toStringAsFixed(2),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != trendingCoins.length - 1
                ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff252525),
                  width: 0.6,
                ),
              ),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Image.network(
                    marketcoin.image.toString(),
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width / 1.4,
                        child: Text(
                          marketcoin.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        marketcoin.symbol.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${marketcoin.currentPrice?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${marketcoin.athChangePercentage?.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: marketcoin.athChangePercentage! > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget for Trending tab (when not in overview mode)
  Widget selectedTrendingWidget() {
    final trendingCoins = _marketController.trendingCoinList.length > 5
        ? _marketController.trendingCoinList.sublist(0, 5)
        : _marketController.trendingCoinList;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: trendingCoins.length > 3 ? 3 : trendingCoins.length,
      itemBuilder: (context, index) {
        final marketcoin = trendingCoins[index];
        return GestureDetector(
          onTap: () {
            print('Title: ${marketcoin.id}');
            print('Symbol: ${marketcoin.symbol}');

            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: true);
            Get.to(
                  () => CryptoDetailInfo(
                typePortfolio: 'todaylist',
                id: marketcoin.id,
                title: marketcoin.name,
                icon: marketcoin.image,
                sym: marketcoin.symbol,
                change: marketcoin.athChangePercentage,
                value: marketcoin.currentPrice,
                high: marketcoin.high24H?.toStringAsFixed(2),
                low: marketcoin.low24H?.toStringAsFixed(2),
                priceChg24: (marketcoin.priceChange24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChange24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChange24H?.abs().toStringAsFixed(2)}',
                priceChgPer: (marketcoin.priceChangePercentage24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChangePercentage24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChangePercentage24H?.abs().toStringAsFixed(2)}',
                circulatingSupply:
                marketcoin.circulatingSupply?.toStringAsFixed(2),
                totalSupply: marketcoin.totalSupply?.toStringAsFixed(2),
                maxSupply: marketcoin.maxSupply?.toStringAsFixed(2),
                ath: marketcoin.ath?.toStringAsFixed(2),
                atl: marketcoin.atl?.toStringAsFixed(2),
                athDate: marketcoin.athDate.toString(),
                atlDate: marketcoin.atlDate.toString(),
                marketCap: marketcoin.marketCap?.toStringAsFixed(2),
                marketChg24: marketcoin.marketCapChange24H?.toStringAsFixed(2),
                fdv: marketcoin.fullyDilutedValuation?.toStringAsFixed(2),
                volume: marketcoin.totalVolume?.toStringAsFixed(2),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != 2 && index != trendingCoins.length - 1
                ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff252525),
                  width: 0.6,
                ),
              ),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Image.network(
                    marketcoin.image.toString(),
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width / 1.4,
                        child: Text(
                          marketcoin.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        marketcoin.symbol.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${marketcoin.currentPrice?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${marketcoin.athChangePercentage?.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: marketcoin.athChangePercentage! > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectedAllWidget() {
    final todayListCrypto = _marketController.marketCoinList.length > 5
        ? _marketController.marketCoinList.sublist(0, 5)
        : _marketController.marketCoinList;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 3, //todayListCrypto.length,
      itemBuilder: (context, index) {
        final marketcoin = _marketController.marketCoinList[index];
        return GestureDetector(
          onTap: () {
            print('Title: ${marketcoin.id}');
            print('Symbol: ${marketcoin.symbol}');

            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: true);
            Get.to(
                  () => CryptoDetailInfo(
                typePortfolio: 'todaylist',
                id: marketcoin.id,
                title: marketcoin.name,
                icon: marketcoin.image,
                sym: marketcoin.symbol,
                change: marketcoin.athChangePercentage,
                value: marketcoin.currentPrice,
                high: marketcoin.high24H?.toStringAsFixed(2),
                low: marketcoin.low24H?.toStringAsFixed(2),
                priceChg24: (marketcoin.priceChange24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChange24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChange24H?.abs().toStringAsFixed(2)}',
                priceChgPer: (marketcoin.priceChangePercentage24H ?? 0) >= 0
                    ? '\$${marketcoin.priceChangePercentage24H?.toStringAsFixed(2)}'
                    : '-\$${marketcoin.priceChangePercentage24H?.abs().toStringAsFixed(2)}',
                circulatingSupply:
                marketcoin.circulatingSupply?.toStringAsFixed(2),
                totalSupply: marketcoin.totalSupply?.toStringAsFixed(2),
                maxSupply: marketcoin.maxSupply?.toStringAsFixed(2),
                ath: marketcoin.ath?.toStringAsFixed(2),
                atl: marketcoin.atl?.toStringAsFixed(2),
                athDate: marketcoin.athDate.toString(),
                atlDate: marketcoin.atlDate.toString(),
                marketCap: marketcoin.marketCap?.toStringAsFixed(2),
                marketChg24: marketcoin.marketCapChange24H?.toStringAsFixed(2),
                fdv: marketcoin.fullyDilutedValuation?.toStringAsFixed(2),
                volume: marketcoin.totalVolume?.toStringAsFixed(2),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != 2
                ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff252525),
                  width: 0.6,
                ),
              ),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Image.network(
                    marketcoin.image.toString(),
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width / 1.4,
                        child: Text(
                          marketcoin.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        marketcoin.symbol.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${marketcoin.currentPrice?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${marketcoin.athChangePercentage?.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: marketcoin.athChangePercentage! > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectedGainerWidget() {
    final todayListCrypto =
    (_marketController.cryptoData.value?.topGainers?.length ?? 0) > 5
        ? _marketController.cryptoData.value!.topGainers!.sublist(0, 5)
        : _marketController.cryptoData.value!.topGainers!;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3, //todayListCrypto.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final marketcoin =
        _marketController.cryptoData.value?.topGainers?[index];
        return GestureDetector(
          onTap: () {
            _chartController.updateCoinId(newCoinId: marketcoin?.id.toString());
            controller.fetchCoinDetails(marketcoin?.id.toString() ?? 'appl');
            controller
                .fetchGainerLoserDetailsCoins(marketcoin?.id.toString() ?? '');
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin?.symbol}USD".toUpperCase();

            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: true);
            Get.to(
                  () => GainerLoserCryptoDetailInfo(
                typePortfolio: 'todaylist',
                id: marketcoin?.id,
                title: marketcoin?.name,
                icon: marketcoin?.image,
                sym: marketcoin?.symbol,
                change: marketcoin?.usd24HChange,
                value: marketcoin?.usd,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != 2
                ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff252525),
                  width: 0.6,
                ),
              ),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Image.network(
                    marketcoin?.image.toString() ?? '',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width / 1.4,
                        child: Text(
                          marketcoin?.name.toString() ?? '0.0',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        marketcoin?.symbol.toString() ?? '0.0',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${marketcoin?.usd?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${marketcoin?.usd24HChange?.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: (marketcoin?.usd24HChange ?? 0) > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectedLoserWidget() {
    final todayListCrypto =
    _marketController.cryptoData.value!.topLosers!.length > 5
        ? _marketController.cryptoData.value!.topLosers!.sublist(0, 5)
        : _marketController.cryptoData.value!.topLosers!;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3, // todayListCrypto.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final marketcoin =
        _marketController.cryptoData.value!.topLosers![index];
        return GestureDetector(
          onTap: () {
            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: true);
            Get.to(
                  () => GainerLoserCryptoDetailInfo(
                typePortfolio: 'todaylist',
                id: marketcoin.id,
                title: marketcoin.name,
                icon: marketcoin.image,
                sym: marketcoin.symbol,
                change: marketcoin.usd24HChange,
                value: marketcoin.usd,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != 2
                ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff252525),
                  width: 0.6,
                ),
              ),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Image.network(
                    marketcoin.image.toString(),
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width / 1.4,
                        child: Text(
                          marketcoin.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        marketcoin.symbol.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${marketcoin.usd?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${marketcoin.usd24HChange?.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: marketcoin.usd24HChange! > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}