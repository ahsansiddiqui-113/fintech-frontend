import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:k_chart_plus_deeping/entity/k_line_entity.dart';
import 'package:wealthnx/models/investment/stock_investment/stock_live_data_model.dart';
import 'package:wealthnx/models/investment/stock_investment/stock_profile_model.dart';

// class StockCoinDetailController extends GetxController {
//   var isLoading = true.obs;
//   var companyProfile = Rx<CompanyProfileModel?>(null);
//   var historicalData = Rx<CoinDetailModel?>(null);
//   var error = RxString('');
//
//   // Chart-related variables
//   var chartData = <KLineEntity>[].obs;
//   final RxString selectedTab = '1 D'.obs;
//   final RxString symbol = ''.obs;
//   var selectedCandle = Rxn<KLineEntity>();
//
//   Timer? _refreshTimer;
//   final String? initialSymbol;
//
//   StockCoinDetailController(this.initialSymbol);
//
//   @override
//   void onInit() {
//     super.onInit();
//     symbol.value = initialSymbol ?? '';
//     fetchCompanyProfile();
//     fetchHistoricalData();
//
//     _refreshTimer = Timer.periodic(
//         const Duration(seconds: 20), (_) => fetchHistoricalData());
//   }
//
//   Future<void> fetchCompanyProfile() async {
//     try {
//       isLoading(true);
//       final url =
//           'https://financialmodelingprep.com/api/v3/profile/${symbol.value}?apikey=uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g';
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//         final profiles =
//             jsonList.map((json) => CompanyProfileModel.fromJson(json)).toList();
//         companyProfile.value = profiles.isNotEmpty ? profiles.first : null;
//       } else {
//         error.value = 'Error: ${response.statusCode}';
//       }
//     } catch (e) {
//       error.value = 'Error: $e';
//     }
//   }
//
//   Future<void> fetchHistoricalData() async {
//     try {
//       isLoading(true);
//       final today = DateTime.now();
//       DateTime fromDate;
//
//       switch (selectedTab.value) {
//         case '1 D':
//           fromDate = today.subtract(const Duration(days: 1));
//           break;
//         case '7 D':
//           fromDate = today.subtract(const Duration(days: 7));
//           break;
//         case '1 M':
//           fromDate = today.subtract(const Duration(days: 30));
//           break;
//         case '6 M':
//           fromDate = today.subtract(const Duration(days: 180));
//           break;
//         case '1 Y':
//           fromDate = today.subtract(const Duration(days: 365));
//           break;
//         case 'YTD':
//           fromDate = DateTime(today.year, 1, 1); // Jan 1st of current year
//           break;
//         default:
//           fromDate = today.subtract(const Duration(days: 30));
//       }
//
//       final formattedFrom = DateFormat('yyyy-MM-dd').format(fromDate);
//       final formattedTo = DateFormat('yyyy-MM-dd').format(today);
//
//       print("To Date: ${formattedTo}");
//       print("From Date: ${formattedFrom}");
//
//       final url =
//           'https://financialmodelingprep.com/api/v3/historical-price-full/${symbol.value}?from=$formattedTo&to=$formattedFrom&apikey=uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g';
//       final response = await http.get(Uri.parse(url));
//
//       print("Chart Stock 123");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         historicalData.value = CoinDetailModel.fromJson(data);
//
//         // Convert to KLineEntity format
//         if (historicalData.value?.historical != null) {
//           final List<KLineEntity> kLineData =
//               historicalData.value!.historical!.map((item) {
//             return KLineEntity.fromCustom(
//               open: item.open ?? 0,
//               high: item.high ?? 0,
//               low: item.low ?? 0,
//               close: item.close ?? 0,
//               vol: item.volume?.toDouble() ?? 0,
//               time: item.date?.millisecondsSinceEpoch ?? 0,
//             );
//           }).toList()
//                 ..sort((a, b) => a.time!.compareTo(b.time!));
//
//           chartData.value = kLineData;
//         }
//       } else {
//         error.value = 'Error fetching historical data: ${response.statusCode}';
//       }
//     } catch (e) {
//       error.value = 'Exception while fetching historical data: $e';
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   void selectCandle(KLineEntity candle) {
//     selectedCandle.value = candle;
//   }
//
//   void changeTab(String tab) {
//     selectedTab.value = tab;
//     fetchHistoricalData();
//   }
//
//   Widget buildTab(String title) {
//     final isSelected = selectedTab.value == title;
//     return GestureDetector(
//       onTap: () => changeTab(title),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF313131) : Colors.transparent,
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF313131) : Colors.transparent,
//             width: 0.25,
//           ),
//         ),
//         child: title == 'Li'
//             ? Icon(Icons.legend_toggle_outlined, size: 16)
//             : title == 'Can'
//                 ? Icon(Icons.candlestick_chart, size: 16)
//                 : Text(
//                     title,
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.grey,
//                       fontSize: 12,
//                       fontWeight:
//                           isSelected ? FontWeight.w400 : FontWeight.normal,
//                     ),
//                   ),
//       ),
//     );
//   }
//
//   @override
//   void onClose() {
//     _refreshTimer?.cancel();
//     super.onClose();
//   }
// }

