import 'dart:developer' hide log;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'package:intl/intl.dart';
import 'package:wealthnx/theme/app_color.dart';

class ChartSampleData {
  final DateTime x;
  final double y;

  ChartSampleData(this.x, this.y);
}

class ExpenseChart extends StatefulWidget {
  final List<FlSpot> spots;
  final List<String> xLabels;
  final String timePeriod;
  RxDouble val;

  ExpenseChart({
    required this.spots,
    required this.xLabels,
    required this.timePeriod,
    RxDouble? val,
  }) : val = val ?? 0.0.obs;

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  double _calculateNiceNumber(double range, bool round) {
    final exponent = (log(range) / ln10).floor();
    final fraction = range / pow(10, exponent);
    double niceFraction;

    if (round) {
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else {
      if (fraction <= 1) {
        niceFraction = 1;
      } else if (fraction <= 2) {
        niceFraction = 2;
      } else if (fraction <= 5) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    }

    return niceFraction * pow(10, exponent).toDouble();
  }

  Map<String, double> _calculateYAxisBounds(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return {'minY': 0, 'maxY': 100, 'interval': 25};
    }

    final yValues = spots.map((s) => s.y).toList();
    double dataMin = yValues.reduce((a, b) => a < b ? a : b);
    double dataMax = yValues.reduce((a, b) => a > b ? a : b);

    if (dataMin == dataMax) {
      if (dataMin == 0) {
        return {'minY': 0, 'maxY': 100, 'interval': 25};
      } else if (dataMin > 0) {
        return {
          'minY': 0,
          'maxY': dataMin * 1.5,
          'interval': _calculateNiceNumber(dataMin * 1.5 / 4, true)
        };
      } else {
        return {
          'minY': dataMin * 1.5,
          'maxY': 0,
          'interval': _calculateNiceNumber(dataMin.abs() * 1.5 / 4, true)
        };
      }
    }

    double minY, maxY;
    bool allPositive = dataMin >= 0;
    bool allNegative = dataMax <= 0;

    if (allPositive) {
      minY = 0;
      final range = dataMax - dataMin;
      maxY = dataMax + (range * 0.2);
    } else if (allNegative) {
      maxY = 0;
      final range = dataMax - dataMin;
      minY = dataMin - (range * 0.2);
    } else {
      final range = dataMax - dataMin;
      minY = dataMin - (range * 0.1);
      maxY = dataMax + (range * 0.1);
    }

    final totalRange = maxY - minY;
    final roughInterval = totalRange / 4;
    final niceInterval = _calculateNiceNumber(roughInterval, true);

    minY = (minY / niceInterval).floor() * niceInterval;
    maxY = (maxY / niceInterval).ceil() * niceInterval;

    if (allPositive && minY < 0) minY = 0;
    if (allNegative && maxY > 0) maxY = 0;

    return {'minY': minY, 'maxY': maxY, 'interval': niceInterval};
  }

