import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/view/genral_news/recent_stories_screen.dart';
import 'package:wealthnx/view/genral_news/trending_news_screen.dart';
import 'package:wealthnx/view/schedule/schedule_screen.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/empty.dart';

class ViewAllNewsPage extends StatelessWidget {
  ViewAllNewsPage({super.key});

  final controller = Get.put(NewsController());
  final ScrollController _outer = ScrollController(); // only outer list

  @override
  Widget build(BuildContext context) {
    // Ensure initial data (All tab default)
    // controller.selectCategory(0);

    return Scaffold(
      appBar: customAppBar(title: 'News'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {
          final idx = controller.selectedCategoryIndex.value;

          final initialLoading = (idx == 0)
              ? (controller.isLoading.value && controller.newsList.isEmpty)
              : (idx == 1
                  ? (controller.isPressStocksLoading.value &&
                      controller.pressStocksList.isEmpty)
                  : (controller.isPressCryptoLoading.value &&
                      controller.pressCryptoList.isEmpty));

          // if (initialLoading) {
          //   return ListView.builder(
          //     itemCount: 8,
          //     itemBuilder: (_, __) => Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 8.0),
          //       child: buildInvestChartShimmerEffect(),
          //     ),
          //   );
          // }
          // if (initialLoading) {
          //   return ListView.builder(
          //     itemCount: 8,
          //     itemBuilder: (_, __) => Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 8.0),
          //       child: buildInvestChartShimmerEffect(),
          //     ),
          //   );
          // }
//           if (initialLoading) {
//             // Show shimmer for both trending + recent stories
//             return ListView(
//               controller: _outer,
//               children: [
//                 /// Trending shimmer
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: SectionName(
//                     title: 'Trending',
//                     titleOnTap: 'View All',
//                     fontSize: 16,
//                     onTap: () {}, // disable during shimmer
//                   ),
//                 ),
//                 SizedBox(
//                   height: 250,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 4, // shimmer cards
//                     itemBuilder: (_, __) => Container(
//                       width: 200,
//                       margin: const EdgeInsets.all(8),
//                       child: buildInvestChartShimmerEffect(),
//                     ),
//                   ),
//                 ),
// addHeight(80),
//                 /// Recent Stories shimmer
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: SectionName(
//                     title: 'Recent Stories',
//                     fontSize: 16,
//                     titleOnTap: 'View All',
//                     onTap: () {}, // disable during shimmer
//                   ),
//                 ),
//                 ListView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: 6, // vertical shimmer items
//                   itemBuilder: (_, __) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 18.0),
//                     child: buildInvestChartShimmerEffect(),
//                   ),
//                 ),
//               ],
//             );
//           }
          if (initialLoading) {
            return _newsScreenShimmer(context, _outer);
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (idx == 0) {
                await controller.fetchPaginatedNews(isFirstLoad: true);
                await controller.selectCategory(0); // keep 3+3 fresh
              } else if (idx == 1) {
                await controller.fetchPressRelease(
                    type: 'Stocks', isFirstLoad: true);
              } else {
                await controller.fetchPressRelease(
                    type: 'Crypto', isFirstLoad: true);
              }
            },
            child: ListView(
              controller: _outer,
              children: [
                /// Trending (unchanged)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SectionName(
                    title: 'Trending',
                    titleOnTap: 'View All',
                    onTap: () => Get.to(() => const TrendingNewsPage()),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: Obx(() {
                    final trending = controller.trending6;
                    if (trending.isEmpty) {
                      return Center(
                        child: Empty(
                          title: 'News',
                          height: responTextHeight(70),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trending.length,
                      itemBuilder: (context, index) {
                        final news = trending[index];
                        return NewsCard(
                          imageUrl: news.image,
                          title: news.title ?? '',
                          source: news.site ?? '',
                          date: news.publishedDate ?? '',
                          publishDate: news.publishedDate,
                          tag: "Just Now",
                          isHorizontal: false,
                          showRelativeDate: false,
                          relativeText: '',
                          url: news.url, // 👈 add this
                        );
                      },
                    );
                  }),
                ),

                /// Recent Stories header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SectionName(
                    title: 'Recent Stories',

                    titleOnTap: 'View All',
                    onTap: () => Get.to(() =>
                        const RecentStoriesPage()), // full pagination lives there
                  ),
                ),
                addHeight(10),

                /// Category chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomCategoryButton(
                        text: "All",
                        isActive: idx == 0,
                        onPressed: () =>
                            controller.switchCategoryWithShimmer(0),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      CustomCategoryButton(
                        text: "Stocks",
                        isActive: idx == 1,
                        onPressed: () =>
                            controller.switchCategoryWithShimmer(1),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      CustomCategoryButton(
                        text: "Crypto",
                        isActive: idx == 2,
                        onPressed: () =>
                            controller.switchCategoryWithShimmer(2),
                      ),
                    ],
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     Expanded(
                //       child: CustomCategoryButton(
                //         text: "All",
                //         isActive: idx == 0,
                //         onPressed: () => controller.selectCategory(0),
                //       ),
                //     ),
                //     Expanded(
                //       child: CustomCategoryButton(
                //         text: "Stocks",
                //         isActive: idx == 1,
                //         onPressed: () => controller.selectCategory(1),
                //       ),
                //     ),
                //     Expanded(
                //       child: CustomCategoryButton(
                //         text: "Crypto",
                //         isActive: idx == 2,
                //         onPressed: () => controller.selectCategory(2),
                //       ),
                //     ),
                //     const Expanded(child: SizedBox()),
                //   ],
                // ),
                addHeight(10),

                /// Recent Stories list — STRICTLY 6 items, NO pagination here
                Obx(() {
                  final int tab = controller.selectedCategoryIndex.value;

                  // ✅ shimmer only when switching tabs
                  final bool showListShimmer = controller.isTabLoading.value;

                  if (showListShimmer) {
                    // return ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   itemCount: 6,
                    //   itemBuilder: (_, __) => Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //     child: buildInvestChartShimmerEffect(),
                    //   ),
                    // );
                    final base = Colors.grey[850]!;
                    final highlight = Colors.grey[700]!;
                    // return ListView.builder(
                    //     itemCount: 8,
                    //     shrinkWrap: true,
                    //     itemBuilder: (context, index) {
                    //       return Padding(
                    //         padding:
                    //             const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    //         child: buildInvestChartShimmerEffect(),
                    //       );
                    //     });
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 6,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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

                  // actual items
                  List items;
                  if (tab == 1) {
                    items = controller.pressStocksList.take(6).toList();
                  } else if (tab == 2) {
                    items = controller.pressCryptoList.take(6).toList();
                  } else {
                    items = controller.allMix6; // 3 + 3
                  }

                  if (items.isEmpty) {
                    // No shimmer on initial load — just show empty-state
                    return Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Empty(
                          title: 'News',
                          height: responTextHeight(70),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final news = items[index];
                      final showRel = tab == 1 || tab == 2 || tab == 0;
                      final relText = showRel
                          ? controller.formatRelativeTime(news.publishedDate)
                          : '';

                      return NewsCard(
                        publishDate: news.publishedDate,
                        imageUrl: news.image,
                        title: news.title ?? '',
                        source: news.site ?? '',
                        date: news.publishedDate ?? '',
                        tag: "",
                        isHorizontal: true,
                        showRelativeDate: showRel,
                        relativeText: relText,
                        url: news.url,
                      );
                    },
                  );
                }),
                // Obx(() {
                //   final int tab = controller.selectedCategoryIndex.value;
                //   List items;
                //   if (tab == 1) {
                //     items = controller.pressStocksList.take(6).toList();
                //   } else if (tab == 2) {
                //     items = controller.pressCryptoList.take(6).toList();
                //   } else {
                //     items = controller.allMix6; // 3 + 3
                //   }
                //
                //   if (items.isEmpty) {
                //     return const Padding(
                //       padding: EdgeInsets.all(24.0),
                //       child: Center(
                //         child: Text('No news found', style: TextStyle(color: Colors.white54)),
                //       ),
                //     );
                //   }
                //
                //   return ListView.builder(
                //     physics: const NeverScrollableScrollPhysics(),
                //     shrinkWrap: true,
                //     itemCount: items.length,
                //     itemBuilder: (context, index) {
                //       final news = items[index];
                //
                //       final showRel = tab == 1 || tab == 2;
                //       final relText =
                //       showRel ? controller.formatRelativeTime(news.publishedDate) : '';
                //
                //       return NewsCard(
                //         publishDate: news.publishedDate,
                //         imageUrl: news.image,
                //         title: news.title ?? '',
                //         source: news.site ?? '',
                //         date: news.publishedDate ?? '',
                //         tag: "",
                //         isHorizontal: true,
                //         showRelativeDate: false,
                //         relativeText: relText,
                //         url: news.url,
                //       );
                //     },
                //   );
                // }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String source;
  final String date;
  final String? tag;
  final bool isHorizontal;
  final String? publishDate;
  final String? url;
  final bool showRelativeDate;
  final String relativeText;

  const NewsCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.source,
    required this.date,
    this.tag,
    this.isHorizontal = false,
    required this.publishDate,
    this.showRelativeDate = false,
    this.relativeText = '',
    this.url,
  });

  Future<void> _openLink() async {
    if (url == null || url!.isEmpty) return;
    final uri = Uri.parse(url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String formatDateWithRelative(String rawDate, String relativeText) {
    try {
      final d = DateTime.parse(rawDate).toLocal();
      final formattedDate = "${d.month}-${d.day}-${d.year}";
      if (relativeText.isEmpty) {
        return "$formattedDate";
      }
      return "$formattedDate";
    } catch (_) {
      return relativeText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              height: isHorizontal ? 100 : 150,
              width: isHorizontal ? 120 : double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/Card.png',
                height: isHorizontal ? 100 : 150,
                width: isHorizontal ? 120 : double.infinity,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/Card.png',
              height: isHorizontal ? 100 : 150,
              width: isHorizontal ? 120 : double.infinity,
              fit: BoxFit.cover,
            ),
    );

    final detailsWidget = Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            left: isHorizontal ? 8 : 0, top: isHorizontal ? 0 : 8, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://www.google.com/s2/favicons?sz=64&domain_url=$source',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/images/expensewallet.png'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white70)),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDateWithRelative(date, relativeText),
                              style: const TextStyle(
                                  fontSize: 8, color: Colors.white54),
                            ),

                            // Text(
                            //   (() {
                            //     if (showRelativeDate &&
                            //         (relativeText.isNotEmpty)) {
                            //       return relativeText;
                            //     }
                            //     try {
                            //       final d = DateTime.parse(date);
                            //       return '${d.month}-${d.day}-${d.year}';
                            //     } catch (_) {
                            //       return date;
                            //     }
                            //   })(),
                            //   style: const TextStyle(
                            //       fontSize: 8, color: Colors.white54),
                            // ),
                            const SizedBox(width: 12),
                            if (tag != null && tag!.isEmpty)
                              Text(
                                relativeText,
                                style: const TextStyle(
                                    fontSize: 8, color: Colors.white54),
                              ),
                            if (tag != null && tag!.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Text(tag!,
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: _openLink,
      child: Container(
        width: isHorizontal ? double.infinity : 250,
        margin: const EdgeInsets.only(right: 8, bottom: 8, top: 8),
        child: isHorizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [detailsWidget, addWidth(5), imageWidget],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [imageWidget, detailsWidget],
              ),
      ),
    );
  }
}

Widget _newsScreenShimmer(BuildContext context, ScrollController outer) {
  final base = Colors.grey[850]!;
  final highlight = Colors.grey[700]!;

  final cardW = marginSide(280); // similar width to your trending card
  final cardH = 240.0;
  final radius = 16.0;

  return ListView(
    controller: outer,
    padding: const EdgeInsets.only(bottom: 18),
    children: [
      // -------- Trending (real header from your UI) --------
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SectionName(
          title: 'Trending',
          titleOnTap: 'View All',
          fontSize: 16,
          onTap: () {}, // disabled during shimmer
        ),
      ),
      const SizedBox(height: 8),

      // -------- Trending horizontal skeletons --------
      SizedBox(
        height: cardH,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: _trendingCardSkeleton(
                  width: cardW, height: cardH, radius: radius, base: base),
            ),
          ),
        ),
      ),

      const SizedBox(height: 45),

      // -------- Recent Stories (real header) --------
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SectionName(
          title: 'Recent Stories',
          titleOnTap: 'View All',
          fontSize: 16,
          onTap: () {}, // disabled during shimmer
        ),
      ),
      const SizedBox(height: 20),

      // -------- 3 filter chips (All | Stocks | Crypto) --------
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Row(
            children: [
              _chipSkeleton(
                  labelWidth: 10, padH: 18, base: base), // All (slightly wider)
              const SizedBox(width: 8),
              _chipSkeleton(labelWidth: 10, padH: 18, base: base), // Stocks
              const SizedBox(width: 8),
              _chipSkeleton(labelWidth: 10, padH: 18, base: base), // Crypto
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),

      // -------- Recent Stories vertical list (text left, image right) --------
      ListView.builder(
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
      ),
    ],
  );
}

Widget _trendingCardSkeleton({
  required double width,
  required double height,
  required double radius,
  required Color base,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image
            Expanded(
              child: Container(color: base),
            ),
            // Title lines
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: width * 0.85, height: 14, base: base, radius: 6),
                  const SizedBox(height: 6),
                  _line(width: width * 0.55, height: 12, base: base, radius: 6),
                  const SizedBox(height: 8),
                  // Meta row: circle + two tiny lines
                  Row(
                    children: [
                      _circle(size: 30, base: base),
                      const SizedBox(width: 8),
                      _line(width: 70, height: 10, base: base, radius: 4),
                      const SizedBox(width: 8),
                      _line(width: 48, height: 10, base: base, radius: 4),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget recentStoryRowSkeleton({required Color base}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left: text stack
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(width: double.infinity, height: 14, base: base, radius: 6),
            const SizedBox(height: 6),
            _line(width: double.infinity, height: 12, base: base, radius: 6),
            const SizedBox(height: 10),
            Row(
              children: [
                _circle(size: 30, base: base),
                const SizedBox(width: 8),
                _line(width: 70, height: 10, base: base, radius: 4),
                const SizedBox(width: 8),
                _line(width: 60, height: 10, base: base, radius: 4),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      // Right: thumbnail
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(width: 120, height: 110, color: base),
      ),
    ],
  );
}

Widget _chipSkeleton(
    {required double labelWidth, required double padH, required Color base}) {
  // pill shape approximating your filter chips
  return Container(
    padding: EdgeInsets.symmetric(horizontal: padH, vertical: 10),
    decoration: BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(12),
    ),
    child: SizedBox(width: labelWidth, height: 10),
  );
}

Widget _line({
  required double width,
  required double height,
  required Color base,
  double radius = 8,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Container(width: width, height: height, color: base),
  );
}

Widget _circle({required double size, required Color base}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(size),
    child: Container(width: size, height: size, color: base),
  );
}