enum ChartMode { line, candle }

class StockCoinDetailController extends GetxController {
  var isLoading = true.obs;
  var companyProfile = Rx<CompanyProfileModel?>(null);
  var historicalData = Rx<CoinDetailModel?>(null);
  var error = RxString('');

  var chartData = <KLineEntity>[].obs;

  /// NEW: separate states
  final RxString timeRange = '1 D'.obs;
  final Rx<ChartMode> chartMode = ChartMode.candle.obs;

  final RxString symbol = ''.obs;
  var selectedCandle = Rxn<KLineEntity>();

  Timer? _refreshTimer;
  final String? initialSymbol;

  StockCoinDetailController(this.initialSymbol);

  @override
  void onInit() {
    super.onInit();
    symbol.value = initialSymbol ?? '';
    fetchCompanyProfile();
    fetchHistoricalData();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
          (_) => fetchHistoricalData(),
    );
  }

  Future<void> fetchCompanyProfile() async {
    try {
      isLoading(true);
      final url =
          'https://financialmodelingprep.com/api/v3/profile/${symbol.value}?apikey=uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final profiles =
        jsonList.map((json) => CompanyProfileModel.fromJson(json)).toList();
        companyProfile.value = profiles.isNotEmpty ? profiles.first : null;
      } else {
        error.value = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Error: $e';
    }
  }

  Future<void> fetchHistoricalData() async {
    try {
      isLoading(true);
      final today = DateTime.now();
      DateTime fromDate;

      switch (timeRange.value) {
        case '1 D':
          fromDate = today.subtract(const Duration(days: 1));
          break;
        case '7 D':
          fromDate = today.subtract(const Duration(days: 7));
          break;
        case '1 M':
          fromDate = today.subtract(const Duration(days: 30));
          break;
        case '6 M':
          fromDate = today.subtract(const Duration(days: 180));
          break;
        case '1 Y':
          fromDate = today.subtract(const Duration(days: 365));
          break;
        case 'YTD':
          fromDate = DateTime(today.year, 1, 1);
          break;
        default:
          fromDate = today.subtract(const Duration(days: 30));
      }

      final formattedFrom = DateFormat('yyyy-MM-dd').format(fromDate);
      final formattedTo = DateFormat('yyyy-MM-dd').format(today);

      // FYI: you had from/to reversed earlier
      final url =
          'https://financialmodelingprep.com/api/v3/historical-price-full/${symbol.value}?from=$formattedFrom&to=$formattedTo&apikey=uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        historicalData.value = CoinDetailModel.fromJson(data);

        if (historicalData.value?.historical != null) {
          final List<KLineEntity> kLineData =
          historicalData.value!.historical!.map((item) {
            // Ensure date parsing to epoch (if your model doesn’t already)
            final dt = item.date;
            final millis = (dt is DateTime)
                ? dt.millisecondsSinceEpoch
                : DateTime.parse(dt.toString()).millisecondsSinceEpoch;

            return KLineEntity.fromCustom(
              open: item.open ?? 0,
              high: item.high ?? 0,
              low: item.low ?? 0,
              close: item.close ?? 0,
              vol: item.volume?.toDouble() ?? 0,
              time: millis,
            );
          }).toList()
            ..sort((a, b) => a.time!.compareTo(b.time!));

          chartData.value = kLineData;
        }
      } else {
        error.value = 'Error fetching historical data: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Exception while fetching historical data: $e';
    } finally {
      isLoading(false);
    }
  }

  void selectCandle(KLineEntity candle) => selectedCandle.value = candle;

  // NEW: handlers
  void changeTimeRange(String range) {
    timeRange.value = range;
    fetchHistoricalData();
  }

  void changeChartMode(ChartMode mode) {
    chartMode.value = mode;
    // Optionally re-fetch if your backend returns different sampling for line vs candle
    // fetchHistoricalData();
  }

  // Tabs
  Widget buildTimeTab(String title) {
    final isSelected = timeRange.value == title;
    return GestureDetector(
      onTap: () => changeTimeRange(title),
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
    final icon = mode == ChartMode.line
        ? Icons.legend_toggle_outlined
        : Icons.candlestick_chart;

    return GestureDetector(
      onTap: () => changeChartMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF313131) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? const Color(0xFF313131) : Colors.transparent,
            width: 0.25,
          ),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
      ),
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
