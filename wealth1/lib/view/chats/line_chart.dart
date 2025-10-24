import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/networth/net_worth_new_controller.dart';

class DoubleExpenseBarGraph {
  final String month;
  final double firstValue; // Asset
  final double secondValue; // Liabilities

  DoubleExpenseBarGraph({
    required this.month,
    required this.firstValue,
    required this.secondValue,
  });
}

class DoubleExpenseBarChart extends StatelessWidget {
  final List<DoubleExpenseBarGraph> data;
  final Color firstBarColor;
  final Color secondBarColor;

  DoubleExpenseBarChart({
    super.key,
    required this.data,
    required this.firstBarColor,
    required this.secondBarColor,
  });

  final controller = Get.put(NetWorthNewController());

  @override
  Widget build(BuildContext context) {
    final isEmptyData =
        data.every((item) => item.firstValue == 0 && item.secondValue == 0);

    /// Dummy Data Preparation (Only once)
    final dummyData = controller.netWorthEmptyList
        .map((item) => DoubleExpenseBarGraph(
              month: item.monthName,
              firstValue: item.asset,
              secondValue: item.liabilities,
            ))
        .toList();

    /// If Empty, Use Dummy Data, Else Actual Data
    final chartData = isEmptyData ? dummyData : data;
    final last6MonthsData = chartData.length > 6
        ? chartData.sublist(chartData.length - 6) // take last 6
        : chartData; // take all if < 6
    return Container(
      padding: EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 4),
      // decoration: BoxDecoration(
      //   border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          // maxY: chartData.isNotEmpty
          //     ? chartData
          //             .map((e) => (e.firstValue > e.secondValue
          //                 ? e.firstValue
          //                 : e.secondValue))
          //             .reduce((a, b) => a > b ? a : b) +
          //         5000
          //     : 5000,
          maxY: last6MonthsData.isNotEmpty
              ? last6MonthsData
              .map((e) => (e.firstValue > e.secondValue
              ? e.firstValue
              : e.secondValue))
              .reduce((a, b) => a > b ? a : b) +
              5000
              : 5000,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black.withOpacity(0.8),

              // getTooltipItem: (group, groupIndex, rod, rodIndex) {
              //   final month = groupIndex < chartData.length
              //       ? chartData[groupIndex].month
              //       : '';
              //   final value = rod.toY.toStringAsFixed(0);
              //   final label = rodIndex == 0 ? 'Assets' : 'Liabilities';
              //   return BarTooltipItem(
              //     '$month\n$label: \$$value',
              //     const TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 15,
              //     ),
              //   );
              // },
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = groupIndex < last6MonthsData.length
                    ? last6MonthsData[groupIndex].month
                    : '';
                final value = rod.toY.toStringAsFixed(0);
                final label = rodIndex == 0 ? 'Assets' : 'Liabilities';
                return BarTooltipItem(
                  '$month\n$label: \$$value',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },

            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 1,
                // getTitlesWidget: (value, meta) {
                //   final index = value.toInt();
                //   if (index < 0 || index >= chartData.length)
                //     return Container();
                //   return SideTitleWidget(
                //     meta: meta,
                //     // child: Text(
                //     //   chartData[index].month,
                //     //   style: const TextStyle(fontSize: 10, color: Colors.white),
                //     // ),
                //     child: Text(
                //       chartData[index].month.length > 3
                //           ? chartData[index].month.substring(0, 3) // show first 3 characters
                //           : chartData[index].month, // if less than 3 chars, show whole string
                //       style: const TextStyle(fontSize: 10, color: Colors.white),
                //     ),
                //   );
                // },
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= last6MonthsData.length) return Container();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      last6MonthsData[index].month.length > 3
                          ? last6MonthsData[index].month.substring(0, 3)
                          : last6MonthsData[index].month,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            // leftTitles: AxisTitles(axisNameWidget: Text('/**/'), sideTitles: SideTitles(showTitles: false)),

            // leftTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 30)),
            //   leftTitles: AxisTitles(
            //       sideTitles: SideTitles(
            //     reservedSize: 30,
            //     interval: 4,
            //     maxIncluded: true,
            //     minIncluded: true,
            //
            //     showTitles: true,
            //     getTitlesWidget: (value, meta) {
            //       if (value == 0) {
            //         return _buildLeftTitle('0');
            //       } else if (value == 10) {
            //         return _buildLeftTitle('10');
            //       } else if (value == 100) {
            //         return _buildLeftTitle('100');
            //       } else if (value == 1000) {
            //         return _buildLeftTitle('1k');
            //       } else if (value == 100000) {
            //         return _buildLeftTitle('100k');
            //       } else {
            //         return Container();
            //       }
            //     },
            //   )),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true),
          // barGroups: chartData.asMap().entries.map((entry) {
          //   final index = entry.key;
          //   final item = entry.value;
          //   return BarChartGroupData(
          //     x: index,
          //     barRods: [
          //       BarChartRodData(
          //         toY: item.firstValue,
          //         width: 14,
          //         borderRadius: BorderRadius.circular(4),
          //         color: firstBarColor,
          //       ),
          //       BarChartRodData(
          //         toY: item.secondValue,
          //         width: 14,
          //         borderRadius: BorderRadius.circular(4),
          //         color: secondBarColor,
          //       ),
          //     ],
          //   );
          // }).toList(),
          barGroups: last6MonthsData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.firstValue,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  color: firstBarColor,
                ),
                BarChartRodData(
                  toY: item.secondValue,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  color: secondBarColor,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
