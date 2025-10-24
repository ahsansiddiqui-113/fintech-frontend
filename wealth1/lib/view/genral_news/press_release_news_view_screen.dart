import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/genral_news/genral_news_viewall_screen.dart';
import 'package:wealthnx/view/genral_news/trending_news_screen.dart';
import 'package:wealthnx/view/webview_news/news_details_webview.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

// class PressReleaseNewsViewScreen extends StatelessWidget {
//   final String type;
//   final controller = Get.put(PressReleaseNewsController());
//
//   final ScrollController scrollController = ScrollController();
//
//   PressReleaseNewsViewScreen({super.key, required this.type}) {
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//               scrollController.position.maxScrollExtent - 300 &&
//           controller.hasMoreData.value &&
//           !controller.isMoreLoading.value) {
//         controller.fetchPaginatedNews(type: type);
//       }
//     });
//   }
class PressReleaseNewsViewScreen extends StatelessWidget {
  final String type;
  final String tag;
  late final PressReleaseNewsController controller;
  final ScrollController scrollController = ScrollController();

  PressReleaseNewsViewScreen({super.key, required this.type})
      : tag = 'news_${type.toLowerCase()}'
  {
    controller = Get.isRegistered<PressReleaseNewsController>(tag: tag)
        ? Get.find<PressReleaseNewsController>(tag: tag)
        : Get.put(PressReleaseNewsController(newsType: type), tag: tag);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300 &&
          controller.hasMoreData.value &&
          !controller.isMoreLoading.value) {
        controller.fetchPaginatedNews(type: type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Fintech Insider'),
      body: Obx(() {
        if (controller.isLoading.value && controller.newsList.isEmpty) {
          final base      = Colors.grey[850]!;
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

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchPaginatedNews(isFirstLoad: true,type: type);
          },
          child: ListView.builder(
            controller: scrollController,
            itemCount: controller.newsList.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.newsList.length) {
                final news = controller.newsList[index];
                return GestureDetector(
                  onTap: () => Get.to(() => WebViewPage(
                        url: news.url ?? '',
                        title: news.title ?? '',
                      )),
                  child: NewsCard(
                    publishDate: news.publishedDate,
                    imageUrl: news.image,
                    title: news.title ?? '',
                    source: news.site ?? '',
                    date: news.publishedDate ?? '',
                    tag: "",
                    isHorizontal: true,
                    showRelativeDate: false,
                    relativeText: controller.formatRelativeTime(news.publishedDate),
                    url: news.url,
                  ),
                  // child: Container(
                  //   margin: EdgeInsets.only(
                  //       bottom: 10, left: 12, right: 12, top: 12),
                  //   height: responTextWidth(180),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     image: DecorationImage(
                  //       image: NetworkImage(news.image.toString()),
                  //       fit: BoxFit.cover,
                  //       colorFilter: ColorFilter.mode(
                  //         context.gc(AppColor.black).withOpacity(0.3),
                  //         BlendMode.darken,
                  //       ),
                  //     ),
                  //   ),
                  //   child: Stack(
                  //     children: [
                  //       Positioned(
                  //         bottom: 0,
                  //         left: 0,
                  //         right: 0,
                  //         child: Container(
                  //           padding: EdgeInsets.all(responTextWidth(12)),
                  //           decoration: BoxDecoration(
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topCenter,
                  //               end: Alignment.bottomCenter,
                  //               colors: [
                  //                 context.gc(AppColor.transparent),
                  //                 context.gc(AppColor.black).withOpacity(0.8),
                  //               ],
                  //             ),
                  //           ),
                  //           child: Get.put(CommonController()).textWidget(
                  //             context,
                  //             title: news.title,
                  //             fontSize: responTextWidth(12),
                  //             fontWeight: FontWeight.w600,
                  //             maxLines: 3,
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         ),
                  //       ),
                  //       Positioned(
                  //         top: responTextHeight(10),
                  //         right: responTextWidth(10),
                  //         child: Get.put(CommonController()).textWidget(
                  //           context,
                  //           title: timeago
                  //               .format(DateTime.parse(news.publishedDate!)),
                  //           fontSize: responTextWidth(12),
                  //           fontWeight: FontWeight.w600,
                  //           maxLines: 3,
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                );
                // return ListTile(
                //   title: Text(news.title ?? 'No Title'),
                //   subtitle: Text(news.site ?? ''),
                // );
              } else {
                if (controller.hasMoreData.value) {
                  // return const Padding(
                  //   padding: EdgeInsets.all(16.0),
                  //   child: Center(child: CircularProgressIndicator()),
                  // );
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 1, // show 2 shimmer items while loading more
                      itemBuilder: (context, index) => NewsCardShimmer(),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }
            },
          ),
        );
      }),
    );
  }
}
