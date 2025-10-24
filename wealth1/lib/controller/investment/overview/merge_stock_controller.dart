import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/models/investment/stock_investment/merge_stock_model.dart';

class CoinsListController extends GetxController {
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<MergeStockModel> allStocks = <MergeStockModel>[].obs;
  final RxList<MergeStockModel> filteredStocks = <MergeStockModel>[].obs;

  // NEW: Separate list for top 3 trending stocks (for overview)
  final RxList<MergeStockModel> trendingTop3Stocks = <MergeStockModel>[].obs;
  final RxBool isLoadingTrending = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;

  final Set<String> loadedSymbols = <String>{};
  bool hasMoreData = true;
  int currentPage = 0;
  final int itemsPerPage = 30;

  final RxString selectedTab = 'Trending'.obs;

  // NEW: centralize api key & base
  static const String _apiKey = 'uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g';
  static const String _baseV3 = 'https://financialmodelingprep.com/api/v3';
  static const String _baseStable = 'https://financialmodelingprep.com/stable';

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce<String>(searchQuery, (_) => _handleSearchOrReset(),
        time: const Duration(milliseconds: 400));

    fetchStockData();
    // NEW: Also fetch top 3 trending stocks separately
    fetchTop3TrendingStocks();
  }

  // NEW: Method to fetch top 3 trending stocks specifically for overview
  Future<void> fetchTop3TrendingStocks() async {
    try {
      isLoadingTrending(true);
      trendingTop3Stocks.clear();

      // Fetch from most-actives endpoint (trending)
      final url = '$_baseStable/most-actives?apikey=$_apiKey';
      final stockListRes = await http.get(Uri.parse(url));

      if (stockListRes.statusCode != 200) {
        print('Failed to load trending stocks: ${stockListRes.statusCode}');
        return;
      }

      final List<dynamic> stockList = json.decode(stockListRes.body);
      final List<MergeStockModel> trendingData = [];

      // Get only top 3
      final top3 = stockList.take(3).toList();

      for (var stock in top3) {
        final symbol = stock['symbol'];
        if (symbol == null) continue;

        final name = stock['name'] ?? stock['companyName'];
        final price = (stock['price'] ?? 0).toDouble();

        // Fetch profile for each stock
        final profileRes = await http.get(
            Uri.parse('$_baseStable/profile?symbol=$symbol&apikey=$_apiKey'));

        if (profileRes.statusCode == 200) {
          final profileList = json.decode(profileRes.body);
          if (profileList is List && profileList.isNotEmpty) {
            final profile = profileList.first;

            trendingData.add(MergeStockModel(
              symbol: symbol,
              name: name,
              price: price,
              imageUrl: profile['image'],
              changePercentage: (profile['changePercentage'] ??
                  profile['changesPercentage'] ??
                  0.0) *
                  1.0,
            ));
          }
        }

        await Future.delayed(const Duration(milliseconds: 150));
      }

      trendingTop3Stocks.assignAll(trendingData);
    } catch (e) {
      print('Error fetching top 3 trending stocks: $e');
    } finally {
      isLoadingTrending(false);
    }
  }

  Future<void> _handleSearchOrReset() async {
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      errorMessage('');
      filteredStocks.assignAll(allStocks);
      isSearching(false);
      return;
    }
    await searchBoth(q);
  }

  void filterStocks() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredStocks.assignAll(allStocks);
    } else {
      filteredStocks.assignAll(allStocks.where((stock) =>
      (stock.name ?? '').toLowerCase().contains(q) ||
          (stock.symbol ?? '').toLowerCase().contains(q)));
    }
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    searchController.clear();
    // If user is actively searching, keep search result view
    if (searchQuery.value.trim().isEmpty) {
      fetchStockData();
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

  Future<void> fetchStockData() async {
    try {
      isLoading(true);
      errorMessage('');
      loadedSymbols.clear();
      allStocks.clear();
      currentPage = 0;
      hasMoreData = true;

      final mergedData = await getMergedStockData();
      allStocks.assignAll(mergedData);

      // If no active query, show the loaded list
      if (searchQuery.value.trim().isEmpty) {
        filteredStocks.assignAll(mergedData);
      } else {
        // If user typed during load, keep search view
        await _handleSearchOrReset();
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load stock data');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMoreData() async {
    if (isFetchingMore.value || !hasMoreData) return;

    try {
      isFetchingMore(true);
      currentPage++;

      final moreData = await getMergedStockData();
      if (moreData.isEmpty) {
        hasMoreData = false;
      } else {
        allStocks.addAll(moreData);
        // Only append to visible list when not searching
        if (searchQuery.value.trim().isEmpty) {
          filterStocks();
        }
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load more stock data');
    } finally {
      isFetchingMore(false);
    }
  }

  Future<List<MergeStockModel>> getMergedStockData() async {
    final List<MergeStockModel> mergedData = [];
    int attempts = 0;
    int neededItems = itemsPerPage;

    while (mergedData.length < neededItems && attempts < 3) {
      try {
        String url = '$_baseStable/company-screener?&apikey=$_apiKey';

        if (selectedTab.value == 'All') {
          url = '$_baseStable/company-screener?&apikey=$_apiKey';
        } else if (selectedTab.value == 'Trending') {
          url = '$_baseStable/most-actives?apikey=$_apiKey';
        } else if (selectedTab.value == 'Gainers') {
          url = '$_baseStable/biggest-gainers?apikey=$_apiKey';
        } else if (selectedTab.value == 'Losers') {
          url = '$_baseStable/biggest-losers?apikey=$_apiKey';
        }

        final stockListRes = await http.get(Uri.parse(url));
        if (stockListRes.statusCode != 200) {
          errorMessage.value = 'Failed to load stocks: ${stockListRes.statusCode}';
        }

        final List<dynamic> stockList = json.decode(stockListRes.body);

        for (var stock in stockList) {
          if (mergedData.length >= neededItems) break;

          final symbol = stock['symbol'];
          if (symbol == null || loadedSymbols.contains(symbol)) continue;

          final name = stock['name'] ?? stock['companyName'];
          final price = (stock['price'] ?? 0).toDouble();

          final profileRes = await http.get(
              Uri.parse('$_baseStable/profile?symbol=$symbol&apikey=$_apiKey'));

          if (profileRes.statusCode == 200) {
            final profileList = json.decode(profileRes.body);
            if (profileList is List && profileList.isNotEmpty) {
              final profile = profileList.first;

              mergedData.add(MergeStockModel(
                symbol: symbol,
                name: name,
                price: price,
                imageUrl: profile['image'],
                changePercentage: (profile['changePercentage'] ??
                    profile['changesPercentage'] ??
                    0.0) *
                    1.0,
              ));

              loadedSymbols.add(symbol);
            }
          }

          await Future.delayed(const Duration(milliseconds: 150));
        }

        if (mergedData.length < neededItems) {
          attempts++;
          neededItems = neededItems - mergedData.length;
        }
      } catch (e) {
        errorMessage(e.toString());
        attempts++;
      }
    }

    if (mergedData.isEmpty) {
      hasMoreData = false;
    }

    return mergedData;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchBoth(String raw) async {
    final q = raw.trim();
    if (q.isEmpty) {
      filteredStocks.assignAll(allStocks);
      errorMessage('');
      return;
    }

    isSearching(true);
    errorMessage('');

    try {
      final ranked = await _searchAndRank(q);
      if (ranked.isEmpty) {
        filteredStocks.clear();
        errorMessage('No results for "$q"');
        return;
      }
      final top = ranked.take(10).toList();
      final detailed = <MergeStockModel>[];
      for (final r in top) {
        final prof = await _fetchProfile(r['symbol'] as String);
        if (prof != null) detailed.add(prof);
        await Future.delayed(const Duration(milliseconds: 120)); // be gentle
      }
      if (detailed.isEmpty) {
        filteredStocks.assignAll(top.map((r) => MergeStockModel(
          symbol: r['symbol'] as String?,
          name: r['name'] as String?,
          price: (r['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: r['image'] as String?,
          changePercentage: 0.0,
        )));
      } else {
        filteredStocks.assignAll(detailed);
      }
    } catch (e) {
      errorMessage(e.toString());
      filteredStocks.clear();
    } finally {
      isSearching(false);
    }
  }

  Future<List<Map<String, dynamic>>> _searchAndRank(String q) async {
    final isLikelySymbol = _looksLikeSymbol(q);
    final query = q.toUpperCase();

    final symbolUri = Uri.parse('$_baseStable/search-symbol?query=$query&limit=50&apikey=$_apiKey');
    final nameUri   = Uri.parse('$_baseStable/search-name?query=$query&limit=50&apikey=$_apiKey');

    final futures = <Future<http.Response>>[
      http.get(symbolUri),
      http.get(nameUri),
    ];

    final responses = await Future.wait(futures);
    final List<dynamic> symList = (responses[0].statusCode == 200)
        ? (json.decode(responses[0].body) as List<dynamic>)
        : const [];
    final List<dynamic> nameList = (responses[1].statusCode == 200)
        ? (json.decode(responses[1].body) as List<dynamic>)
        : const [];

    final Map<String, Map<String, dynamic>> bySymbol = {};

    void addAll(List<dynamic> src) {
      for (final row in src) {
        final symbol = (row['symbol'] ?? '').toString();
        if (symbol.isEmpty) continue;
        bySymbol.putIfAbsent(symbol, () {
          return {
            'symbol': symbol,
            'name': (row['name'] ?? row['companyName'] ?? '').toString(),
            'exchange': (row['exchangeShortName'] ?? row['exchange'] ?? '').toString(),
            'price': (row['price'] is num) ? (row['price'] as num).toDouble() : 0.0,
            'image': row['image'],
          };
        });
      }
    }

    addAll(symList);
    addAll(nameList);

    int scoreRow(Map<String, dynamic> r) {
      final s = (r['symbol'] ?? '').toString().toUpperCase();
      final n = (r['name'] ?? '').toString().toUpperCase();
      final exch = (r['exchange'] ?? '').toString().toUpperCase();

      int score = 0;

      // Symbol-oriented boosts
      if (s == query) score += 100;
      else if (s.startsWith(query)) score += 85;
      else if (s.contains(query)) score += 70;

      if (n == query) score += 80;
      else if (n.startsWith(query)) score += 65;
      else if (n.contains(query)) score += 50;

      if (exch == 'NASDAQ' || exch == 'NYSE' || exch == 'AMEX') score += 10;

      if (isLikelySymbol && s.contains(query)) score += 10;

      return score;
    }
    final ranked = bySymbol.values.toList()
      ..sort((a, b) => scoreRow(b).compareTo(scoreRow(a)));

    return ranked;
  }

  bool _looksLikeSymbol(String q) {
    final t = q.trim().toUpperCase();
    if (t.isEmpty) return false;
    final symbolish = RegExp(r'^[A-Z.\-]{1,8}$');
    return symbolish.hasMatch(t);
  }

  Future<MergeStockModel?> _fetchProfile(String symbol) async {
    final uri = Uri.parse('$_baseV3/profile/$symbol?apikey=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final data = json.decode(res.body);
    if (data is! List || data.isEmpty) return null;

    final p = data.first as Map<String, dynamic>;
    return MergeStockModel(
      symbol: (p['symbol'] ?? symbol).toString(),
      name: (p['companyName'] ?? p['name'] ?? symbol).toString(),
      price: (p['price'] is num) ? (p['price'] as num).toDouble() : 0.0,
      imageUrl: p['image'],
      changePercentage:
      ((p['changesPercentage'] ?? p['changePercentage'] ?? 0.0) as num).toDouble(),
    );
  }
}