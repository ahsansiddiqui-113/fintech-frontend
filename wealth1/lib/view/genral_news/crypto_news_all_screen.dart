import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

import '../../controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import '../../widgets/news_custom_widget.dart';

class CryptoNewsAllScreen extends StatelessWidget {
  final controller = Get.put(ChartController());

  final ScrollController scrollController = ScrollController();

  final bool cryptoNews;
  final String newsId;
  CryptoNewsAllScreen(
      {Key? key, required this.cryptoNews, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Fintech Insider'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Obx(() {
          if (controller.isLoading.value && controller.newsList.isEmpty) {
            return ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: buildInvestChartShimmerEffect(),
                  );
                });
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchNews(cryptoNews: cryptoNews, newsId: newsId);
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: controller.newsList.length,
              itemBuilder: (context, index) {
                final news = controller.newsList[index];
                return newsCustomWidget(
                  image: news.image.toString(),
                  title: news.title ?? '',
                  publishedDate: news.publishedDate ?? '',
                  url: news.url ?? '',
                  cryptoNewsModel: news,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
