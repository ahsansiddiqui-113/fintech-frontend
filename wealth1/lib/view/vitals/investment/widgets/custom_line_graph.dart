import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';

class CustomLineGraph extends StatelessWidget {
  const CustomLineGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return buildInvestGraph(context);
  }

  Widget buildInvestGraph(BuildContext context) {
    final responseData = [
      {"monthName": "May", "total": 115.57},
      {"monthName": "Apr", "total": 8984.03},
      {"monthName": "Mar", "total": 2943.02},
      {"monthName": "Feb", "total": 13403.76},
      {"monthName": "Jan", "total": 0},
      {"monthName": "Dec", "total": 0},
    ];

// Reverse for chronological order (old to new)
    final chartData = responseData.toList();

// X-axis labels
    final xLabels = chartData.map((e) => e['monthName'] as String).toList();

// Create spots for the line chart
    final List<FlSpot> spots = List.generate(chartData.length, (index) {
      final total = (chartData[index]['total'] as num).toDouble();
      return FlSpot(index.toDouble(), total);
    });

    final totalSum = responseData.fold<double>(
      0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: (totalSum == 0.0) ? 80 : 30,
          ),
          Container(
            height: (totalSum == 0.0) ? 150 : 200,
            child: (totalSum == 0.0)
                ? ExpenseEmptyChart(
                    spots: spots,
                    xLabels: xLabels,
                  )
                : ExpenseChart(
                    spots: spots,
                    xLabels: xLabels,
              timePeriod:  'Yearly',
                  ),
          ),
        ],
      ),
    );
  }
}
