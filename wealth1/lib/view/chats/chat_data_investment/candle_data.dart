import 'package:flutter/material.dart';
import 'package:k_chart_plus_deeping/chart_style.dart';
import 'package:k_chart_plus_deeping/entity/k_line_entity.dart';
import 'package:k_chart_plus_deeping/k_chart_widget.dart';
import 'package:wealthnx/models/investment/candle_chart_model.dart';

// class CandleData {
//   final DateTime dateTime;
//   final double open;
//   final double high;
//   final double low;
//   final double close;

//   CandleData({
//     required this.dateTime,
//     required this.open,
//     required this.high,
//     required this.low,
//     required this.close,
//   });
// }

List<KLineEntity> convertToKLineEntity(
    Map<String, TimeSeries5Min> timeSeriesMap) {
  return timeSeriesMap.entries.map((entry) {
    final dateTime = DateTime.parse(entry.key);
    final item = entry.value;

    return KLineEntity.fromCustom(
      open: double.tryParse(item.the1Open ?? '0') ?? 0,
      high: double.tryParse(item.the2High ?? '0') ?? 0,
      low: double.tryParse(item.the3Low ?? '0') ?? 0,
      close: double.tryParse(item.the4Close ?? '0') ?? 0,
      vol: double.tryParse(item.the5Volume ?? '0') ?? 0,
      time: dateTime.millisecondsSinceEpoch,
    );
  }).toList()
    ..sort((a, b) => a.time!.compareTo(b.time!.toInt()));
}

class CryptoCandleChart extends StatelessWidget {
  final List<KLineEntity> data;

  const CryptoCandleChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return KChartWidget(
      data,
      ChartStyle(),
      ChartColors(bgColor: Colors.transparent, gridColor: Colors.transparent),

      isLine: false, // false = candlestick, true = line chart
      // mainState: MainState.mA, // display MA line
      // secondaryStateLi: {SecondaryState.mACD}, // display MACD
      isTrendLine: true,
      volHidden: false,
      isTapShowInfoDialog: true,
    );
  }
}
