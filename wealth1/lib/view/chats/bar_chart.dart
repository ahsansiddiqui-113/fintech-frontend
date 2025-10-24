import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseBarCht extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> xLabels;

  const ExpenseBarCht({
    super.key,
    required this.spots,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    bool isEmptyData = spots.every((spot) => spot.y == 0);

    if (isEmptyData) {
      return Center(
        child: Text(
          'No expense data available',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 100, // Ensure enough space for labels
              interval: 10, // One bar per index
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= xLabels.length) return Container();
                String label = xLabels[index];
                String displayLabel = label; // Default fallback

                if (label.contains('-')) {
                  List<String> parts = label.split('-');
                  if (parts.length == 3) {
                    displayLabel = "${parts[1]}-${parts[2]}"; // Show "03-02" instead of full date
                  }
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    displayLabel,
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Match line chart
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Match line chart
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Match line chart
          ),
        ),
        gridData: FlGridData(show: false), // Match line chart
        borderData: FlBorderData(show: true), // Match line chart
        barGroups: spots.asMap().entries.map((entry) {
          final index = entry.key;
          final spot = entry.value;
          return BarChartGroupData(
            barsSpace: 20,
            x: index,
            barRods: [
              BarChartRodData(
                toY: spot.y,
                width: 14,
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2BDFD2),
                    Color(0xFF12ACA2),
                  ],
                ),
              ),
            ],
            // No barsSpace needed since only one rod per group
          );
        }).toList(),
        groupsSpace: 20,

      ),
    );
  }
}

class ExpenseBarGraph {
  final String month;
  final double total;

  ExpenseBarGraph({required this.month, required this.total});
}
