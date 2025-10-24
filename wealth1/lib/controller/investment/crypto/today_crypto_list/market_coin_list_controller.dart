import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/models/investment/crypto_investment/crypto_loser_gainer_model.dart';
import 'dart:convert';
import 'package:wealthnx/models/investment/crypto_investment/market_coin_list_model.dart';

class MarketCoinController extends GetxController {
  final String apiKey = 'CG-WA6uPbtYUPRqcRZNpcdw9AZ7';

  // Search state
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<MarketCoinListModel> filteredCoins = <MarketCoinListModel>[].obs;
  final RxBool isSearching = false.obs;

  // Lists and pagination
  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;
  final RxList<MarketCoinListModel> marketCoinList = <MarketCoinListModel>[].obs;

  // NEW: Separate trending list for overview page
  final RxList<MarketCoinListModel> trendingCoinList = <MarketCoinListModel>[].obs;
  final RxBool isTrendingLoading = false.obs;

  final RxString errorMessage = ''.obs;
  final RxBool hasMoreData = true.obs;
  int currentPage = 1;
  final int itemsPerPage = 100;

  // Tabs & extra data
  final cryptoData = Rx<CryptoLoserGainer?>(null);
  final RxString selectedTab = 'Trending'.obs;

  String _lastSearchQuery = '';
  List<String> _searchIds = [];

