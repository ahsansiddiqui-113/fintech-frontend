import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart_plus_deeping/chart_style.dart';
import 'package:k_chart_plus_deeping/k_chart_widget.dart';
import 'package:wealthnx/controller/investment/stocks/stock_live_data/stock_live_data_controller.dart';

class CandlePage extends StatelessWidget {
  CandlePage({super.key, this.isLine});

  bool? isLine;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StockCoinDetailController>();

    return Container(
      child: Obx(() {
        if (controller.isLoading.value && controller.chartData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error loading chart: ${controller.error.value}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (controller.chartData.isEmpty) {
          return const Center(
            child: Text(
              'No chart data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return KChartWidget(
          controller.chartData,
          ChartStyle(),
          ChartColors(
              bgColor: Colors.transparent,
              gridColor: Colors.transparent,

              // line
              kLineColor: Color(0xFF2EADA5), // line color
              lineFillColor: Color(0xFF2EADA5).withOpacity(0.3),

              // info window
              selectFillColor: Colors.black, // background of the card
              selectBorderColor: Colors.grey.withOpacity(0.4), // border color
              infoWindowTitleColor: Colors.white, // title color
              infoWindowNormalColor: Colors.white, // normal text color
              infoWindowUpColor: const Color(0xFF2EADA5),
              infoWindowDnColor: const Color(0xFFD5405D),
              sizeText: 11,
              crossTextColor: Colors.white ,
              //
              maxColor: Colors.transparent,
              minColor: Colors.transparent),
          isLine: isLine ?? false,
          isTrendLine: false,
          volHidden: true,
          isTapShowInfoDialog: true,
          hideGrid: false,
        );
      }),
    );
  }
}
