import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wealthnx/models/investment/crypto_investment/crypto_coin_details_info_model.dart';
import 'package:wealthnx/models/investment/crypto_investment/market_coin_list_model.dart';

class CryptoDetailInfoController extends GetxController {
  final Rx<CryptoCoinDetailsInfoModel?> coinDetails =
  Rx<CryptoCoinDetailsInfoModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  var errorMessage = ''.obs;

  var marketCoinList = <MarketCoinListModel>[].obs;

  @override
  void onInit() {
    // fetchCoinDetails('bitcoin');
    super.onInit();
  }

  Future<void> fetchCoinDetails(String coinId) async {
    try {
      isLoading.value = true;
      error.value = '';

      const apiKey = "CG-WA6uPbtYUPRqcRZNpcdw9AZ7";
      final url = Uri.parse(
        'https://pro-api.coingecko.com/api/v3/coins/$coinId?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false',
      );

      final response = await http.get(
        url,
        headers: {
          'x-cg-pro-api-key': apiKey,
        },
      );
      print("Coin Data : ${url}");
      print("Coin Data Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        coinDetails.value = CryptoCoinDetailsInfoModel.fromJson(jsonData);
      } else {
        error.value = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Error fetching coin details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGainerLoserDetailsCoins(String coinId) async {
    String url =
        'https://pro-api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$coinId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-cg-pro-api-key': 'CG-WA6uPbtYUPRqcRZNpcdw9AZ7',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      handleSuccessfulResponse(response);
    } else {
      print("Gainer Data : ${response.statusCode}");
    }
  }

  void handleSuccessfulResponse(http.Response response) {
    List<dynamic> jsonResponse = json.decode(response.body);

    updateCoinList(jsonResponse);
  }

  void updateCoinList(List<dynamic> jsonResponse) {
    final newCoins =
    jsonResponse.map((coin) => MarketCoinListModel.fromJson(coin)).toList();

    marketCoinList.assignAll(newCoins);
  }
}