  @override
  Widget build(BuildContext context) {
    final limitedSpots = widget.spots.toList();
    final limitedLabels = widget.xLabels;
    String adjustedTimePeriod = widget.timePeriod;

    if (widget.timePeriod == '1 M') {
      adjustedTimePeriod = '1M';
    } else if (widget.timePeriod == '1 W' ||
        widget.timePeriod == '3 M' ||
        widget.timePeriod == '6 M' ||
        widget.timePeriod == '1 M') {
      adjustedTimePeriod = 'Monthly';
    } else if (widget.timePeriod == '1 Y') {
      adjustedTimePeriod = 'Yearly';
    } else if (widget.timePeriod == 'YTD') {
      adjustedTimePeriod = 'YTD';
    }

    final List<FlSpot> displaySpots = adjustedTimePeriod == 'Daily'
        ? List.from(widget.spots)
        : widget.spots.length >= 500
            ? widget.spots.sublist(widget.spots.length - 500)
            : widget.spots;
    final displayLabels = adjustedTimePeriod == 'Daily'
        ? List.from(widget.xLabels)
        : widget.xLabels.length >= 500
            ? widget.xLabels.sublist(widget.xLabels.length - 500)
            : widget.xLabels;

    if (widget.spots.every((spot) => spot.y == 0)) {
      return const Center(
        child: Text(
          'No expense data available',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }

    final bounds = _calculateYAxisBounds(displaySpots);
    final double minY = bounds['minY']!;
    final double maxY = bounds['maxY']!;
    final double interval = bounds['interval']!;

    return LineChart(
      LineChartData(
        baselineX: 0,
        baselineY: 0,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response == null || response.lineBarSpots == null) return;
            final spot = response.lineBarSpots!.first;
            setState(() {
              widget.val.value = spot.y;
            });
          },
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                context.gc(AppColor.black).withOpacity(0.8),
            tooltipHorizontalOffset: 12,
            showOnTopOfTheChartBoxArea: false,
            tooltipMargin: 0,
            tooltipRoundedRadius: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            getTooltipItems: (touchedSpots) {
              final formatter = NumberFormat('#,###');
              final dateInputFormat = DateFormat('dd MMM yyyy');
              final dateOutputFormat = DateFormat('MMMM d, yyyy');

              return touchedSpots.map((spot) {
                int index = spot.spotIndex;
                String rawDate =
                    index < limitedLabels.length ? limitedLabels[index] : '';
                String formattedDate = '';
                try {
                  final date = dateInputFormat.parse(rawDate);
                  formattedDate = dateOutputFormat.format(date);
                } catch (_) {
                  formattedDate = rawDate;
                }

                return LineTooltipItem(
                  '\$${formatter.format(spot.y)} \n$formattedDate',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.white, strokeWidth: 1, dashArray: [2, 2]),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: context.gc(AppColor.primary),
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            }).toList();
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= limitedLabels.length)
                  return Container();
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Transform.rotate(
                    angle: -45 * 0.0174533,
                    child: Text(
                      limitedLabels[index],
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            drawBelowEverything: false,
            sideTitles: SideTitles(
              showTitles: true,
              maxIncluded: false,
              minIncluded: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (value, meta) {
                bool isNegative = value < 0;
                double absValue = value.abs();
                String formattedValue;

                String format(double number, double divisor, String suffix) {
                  return '${(number / divisor).floor()}$suffix';
                }

                if (absValue >= 1_000_000_000_000) {
                  formattedValue = format(absValue, 1_000_000_000_000, 'T');
                } else if (absValue >= 1_000_000_000) {
                  formattedValue = format(absValue, 1_000_000_000, 'B');
                } else if (absValue >= 1_000_000) {
                  formattedValue = format(absValue, 1_000_000, 'M');
                } else if (absValue >= 1_000) {
                  formattedValue = format(absValue, 1_000, 'k');
                } else {
                  formattedValue = absValue.toInt().toString();
                }

                return Text(
                  '${isNegative ? '-\$' : '\$'}$formattedValue',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: limitedSpots,
            isCurved: false,
            barWidth: 0.5,
            gradient: LinearGradient(
              colors: [const Color(0xFF05CABE), Colors.black],
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: widget.spots.any((s) => s.x < 0)
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF05CABE), Colors.black],
              ),
            ),
            show: true,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
// class _ExpenseChartState extends State<ExpenseChart> {
//   @override
//   Widget build(BuildContext context) {
//     final limitedSpots = widget.spots.toList();
//     final limitedLabels = widget.xLabels;
//     String adjustedTimePeriod = widget.timePeriod;
//     if (widget.timePeriod == '1 M') {
//       adjustedTimePeriod = '1M';
//     } else if (widget.timePeriod == '1 W' ||
//         widget.timePeriod == '3 M' ||
//         widget.timePeriod == '6 M' ||
//         widget.timePeriod == '1 M') {
//       adjustedTimePeriod = 'Monthly';
//     } else if (widget.timePeriod == '1 Y') {
//       adjustedTimePeriod = 'Yearly';
//     } else if (widget.timePeriod == 'YTD') {
//       adjustedTimePeriod = 'YTD';
//     }
//
//     final displaySpots = adjustedTimePeriod == 'Daily'
//         ? List.from(widget.spots)
//         : widget.spots.length >= 500
//             ? widget.spots.sublist(widget.spots.length - 500)
//             : widget.spots;
//     final displayLabels = adjustedTimePeriod == 'Daily'
//         ? List.from(widget.xLabels)
//         : widget.xLabels.length >= 500
//             ? widget.xLabels.sublist(widget.xLabels.length - 500)
//             : widget.xLabels;
//
//     double minY = 0;
//     double maxY = 100;
//
//     if (displaySpots.isNotEmpty) {
//       final yValues = displaySpots.map((s) => s.y).toList();
//       minY = yValues.reduce((a, b) => a < b ? a : b);
//       maxY = yValues.reduce((a, b) => a > b ? a : b);
//       final range = maxY - minY;
//       minY = minY - (range * 0.35);
//       maxY = maxY + (range * 0.5);
//     }
//
//     if (widget.spots.every((spot) => spot.y == 0)) {
//       return const Center(
//         child: Text(
//           'No expense data available',
//           style: TextStyle(color: Colors.white, fontSize: 14),
//         ),
//       );
//     }
//
//     final double adjustedMinY = minY;
//     final double adjustedRange = maxY - adjustedMinY;
//     final double interval = adjustedRange / 3.1 <=0 ? 1 : adjustedRange / 3.1;
//     return LineChart(
//       LineChartData(
//         baselineX: 0,
//         baselineY: 0,
//         minY: adjustedMinY,
//         maxY: maxY,
//         lineTouchData: LineTouchData(
//           touchCallback: (event, response) {
//             if (response == null || response.lineBarSpots == null) return;
//             final spot = response.lineBarSpots!.first;
//             setState(() {
//               widget.val.value = spot.y;
//             });
//           },
//           handleBuiltInTouches: true,
//           touchTooltipData: LineTouchTooltipData(
//             getTooltipColor: (touchedSpot) =>
//                 context.gc(AppColor.black).withOpacity(0.8),
//             tooltipHorizontalOffset: 12,
//             showOnTopOfTheChartBoxArea: false,
//             tooltipMargin: 0,
//             tooltipRoundedRadius: 8,
//             fitInsideVertically: true,
//             fitInsideHorizontally: true,
//             tooltipHorizontalAlignment: FLHorizontalAlignment.right,
//             getTooltipItems: (touchedSpots) {
//               final formatter = NumberFormat('#,###');
//               final dateInputFormat = DateFormat('dd MMM yyyy');
//               final dateOutputFormat = DateFormat('MMMM d, yyyy');
//
//               return touchedSpots.map((spot) {
//                 int index = spot.spotIndex;
//                 String rawDate =
//                     index < limitedLabels.length ? limitedLabels[index] : '';
//                 String formattedDate = '';
//                 try {
//                   final date = dateInputFormat.parse(rawDate);
//                   formattedDate = dateOutputFormat.format(date);
//                 } catch (_) {
//                   formattedDate = rawDate;
//                 }
//
//                 return LineTooltipItem(
//                   '\$${formatter.format(spot.y)} \n$formattedDate',
//                   const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 10,
//                   ),
//                 );
//               }).toList();
//             },
//
//           ),
//           getTouchedSpotIndicator:
//               (LineChartBarData barData, List<int> spotIndexes) {
//             return spotIndexes.map((index) {
//               return TouchedSpotIndicatorData(
//                 FlLine(color: Colors.white, strokeWidth: 1, dashArray: [2, 2]),
//                 FlDotData(
//                   show: true,
//                   getDotPainter: (spot, percent, barData, index) =>
//                       FlDotCirclePainter(
//                     radius: 4,
//                     color: context.gc(AppColor.primary),
//                     strokeColor: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 ),
//               );
//             }).toList();
//           },
//         ),
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: false,
//               reservedSize: 0,
//               getTitlesWidget: (value, meta) {
//                 int index = value.toInt();
//                 if (index < 0 || index >= limitedLabels.length)
//                   return Container();
//                 return SideTitleWidget(
//                   meta: meta,
//                   space: 8,
//                   child: Transform.rotate(
//                     angle: -45 * 0.0174533,
//                     child: Text(
//                       limitedLabels[index],
//                       style: const TextStyle(fontSize: 10, color: Colors.white),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           leftTitles: AxisTitles(
//             drawBelowEverything: false,
//             sideTitles: SideTitles(
//               showTitles: true,
//               maxIncluded: false,
//               minIncluded: true,
//               reservedSize: 42,
//               interval: interval ,
//               getTitlesWidget: (value, meta) {
//                 bool isNegative = value < 0;
//                 double absValue = value.abs();
//                 String formattedValue;
//
//                 String format(double number, double divisor, String suffix) {
//                   // Integer division and no decimals
//                   return '${(number / divisor).floor()}$suffix';
//                 }
//
//                 if (absValue >= 1_000_000_000_000) {
//                   formattedValue = format(absValue, 1_000_000_000_000, 'T');
//                 } else if (absValue >= 1_000_000_000) {
//                   formattedValue = format(absValue, 1_000_000_000, 'B');
//                 } else if (absValue >= 1_000_000) {
//                   formattedValue = format(absValue, 1_000_000, 'M');
//                 } else if (absValue >= 1_000) {
//                   formattedValue = format(absValue, 1_000, 'k');
//                 } else {
//                   formattedValue = absValue.toInt().toString();
//                 }
//
//                 return Text(
//                   '${isNegative ? '-\$' : '\$'}$formattedValue',
//                   style: const TextStyle(color: Colors.white, fontSize: 10),
//                 );
//               },
//             ),
//           ),
//         ),
//         gridData: FlGridData(show: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: limitedSpots,
//             isCurved: false,
//             barWidth: 0.5,
//             gradient: LinearGradient(
//               colors: [const Color(0xFF05CABE), Colors.black],
//             ),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 begin: widget.spots.any((s) => s.x < 0)
//                     ? Alignment.bottomCenter
//                     : Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [const Color(0xFF05CABE), Colors.black],
//               ),
//             ),
//             show: true,
//             dotData: FlDotData(show: false),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ExpenseEmptyChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> xLabels;

  ExpenseEmptyChart({required this.spots, required this.xLabels});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 1,
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            // Colors.white.withValues(alpha: 0.8),

            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                );
              }).toList();
            },
          ),

          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Colors.white, // Line shown on touch
                  strokeWidth: 1,
                ),
                FlDotData(
                  show: true,
                ),
              );
            }).toList();
          },

          // enabled: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= xLabels.length) return Container();
                return SideTitleWidget(
                  // axisSide: meta.axisSide,
                  meta: meta,
                  child: Text(
                    '', // Show short month
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 2000, // Adjust according to your max values
              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 2000, // Adjust according to your max values
              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 2000, // Adjust according to your max values
              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 1,
            color: Color(0xFF2BDFD2),
            belowBarData: BarAreaData(
              show: true,
              color: Color(0xFF2BDFD2).withOpacity(0.3),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Colors.black,
                  Color.fromARGB(255, 27, 94, 90),
                  // Color(0xFF12ACA2),
                  // Color(0xFF05CABE),
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  // Colors.black,
                ],
              ),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

// class InvestEmptyChart extends StatelessWidget {
//   final List<FlSpot> spots;
//   final List<String> xLabels;

//   InvestEmptyChart({required this.spots, required this.xLabels});

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         minY: 20,
//         maxY: 100,
//         minX: -3,
//         lineTouchData: LineTouchData(
//           handleBuiltInTouches: true,
//           touchTooltipData: LineTouchTooltipData(
//             getTooltipColor: (touchedSpot) => Colors.white,
//             // Colors.white.withValues(alpha: 0.8),

//             getTooltipItems: (touchedSpots) {
//               return touchedSpots.map((spot) {
//                 return LineTooltipItem(
//                   '\$${spot.y.toStringAsFixed(0)}',
//                   const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 );
//               }).toList();
//             },
//           ),

//           getTouchedSpotIndicator:
//               (LineChartBarData barData, List<int> spotIndexes) {
//             return spotIndexes.map((index) {
//               return TouchedSpotIndicatorData(
//                 FlLine(
//                   color: Colors.white, // Line shown on touch
//                   strokeWidth: 1,
//                 ),
//                 FlDotData(
//                   show: true,
//                 ),
//               );
//             }).toList();
//           },

//           // enabled: false,
//         ),
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 35,
//               interval: 1,
//               getTitlesWidget: (value, meta) {
//                 int index = value.toInt();
//                 if (index < 0 || index >= xLabels.length) return Container();
//                 return SideTitleWidget(
//                   // axisSide: meta.axisSide,
//                   meta: meta,
//                   child: Text(
//                     '', // Show short month
//                     style: TextStyle(fontSize: 10, color: Colors.white),
//                   ),
//                 );
//               },
//             ),
//           ),
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: false,
//               interval: 2000, // Adjust according to your max values
//               getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
//             ),
//           ),
//           topTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: false,
//               interval: 2000, // Adjust according to your max values
//               getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: false,
//               interval: 2000, // Adjust according to your max values
//               getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
//             ),
//           ),
//         ),
//         gridData: FlGridData(show: false),
//         borderData: FlBorderData(show: true),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             barWidth: 1,
//             color: Color(0xFF2BDFD2),
//             belowBarData: BarAreaData(
//               show: true,
//               color: Color(0xFF2BDFD2).withOpacity(0.3),
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   // Colors.black,
//                   Color.fromARGB(255, 27, 94, 90),
//                   // Color(0xFF12ACA2),
//                   // Color(0xFF05CABE),
//                   Colors.black,
//                   Colors.black,
//                   Colors.black,
//                   Colors.black,
//                   Colors.black,
//                   Colors.black,
//                   // Colors.black,
//                 ],
//               ),
//             ),
//             dotData: FlDotData(show: false),
//           ),
//         ],
//       ),
//     );
//   }
// }

class InvestEmptyChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> xLabels;

  InvestEmptyChart({required this.spots, required this.xLabels});

  @override
  Widget build(BuildContext context) {
    double minXValue = spots.isNotEmpty
        ? spots.map((e) => e.x).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxXValue = spots.isNotEmpty
        ? spots.map((e) => e.x).reduce((a, b) => a > b ? a : b)
        : 0;

    return LineChart(
      LineChartData(
        baselineX: 0,
        baselineY: 0,
        minY: 0,
        maxY: 4000,
        minX: minXValue,
        maxX: maxXValue,
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response == null || response.lineBarSpots == null) return;
            final spot = response.lineBarSpots!.first;
          },
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(0),
            getTooltipColor: (touchedSpot) =>
                context.gc(AppColor.black).withOpacity(0.3),
            tooltipHorizontalOffset: 12,
            showOnTopOfTheChartBoxArea: false,
            tooltipMargin: 0,
            tooltipRoundedRadius: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            getTooltipItems: (touchedSpots) {
              final formatter = NumberFormat('#,###');
              final dateInputFormat = DateFormat('dd MMM yyyy');
              final dateOutputFormat = DateFormat('MMMM d, yyyy');

              return touchedSpots.map((spot) {
                int index = spot.spotIndex;
                String rawDate = index < 0 ? '' : '';
                String formattedDate = '';
                try {
                  final date = dateInputFormat.parse(rawDate);
                  formattedDate = dateOutputFormat.format(date);
                } catch (_) {
                  formattedDate = rawDate;
                }

                return LineTooltipItem(
                  '\$${formatter.format(spot.y)} \n$formattedDate',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.white, strokeWidth: 1, dashArray: [2, 2]),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: context.gc(AppColor.primary),
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            }).toList();
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            drawBelowEverything: false,
            sideTitles: SideTitles(
              showTitles: true,
              maxIncluded: false,
              minIncluded: true,
              reservedSize: 30,
              interval: 1000,
              getTitlesWidget: (value, meta) {
                bool isNegative = value < 0;
                double absValue = value.abs();
                String formattedValue;

                String format(double number, double divisor, String suffix) {
                  return '${(number / divisor).floor()}$suffix';
                }

                if (absValue >= 1_000_000_000_000) {
                  formattedValue = format(absValue, 1_000_000_000_000, 'T');
                } else if (absValue >= 1_000_000_000) {
                  formattedValue = format(absValue, 1_000_000_000, 'B');
                } else if (absValue >= 1_000_000) {
                  formattedValue = format(absValue, 1_000_000, 'M');
                } else if (absValue >= 1_000) {
                  formattedValue = format(absValue, 1_000, 'k');
                } else {
                  formattedValue = absValue.toInt().toString();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${isNegative ? '-\$' : '\$'}$formattedValue',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 1,
            color: Color(0xFF2BDFD2),
            belowBarData: BarAreaData(
              show: true,
              color: Color(0xFF2BDFD2).withOpacity(0.3),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Colors.black,
                  Color.fromARGB(255, 27, 94, 90),
                  // Color(0xFF12ACA2),
                  // Color(0xFF05CABE),
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                  // Colors.black,
                ],
              ),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