  @override
  void onInit() {
    fetchMarketCoins();
    fetchTrendingCoinsForOverview();
    setupSearchListener();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
      filterCoins();
    });
  }

  void filterCoins() {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) {
      filteredCoins.assignAll(marketCoinList);
      isSearching.value = false;
    } else {
      isSearching.value = true;
      filteredCoins.assignAll(
        marketCoinList.where((coin) =>
        (coin.name ?? '').toLowerCase().contains(q) ||
            (coin.symbol ?? '').toLowerCase().contains(q)
        ),
      );
    }
  }

  Widget buildTab(String title) {
    return Obx(() {
      final isSelected = selectedTab.value == title;
      return GestureDetector(
        onTap: () => changeTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(46, 173, 165, 1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(46, 173, 165, 1)
                  : Colors.grey,
              width: 0.5,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Future<void> refreshData() async {
    searchController.clear();
    await Future.wait([
      fetchMarketCoins(),
      fetchTrendingCoinsForOverview(), // NEW: Refresh trending coins too
    ]);
  }

  Future<void> loadMoreData() async {
    if (shouldLoadMoreData()) {
      await fetchMarketCoins(loadNextPage: true);
    }
  }

  bool shouldLoadMoreData() {
    return !isSearching.value &&
        (selectedTab.value == 'All' ||
            selectedTab.value == 'Trending' ||
            selectedTab.value == 'New');
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    searchController.clear();

    if (selectedTab.value == 'All' ||
        selectedTab.value == 'Trending' ||
        selectedTab.value == 'New') {
      fetchMarketCoins();
    } else if (selectedTab.value == 'Gainers' ||
        selectedTab.value == 'Losers') {
      fetchTopGainerLoserCoins();
    }
  }

  // NEW: Method to fetch trending coins specifically for overview page
  Future<void> fetchTrendingCoinsForOverview() async {
    try {
      isTrendingLoading(true);

      // Fetch trending coins using CoinGecko's trending endpoint
      final response = await http.get(
        Uri.parse('https://pro-api.coingecko.com/api/v3/search/trending'),
        headers: {
          'x-cg-pro-api-key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> trendingItems = jsonResponse['coins'] ?? [];

        // Extract coin IDs from trending response
        final List<String> trendingIds = trendingItems
            .take(10) // Get top 10 trending coins
            .map((item) => item['item']['id'].toString())
            .toList();

        if (trendingIds.isNotEmpty) {
          // Fetch detailed market data for trending coins
          final marketDataResponse = await http.get(
            Uri.parse(
                'https://pro-api.coingecko.com/api/v3/coins/markets'
                    '?vs_currency=usd&ids=${trendingIds.join(',')}&sparkline=false'
            ),
            headers: {
              'x-cg-pro-api-key': apiKey,
              'Content-Type': 'application/json',
            },
          );

          if (marketDataResponse.statusCode == 200) {
            final List<dynamic> marketData = json.decode(marketDataResponse.body);
            final trendingCoins = marketData
                .map((coin) => MarketCoinListModel.fromJson(coin))
                .toList();

            trendingCoinList.assignAll(trendingCoins);
          }
        }
      }
    } catch (e) {
      print('Error fetching trending coins: $e');
      // Fallback to using regular market coins if trending API fails
      if (marketCoinList.isNotEmpty) {
        trendingCoinList.assignAll(marketCoinList.take(10));
      }
    } finally {
      isTrendingLoading(false);
    }
  }

  Future<void> fetchMarketCoins({bool loadNextPage = false}) async {
    try {
      if (loadNextPage && (!hasMoreData.value || isFetchingMore.value)) return;

      if (loadNextPage) {
        isFetchingMore(true);
        currentPage++;
      } else {
        isLoading(true);
        currentPage = 1;
        marketCoinList.clear();
        hasMoreData(true);
      }

      errorMessage('');

      final q = searchQuery.value.trim();
      if (q.isNotEmpty) {
        await _ensureSearchIds(q);

        if (_searchIds.isEmpty) {
          handleSuccessfulResponse(http.Response('[]', 200), loadNextPage);
          return;
        }

        final start = (currentPage - 1) * itemsPerPage;
        final end = (start + itemsPerPage).clamp(0, _searchIds.length);
        if (start >= _searchIds.length) {
          handleSuccessfulResponse(http.Response('[]', 200), loadNextPage);
          return;
        }

        final pageIds = _searchIds.sublist(start, end);
        final idsParam = pageIds.join(',');

        final url =
            'https://pro-api.coingecko.com/api/v3/coins/markets'
            '?vs_currency=usd&per_page=${pageIds.length}&page=1'
            '&sparkline=false&ids=$idsParam';

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'x-cg-pro-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // When searching, hasMoreData depends on how many IDs remain
          if (end >= _searchIds.length) {
            hasMoreData(false);
          }
          handleSuccessfulResponse(response, loadNextPage);
        } else {
          handleErrorResponse(response.statusCode, loadNextPage);
        }

        return;
      }

      String url =
          'https://pro-api.coingecko.com/api/v3/coins/markets'
          '?vs_currency=usd&page=$currentPage&per_page=$itemsPerPage&sparkline=false';

      if (selectedTab.value == 'All') {
        url =
        'https://pro-api.coingecko.com/api/v3/coins/markets'
            '?vs_currency=usd&page=$currentPage&per_page=$itemsPerPage&sparkline=false';
      } else if (selectedTab.value == 'Trending') {
        // When Trending tab is selected, use the trending list
        // But still fetch market data for pagination
        url =
        'https://pro-api.coingecko.com/api/v3/coins/markets'
            '?vs_currency=usd&page=$currentPage&per_page=$itemsPerPage'
            '&order=market_cap_desc&sparkline=false';

        // Also refresh trending coins when tab is selected
        if (currentPage == 1) {
          fetchTrendingCoinsForOverview();
        }
      } else if (selectedTab.value == 'New') {
        url =
        'https://pro-api.coingecko.com/api/v3/coins/markets'
            '?vs_currency=usd&page=$currentPage&per_page=$itemsPerPage'
            '&order=id_desc&sparkline=false';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-cg-pro-api-key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        handleSuccessfulResponse(response, loadNextPage);

        // Update trending list from market list if trending-specific fetch failed
        if (selectedTab.value == 'Trending' && trendingCoinList.isEmpty && marketCoinList.isNotEmpty) {
          trendingCoinList.assignAll(marketCoinList.take(10));
        }
      } else {
        handleErrorResponse(response.statusCode, loadNextPage);
      }
    } catch (e) {
      handleFetchError(e, loadNextPage);
    } finally {
      updateLoadingStates(loadNextPage);
    }
  }

  void handleSuccessfulResponse(http.Response response, bool loadNextPage) {
    final List<dynamic> jsonResponse = json.decode(response.body);

    if (jsonResponse.isEmpty) {
      hasMoreData(false);
    } else {
      updateCoinList(jsonResponse, loadNextPage);
      filterCoins();
    }
  }

  void updateCoinList(List<dynamic> jsonResponse, bool loadNextPage) {
    final newCoins = jsonResponse
        .map((coin) => MarketCoinListModel.fromJson(coin))
        .toList();

    if (loadNextPage) {
      marketCoinList.addAll(newCoins);
    } else {
      marketCoinList.assignAll(newCoins);
    }
  }

  void handleErrorResponse(int statusCode, bool loadNextPage) {
    errorMessage('Failed to load data: $statusCode');
    if (loadNextPage) currentPage--;
  }

  void handleFetchError(dynamic error, bool loadNextPage) {
    errorMessage('Error fetching data: $error');
    if (loadNextPage) currentPage--;
  }

  void updateLoadingStates(bool loadNextPage) {
    if (loadNextPage) {
      isFetchingMore(false);
    } else {
      isLoading(false);
    }
  }

  // ---------------------------
  // Gainers / Losers
  // ---------------------------
  Future<void> fetchTopGainerLoserCoins() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await http.get(
        Uri.parse(
          'https://pro-api.coingecko.com/api/v3/coins/top_gainers_losers?vs_currency=usd',
        ),
        headers: {
          'x-cg-pro-api-key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        cryptoData.value =
            CryptoLoserGainer.fromJson(json.decode(response.body));
      } else {
        errorMessage('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _ensureSearchIds(String q) async {
    if (q == _lastSearchQuery && _searchIds.isNotEmpty) return;

    _lastSearchQuery = q;
    _searchIds = await _resolveIdsByQuery(q, limit: 500);
  }

  /// Resolve CoinGecko coin IDs by free-text query (supports name or symbol).
  Future<List<String>> _resolveIdsByQuery(String raw, {int limit = 50}) async {
    final q = raw.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse('https://pro-api.coingecko.com/api/v3/search?query=$q');

    final res = await http.get(
      uri,
      headers: {
        'x-cg-pro-api-key': apiKey,
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) return [];

    final Map<String, dynamic> body = json.decode(res.body);
    final List coins = (body['coins'] as List?) ?? const [];

    int score(Map<String, dynamic> r) {
      final sym = (r['symbol'] ?? '').toString().toLowerCase();
      final name = (r['name'] ?? '').toString().toLowerCase();
      final query = q.toLowerCase();
      int s = 0;

      // Symbol-driven boosts
      if (sym == query) s += 100;
      else if (sym.startsWith(query)) s += 85;
      else if (sym.contains(query)) s += 70;

      // Name-driven boosts
      if (name == query) s += 60;
      else if (name.startsWith(query)) s += 45;
      else if (name.contains(query)) s += 30;

      final mcr = r['market_cap_rank'];
      if (mcr is int && mcr > 0) s += 5;
      if (_looksLikeSymbol(q) && sym.contains(query)) s += 5;

      return s;
    }

    final ranked = coins
        .where((e) => (e['id'] ?? '').toString().isNotEmpty)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => score(b).compareTo(score(a)));

    final ids = <String>[];
    for (final r in ranked) {
      final id = (r['id'] ?? '').toString();
      if (id.isEmpty) continue;
      if (!ids.contains(id)) ids.add(id);
      if (ids.length >= limit) break;
    }
    return ids;
  }

  bool _looksLikeSymbol(String q) {
    final t = q.trim();
    if (t.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9\-]{2,10}$').hasMatch(t);
  }
}
