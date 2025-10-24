import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart_plus_deeping/entity/k_line_entity.dart';
import 'package:wealthnx/models/investment/crypto_investment/crypto_live_chart_model.dart';
import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
import 'package:wealthnx/services/crypto_news_services.dart';

enum ChartMode { line, candle }

class ChartController extends GetxController {
  // DATA
  final chartData = <KLineEntity>[].obs;
  final coinId = ''.obs;

  // UI STATE
  final selectedRange = '1 D'.obs;
  final dayInterval = '1'.obs;
  final chartMode = ChartMode.candle.obs;
  final selectedCandle = Rxn<KLineEntity>();

  Timer? _refreshTimer;

  static const Map<String, String> _rangeToDays = {
    '1 D': '1',
    '7 D': '7',
    '1 M': '30',
    '6 M': '180',
    '1 Y': '365',
    'YTD': 'max',
  };

  @override
  void onInit() {
    super.onInit();
    fetchChartData(interval: dayInterval.value);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => fetchChartData(interval: dayInterval.value),
    );
  }

  void selectCandle(KLineEntity candle) => selectedCandle.value = candle;

  void updateCoinId({String? newCoinId}) {
    if (newCoinId != null && coinId.value != newCoinId) {
      coinId.value = newCoinId;
      // reset range to 1D, but DO NOT touch chartMode
      selectedRange.value = '1 D';
      dayInterval.value = '1';
      fetchChartData(interval: dayInterval.value);
    }
  }

  void setRange(String rangeLabel) {
    selectedRange.value = rangeLabel;
    dayInterval.value = _rangeToDays[rangeLabel] ?? '1';
    fetchChartData(interval: dayInterval.value);
  }

  void setMode(ChartMode mode) {
    chartMode.value = mode; // no fetch needed; same OHLC data
  }

  Future<void> fetchChartData({required String interval}) async {
    if (coinId.value.isEmpty) return; // protect against empty id
    try {
      final uri = Uri.parse(
        'https://pro-api.coingecko.com/api/v3/coins/${coinId.value}/ohlc'
        '?vs_currency=usd&days=$interval',
      );

      final response = await http.get(
        uri,
        headers: {
          'x-cg-pro-api-key': 'CG-WA6uPbtYUPRqcRZNpcdw9AZ7',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        final entries = raw.map((e) => PriceEntry.fromJson(e)).toList();

        chartData.value = entries.map((entry) {
          return KLineEntity.fromCustom(
            open: entry.open ?? 0,
            high: entry.high ?? 0,
            low: entry.low ?? 0,
            close: entry.close ?? 0,
            vol: 0,
            time: entry.timestamp?.millisecondsSinceEpoch ?? 0,
          );
        }).toList()
          ..sort((a, b) => a.time!.compareTo(b.time!));
      } else {
        debugPrint('OHLC error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception while fetching chart data: $e');
    }
  }

  // ---- Tab Builders ----
  Widget buildRangeTab(String title) {
    final isSelected = selectedRange.value == title;
    return GestureDetector(
      onTap: () => setRange(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF313131) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? const Color(0xFF313131) : Colors.transparent,
            width: 0.25,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildModeTab(ChartMode mode) {
    final isSelected = chartMode.value == mode;
    final isLine = mode == ChartMode.line;
    return GestureDetector(
      onTap: () => setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF313131) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? const Color(0xFF313131) : Colors.transparent,
            width: 0.25,
          ),
        ),
        child: Icon(
          isLine ? Icons.legend_toggle_outlined : Icons.candlestick_chart,
          size: 16,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  final ApiService _apiService = ApiService();
  var newsList = <CryptoNewsModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchNews(
      {required String newsId, required bool cryptoNews}) async {
    // newsList.clear();
    try {
      isLoading(true);
      errorMessage('');
      final news =
          await _apiService.fetchNews(newsId: newsId, crypto: cryptoNews);
      newsList.assignAll(news);
    } catch (e) {
      errorMessage(e.toString());
      // Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
