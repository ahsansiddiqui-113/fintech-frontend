
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/genral_news/genral_news_viewall_screen.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class TrendingNewsPage extends StatefulWidget {
  const TrendingNewsPage({super.key});

  @override
  State<TrendingNewsPage> createState() => _TrendingNewsPageState();
}

class _TrendingNewsPageState extends State<TrendingNewsPage> {
  late final NewsController controller;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewsController>();

    // Initial fetch
    if (controller.newsList.isEmpty && !controller.isLoading.value) {
      controller.fetchPaginatedNews(isFirstLoad: true);
    }

    // Infinite scroll (guarded)
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        if (!controller.isMoreLoading.value && controller.hasMoreData.value) {
          controller.fetchPaginatedNews();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Trending News"),
      body: Obx(() {
        final firstLoading = controller.isLoading.value && controller.newsList.isEmpty;

        if (firstLoading) {
          // return const Center(
          //   child: SizedBox(
          //     height: 40,
          //     width: 40,
          //     child: CircularProgressIndicator(strokeWidth: 3),
          //   ),
          // );
          final base      = Colors.grey[850]!;
          final highlight = Colors.grey[700]!;
          return  ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 6,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                child: recentStoryRowSkeleton(base: base),
              ),
            ),
          );
        }

        // 2) Empty state (with pull-to-refresh)
        if (!controller.isLoading.value && controller.newsList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => controller.fetchPaginatedNews(isFirstLoad: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(child: Empty(title: 'News', height: responTextHeight(70))),
                const SizedBox(height: 120),
              ],
            ),
          );
        }

        // 3) List + reliable bottom shimmer when loading more
        return RefreshIndicator(
          onRefresh: () async => controller.fetchPaginatedNews(isFirstLoad: true),
          child: ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.newsList.length + (controller.isMoreLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              // News items
              if (index < controller.newsList.length) {
                final news = controller.newsList[index];
                final rel = controller.formatRelativeTime(news.publishedDate);

                return NewsCard(
                  imageUrl: news.image,
                  title: news.title ?? '',
                  source: news.site ?? '',
                  date: news.publishedDate ?? '',
                  publishDate: news.publishedDate,
                  tag: "just now",
                  isHorizontal: true,
                  showRelativeDate: false,
                  relativeText: rel,
                  url: news.url,
                );
              }

              // Footer shimmer (ONE item, no nested ListView)
              return const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: NewsCardShimmer(),
              );
            },
          ),
        );
      }),
    );
  }
}


class NewsCardShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final double imageSize;
  final double gap;
  final double radius;

  const NewsCardShimmer({
    super.key,
    this.padding = EdgeInsets.zero,
    this.imageSize = 80,
    this.gap = 12,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final base      = Colors.grey[850]!;
    final highlight = Colors.grey[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: recentStoryRowSkeleton(base: base),
      ),
    );
  }
}
