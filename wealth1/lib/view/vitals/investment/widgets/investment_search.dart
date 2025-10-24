import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/controller/investment/crypto/today_crypto_list/market_coin_list_controller.dart';
import 'package:wealthnx/controller/investment/overview/merge_stock_controller.dart';
import 'package:wealthnx/controller/investment/search_invest/search_investment_controller.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/coins_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_coin_today_list/crypto_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_detail_info.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stock_coin_detail_screen.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/models/investment/crypto_investment/market_coin_list_model.dart';
import 'package:wealthnx/models/investment/stock_investment/merge_stock_model.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class InvestmentSearch extends StatelessWidget {
  InvestmentSearch({super.key});

  final MarketCoinController _marketController =
      Get.find<MarketCoinController>();
  final CryptoDetailInfoController controller =
      Get.find<CryptoDetailInfoController>();
  final _chartController = Get.put(ChartController());

  final CoinsListController _controller = Get.find<CoinsListController>();

  final SearchInvestController _searchController =
      Get.put(SearchInvestController());

  final TextEditingController _searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Search'),
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
                        controller: _searchFieldController,
                        onChanged: _searchController.search,
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

            Expanded(
              child: Obx(() {
                if (_searchController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.searchQuery.value.isNotEmpty) {
                  final results = _searchController.searchResults;
                  if (results.isEmpty) {
                    return Center(
                      child: Empty(
                        title: 'No results found',
                        height: 100,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];

                      // If it's a crypto
                      if (item is MarketCoinListModel) {
                        return _buildCryptoItem(item);
                      } else {
                        // item is MergeStockModel;
                        // return _buildStockItem(item);
                        return _buildStockItem(item);
                      }
                    },
                  );
                }

                return lowerSection();
              }),
            ),
          ],
        ),
      ),
    );
  }

