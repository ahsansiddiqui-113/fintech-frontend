import 'package:get/get.dart';
import 'package:wealthnx/controller/investment/crypto/today_crypto_list/market_coin_list_controller.dart';
import 'package:wealthnx/controller/investment/overview/merge_stock_controller.dart';

class SearchInvestController extends GetxController {
  final MarketCoinController _cryptoController = Get.find();
  final CoinsListController _stockController = Get.find();

  final RxString searchQuery = ''.obs;
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  void search(String query) async {
    searchQuery.value = query;
    searchResults.clear();
    if (query.isEmpty) return;

    isLoading.value = true;

    await Future.wait([
      _searchCryptos(query),
      _searchStocks(query),
    ]);

    isLoading.value = false;
  }

  Future<void> _searchCryptos(String query) async {
    final results = _cryptoController.marketCoinList.where((coin) =>
        coin.name!.toLowerCase().contains(query.toLowerCase()) ||
        coin.symbol!.toLowerCase().contains(query.toLowerCase()));

    searchResults.addAll(results);
  }

  // Future<void> _searchStocks(String query) async {
  //   final results = _stockController.allStocks.where((stock) =>
  //       stock.name!.toLowerCase().contains(query.toLowerCase()) ||
  //       stock.symbol!.toLowerCase().contains(query.toLowerCase()));
  //
  //   searchResults.addAll(results);
  // }
  Future<void> _searchStocks(String query) async {
    final q = query.toLowerCase();
    final stocks = _stockController.allStocks; // RxList or List

    if (stocks.isEmpty) return;

    final results = stocks.where((s) {
      final name = s.name?.toLowerCase() ?? '';
      final sym  = s.symbol?.toLowerCase() ?? '';
      return name.contains(q) || sym.contains(q);
    }).toList();

    searchResults.addAll(results);
  }



  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }
}
