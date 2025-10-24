import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/controller/investment/overview/merge_stock_controller.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stock_coin_detail_screen.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';

class StockCoinTodayList extends StatelessWidget {
  StockCoinTodayList({super.key, this.filterTag});

  String? filterTag;

  final CoinsListController _controller = Get.find<CoinsListController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation tabs - Only show when not in overview mode
        if (filterTag != 'overview') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _controller.buildTab('Trending'),
              _controller.buildTab('Gainers'),
              _controller.buildTab('Losers'),
              _controller.buildTab('All'),
            ],
          ),
          SizedBox(height: 16),
        ],

        SizedBox(
          child: Obx(() {
            // Special handling for overview case - use separate trending list
            if (filterTag == 'overview') {
              if (_controller.isLoadingTrending.value && _controller.trendingTop3Stocks.isEmpty) {
                return buildlistShimmerEffect();
              } else if (_controller.trendingTop3Stocks.isEmpty) {
                return Center(
                  child: Empty(
                    title: 'Trending Stocks',
                    height: responTextHeight(70),
                  ),
                );
              } else {
                return buildTop3TrendingList();
              }
            }

            // Normal handling for non-overview cases
            if (_controller.isLoading.value && _controller.allStocks.isEmpty) {
              return buildlistShimmerEffect();
            } else if (_controller.errorMessage.isNotEmpty) {
              return Center(
                child: Empty(
                  title: 'Today\'s List',
                  height: responTextHeight(70),
                ),
              );
            } else if (_controller.allStocks.isEmpty) {
              return Center(
                child: Empty(
                  title: 'Today\'s List',
                  height: responTextHeight(70),
                ),
              );
            } else {
              if (_controller.selectedTab.value == 'All') {
                return buildStockItem();
              } else if (_controller.selectedTab.value == 'Trending') {
                return buildStockItem();
              } else if (_controller.selectedTab.value == 'Gainers') {
                return buildStockItem();
              } else if (_controller.selectedTab.value == 'Losers') {
                return buildStockItem();
              }
              return Container();
            }
          }),
        ),
      ],
    );
  }

  // Build top 3 trending list for overview using the separate trendingTop3Stocks list
  Widget buildTop3TrendingList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _controller.trendingTop3Stocks.length,
      padding: EdgeInsets.all(0),
      itemBuilder: (context, index) {
        final stock = _controller.trendingTop3Stocks[index];
        return GestureDetector(
          onTap: () {
            print("Stock news");
            Get.put(ChartController()).newsList.clear();
            String coinParms = "${stock.symbol}".toUpperCase();
            print(coinParms);

            Get.put(ChartController())
                .fetchNews(newsId: coinParms, cryptoNews: false);
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
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: index != _controller.trendingTop3Stocks.length - 1
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
                    stock.imageUrl.toString(),
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
                          stock.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
    );
  }

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
        shrinkWrap: true,
        itemCount: 3,
        padding: EdgeInsets.all(0),
        /* _controller.allStocks.length + (_controller.hasMoreData ? 1 : 0),*/
        itemBuilder: (context, index) {
          if (index >= _controller.allStocks.length) {
            // Show small shimmer effect at the bottom when loading more
            return buildLoadingShimmerItem();
          }
          final stock = _controller.allStocks[index];
          return GestureDetector(
            onTap: () {
              print("Stock news");
              Get.put(ChartController()).newsList.clear();
              String coinParms = "${stock.symbol}".toUpperCase();
              // String coinParms = '${stock.symbol}USD'.toUpperCase();
              print(coinParms);

              Get.put(ChartController())
                  .fetchNews(newsId: coinParms, cryptoNews: false);
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
              // color: Colors.transparent,
              // margin: const EdgeInsets.symmetric(vertical: 8),
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
                      stock.imageUrl.toString(),
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
}