//--------------------------------------

  Widget lowerSection() {
    return Column(
      children: [
        SectionName(
          title: 'Crypto Lists',
          titleOnTap: 'View All',
          onTap: () {
            Get.to(() => CryptoCoinTodayList());
          },
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
              return buildCryptoList(_marketController.filteredCoins);
            }
          }),
        ),
        const SizedBox(height: 16),

        Divider(
          thickness: 0.25,
          color: Colors.white,
          height: 2,
        ),
        const SizedBox(height: 16),

        SectionName(
          title: 'Stock Lists',
          titleOnTap: 'View All',
          onTap: () {
            Get.to(() => CoinsScreen());
          },
        ),

        Expanded(
          // height: 300,
          child: Obx(() {
            if (_controller.isLoading.value && _controller.allStocks.isEmpty) {
              return buildlistShimmerEffect();
            } else if (_controller.errorMessage.isNotEmpty) {
              return Center(
                child: Empty(
                  title: 'Today\'s List',
                  height: responTextHeight(70),
                ),
              );
            } else if (_controller.filteredStocks.isEmpty) {
              return Center(
                child: Empty(
                  title: _controller.searchQuery.isEmpty
                      ? 'Today\'s List'
                      : 'No results found',
                  height: responTextHeight(70),
                ),
              );
            } else {
              return buildStockItem();
            }
          }),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCryptoItem(MarketCoinListModel coin) {
    return GestureDetector(
      onTap: () {
        _chartController.updateCoinId(newCoinId: coin.id.toString());
        controller.fetchCoinDetails(coin.id.toString());
        Get.put(ChartController()).newsList.clear();
        String coinParms = "${coin.symbol}USD".toUpperCase();
        // String coinParms = '${stock.symbol}USD'.toUpperCase();
        print(coinParms);

        Get.put(ChartController())
            .fetchNews(newsId: coinParms, cryptoNews: true);
        Get.to(() => CryptoDetailInfo(
              typePortfolio: 'search',
              id: coin.id,
              title: coin.name,
              icon: coin.image,
              sym: coin.symbol,
              change: coin.athChangePercentage,
              value: coin.currentPrice,
              high: coin.high24H.toString(),
              low: coin.low24H.toString(),
              priceChg24: coin.priceChange24H.toString(),
              priceChgPer: coin.priceChangePercentage24H.toString(),
              circulatingSupply: coin.circulatingSupply.toString(),
              totalSupply: coin.totalSupply.toString(),
              maxSupply: coin.maxSupply.toString(),
              ath: coin.ath.toString(),
              atl: coin.atl.toString(),
              athDate: coin.athDate.toString(),
              atlDate: coin.atlDate.toString(),
              marketCap: coin.marketCap.toString(),
              marketChg24: coin.marketCapChange24H.toString(),
              fdv: coin.fullyDilutedValuation.toString(),
              volume: coin.totalVolume.toString(),
            ));
      },
      child: _buildListItem(
        iconUrl: coin.image.toString(),
        name: coin.name ?? '',
        symbol: coin.symbol ?? '',
        price: coin.currentPrice ?? 0,
        change: coin.athChangePercentage ?? 0,
      ),
    );
  }

  // Widget _buildStockItem(MergeStockModel stock) {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.put(ChartController()).newsList.clear();
  //       String coinParms = "${stock.symbol}USD".toUpperCase();
  //       // String coinParms = '${stock.symbol}USD'.toUpperCase();
  //       print(coinParms);
  //
  //       Get.put(ChartController())
  //           .fetchNews(newsId: coinParms, cryptoNews: false);
  //       Get.to(() => StockCoinDetailScreen(
  //             typePortfolio: 'search',
  //             title: stock.name,
  //             icon: stock.imageUrl,
  //             sym: stock.symbol,
  //             change: stock.changePercentage,
  //             value: stock.price,
  //           ));
  //     },
  //     child: _buildListItem(
  //       iconUrl: stock.imageUrl.toString(),
  //       name: stock.name.toString(),
  //       symbol: stock.symbol.toString(),
  //       price: stock.price?.toDouble() ?? 0.0,
  //       change: stock.changePercentage?.toDouble() ?? 0.0,
  //     ),
  //   );
  // }

  Widget _buildListItem({
    required String iconUrl,
    required String name,
    required String symbol,
    required double price,
    required double change,
  }) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              iconUrl,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                Text(symbol,
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          ),
          Column(
            children: [
              Text('\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white)),
              Text('${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: change >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  //-----------------------------------------

  Widget buildStockItem() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels ==
            scrollNotification.metrics.maxScrollExtent) {
          if (!_controller.isFetchingMore.value && _controller.hasMoreData) {
            _controller.loadMoreData();
          }
        }
        return false;
      },
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _controller.filteredStocks.length +
            (_controller.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _controller.filteredStocks.length) {
            return buildLoadingShimmerItem();
          }
          final stock = _controller.filteredStocks[index];
          return GestureDetector(
            onTap: () {
              Get.put(ChartController()).newsList.clear();
              String coinParms = "${stock.symbol}USD".toUpperCase();
              // String coinParms = '${stock.symbol}USD'.toUpperCase();
              print(coinParms);

              Get.put(ChartController())
                  .fetchNews(newsId: coinParms, cryptoNews: true);
              Get.to(
                () => StockCoinDetailScreen(
                  typePortfolio: 'todaylist',
                  title: stock.name,
                  icon: stock.imageUrl,
                  sym: stock.symbol,
                  change: stock.changePercentage,
                  value: stock.price,
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
                      stock.imageUrl.toString(),
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
                            stock.name.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          stock.symbol.toString(),
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
                        '\$${stock.price?.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${stock.changePercentage?.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: stock.changePercentage! > 0
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
        physics: const NeverScrollableScrollPhysics(),
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
  Widget _buildStockItem(MergeStockModel stock) {
    return GestureDetector(
      onTap: () {
        Get.put(ChartController()).newsList.clear();
        final newsId = "${stock.symbol}USD".toUpperCase();
        Get.put(ChartController()).fetchNews(newsId: newsId, cryptoNews: false);

        Get.to(() => StockCoinDetailScreen(
          typePortfolio: 'search',
          title: stock.name ?? '',
          icon: stock.imageUrl,
          sym: stock.symbol ?? '',
          change: stock.changePercentage ?? 0,
          value: stock.price ?? 0,
        ));
      },
      child: _buildListItem(
        iconUrl: stock.imageUrl ?? '',
        name: stock.name ?? '',
        symbol: stock.symbol ?? '',
        price: (stock.price ?? 0).toDouble(),
        change: (stock.changePercentage ?? 0).toDouble(),
      ),
    );
  }

}
