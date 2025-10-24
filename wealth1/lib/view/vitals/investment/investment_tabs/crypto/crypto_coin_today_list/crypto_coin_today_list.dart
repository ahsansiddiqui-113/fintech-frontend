import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/controller/investment/crypto/today_crypto_list/market_coin_list_controller.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_detail_info.dart';
import 'package:wealthnx/models/investment/crypto_investment/market_coin_list_model.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';

class CryptoCoinTodayList extends StatelessWidget {
  CryptoCoinTodayList({super.key});

  final MarketCoinController _marketController =
      Get.find<MarketCoinController>();
  final CryptoDetailInfoController controller =
      Get.find<CryptoDetailInfoController>();
  final _chartController = Get.put(ChartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Crypto Today\'s list',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (_marketController.searchQuery.value != '') {
              _marketController.searchController.clear();
              _marketController.searchQuery.value = '';
              _marketController.filterCoins();
              _marketController.fetchMarketCoins();
            }

            Get.back();
          },
        ),
        actions: const [SizedBox(), SizedBox()],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _marketController.searchController,
                        onChanged: (value) {
                          _marketController.searchQuery.value = value;
                          _marketController.filterCoins();
                          _marketController.fetchMarketCoins();
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(46, 173, 165, 1),
                            ),
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // Search functionality will be handled via controller
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _marketController.buildTab('Trending'),
                  _marketController.buildTab('Gainers'),
                  _marketController.buildTab('Losers'),
                  _marketController.buildTab('New'),
                  _marketController.buildTab('All'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: Obx(() {
                if (_marketController.isLoading.value &&
                    _marketController.marketCoinList.isEmpty) {
                  return buildlistShimmerEffect();
                } else if (_marketController.errorMessage.isNotEmpty) {
                  return Center(
                      child: Empty(
                    title: 'Empty List',
                    height: responTextHeight(70),
                  ));
                } else if (_marketController.filteredCoins.isEmpty &&
                    _marketController.searchQuery.isNotEmpty) {
                  return Center(
                      child: Empty(
                    title: 'results found',
                    height: responTextHeight(70),
                  ));
                } else if (_marketController.filteredCoins.isEmpty) {
                  return Center(
                      child: Empty(
                    title: 'Empty List',
                    height: responTextHeight(70),
                  ));
                } else {
                  if (_marketController.selectedTab.value == 'All') {
                    return buildCryptoList(_marketController.filteredCoins);
                  } else if (_marketController.selectedTab.value ==
                      'Trending') {
                    return buildCryptoList(_marketController.filteredCoins);
                  } else if (_marketController.selectedTab.value == 'New') {
                    return buildCryptoList(_marketController.filteredCoins);
                  } else if (_marketController.selectedTab.value == 'Gainers') {
                    return selectedGainerWidget();
                  } else if (_marketController.selectedTab.value == 'Losers') {
                    return selectedLoserWidget();
                  }
                  return Container();
                }
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildCryptoList(List<MarketCoinListModel> coins) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels ==
            scrollNotification.metrics.maxScrollExtent) {
          if (!_marketController.isFetchingMore.value &&
              _marketController.hasMoreData.value &&
              _marketController.searchQuery.isEmpty) {
            _marketController.loadMoreData();
          }
        }
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: coins.length +
            (_marketController.hasMoreData.value &&
                    _marketController.searchQuery.isEmpty
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (index >= coins.length) {
            return buildLoadingShimmerItem();
          }

          final marketcoin = coins[index];
          return buildCryptoItem(marketcoin);
        },
      ),
    );
  }

  Widget buildCryptoItem(MarketCoinListModel marketcoin) {
    return GestureDetector(
      onTap: () {
        _chartController.updateCoinId(newCoinId: marketcoin.id.toString());

        controller.fetchCoinDetails(marketcoin.id.toString());
        Get.put(ChartController()).newsList.clear();
        String coinParms = "${marketcoin.symbol}USD".toUpperCase();
        // String coinParms = '${stock.symbol}USD'.toUpperCase();
        print(marketcoin.symbol);
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
            high: marketcoin.high24H.toString(),
            low: marketcoin.low24H.toString(),
            priceChg24: marketcoin.priceChange24H.toString(),
            priceChgPer: marketcoin.priceChangePercentage24H.toString(),
            circulatingSupply: marketcoin.circulatingSupply.toString(),
            totalSupply: marketcoin.totalSupply.toString(),
            maxSupply: marketcoin.maxSupply.toString(),
            ath: marketcoin.ath.toString(),
            atl: marketcoin.atl.toString(),
            athDate: marketcoin.athDate.toString(),
            atlDate: marketcoin.atlDate.toString(),
            marketCap: marketcoin.marketCap.toString(),
            marketChg24: marketcoin.marketCapChange24H.toString(),
            fdv: marketcoin.fullyDilutedValuation.toString(),
            volume: marketcoin.totalVolume.toString(),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8),
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
            const SizedBox(width: 8),
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
  }

  Widget selectedGainerWidget() {
    if (_marketController.cryptoData.value == null ||
        _marketController.cryptoData.value!.topGainers == null) {
      return buildlistShimmerEffect();
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: _marketController.cryptoData.value?.topGainers?.length,
      itemBuilder: (context, index) {
        final marketcoin =
            _marketController.cryptoData.value!.topGainers![index];
        return GestureDetector(
          onTap: () {
            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            // String coinParms = '${stock.symbol}USD'.toUpperCase();
            print(marketcoin.symbol);
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
                change: marketcoin.usd24HChange,
                value: marketcoin.usd,
              ),
            );
          },
          child: Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                const SizedBox(width: 8),
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

  Widget selectedLoserWidget() {
    if (_marketController.cryptoData.value == null ||
        _marketController.cryptoData.value!.topLosers == null) {
      return buildlistShimmerEffect();
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: _marketController.cryptoData.value?.topLosers?.length ?? 0,
      itemBuilder: (context, index) {
        final marketcoin =
            _marketController.cryptoData.value!.topLosers![index];
        return GestureDetector(
          onTap: () {
            _chartController.updateCoinId(newCoinId: marketcoin.id.toString());
            controller.fetchCoinDetails(marketcoin.id.toString());
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${marketcoin.symbol}USD".toUpperCase();
            // String coinParms = '${stock.symbol}USD'.toUpperCase();
            print(marketcoin.symbol);
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
                change: marketcoin.usd24HChange,
                value: marketcoin.usd,
              ),
            );
          },
          child: Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                const SizedBox(width: 8),
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
