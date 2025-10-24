import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/controller/investment/overview/merge_stock_controller.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stock_coin_detail_screen.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class CoinsScreen extends StatelessWidget {
  CoinsScreen({super.key});

  final CoinsListController _controller = Get.find<CoinsListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
        title: 'Stock Today\'s list',
        onBackPressed: () {
          if (_controller.searchQuery.value != '') {
            _controller.searchController.clear();
            _controller.searchQuery.value = '';
          }

          Get.back();
        },
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 0.5),
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
                            onPressed: () {},
                          ),
                        ),
                        onChanged: (value) {
                          _controller.searchQuery.value = value;
                        },
                        controller: _controller.searchController,
                      ),
                    ),
                    if (_controller.searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _controller.searchController.clear();
                          _controller.searchQuery.value = '';
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _controller.buildTab('Trending'),
                  _controller.buildTab('Gainers'),
                  _controller.buildTab('Losers'),
                  _controller.buildTab('All'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content based on selected tab and search query
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value &&
                    _controller.allStocks.isEmpty) {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Empty(
                          title: _controller.searchQuery.isEmpty
                              ? 'Today\'s List'
                              : 'No results found',
                          height: responTextHeight(70),
                        ),
                        if (_controller.searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _controller.searchController.clear();
                              _controller.searchQuery.value = '';
                            },
                            child: const Text(
                              'Clear search',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return buildStockItem();
                }
              }),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
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
        physics: const AlwaysScrollableScrollPhysics(),
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
}
