import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
import 'package:wealthnx/services/crypto_news_services.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/genral_news/genral_news_viewall_screen.dart';
import 'package:wealthnx/view/genral_news/press_release_news_view_screen.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/webview_news/news_details_webview.dart';
import 'package:wealthnx/widgets/empty.dart';

class PressReleaseNewsController extends GetxController {
  // final ApiService _apiService = ApiService();
  //
  // var newsList = <CryptoNewsModel>[].obs;
  // var isLoading = false.obs;
  // var errorMessage = ''.obs;
  // var isMoreLoading = false.obs;
  // var page = 0;
  // final int limit = 10;
  // var hasMoreData = true.obs;
  //
  // Future<void> fetchPaginatedNews({bool isFirstLoad = false}) async {
  //   if (isFirstLoad) {
  //     newsList.clear();
  //     page = 0;
  //     hasMoreData(true);
  //   }
  //   if (!hasMoreData.value || isLoading.value || isMoreLoading.value) return;
  //
  //   try {
  //     if (isFirstLoad) {
  //       isLoading(true);
  //     } else {
  //       isMoreLoading(true);
  //     }
  //     errorMessage('');
  //
  //     final newNews = await _apiService.fetchPressReleaseNewsWithPagination(
  //       page: page,
  //       limit: limit,
  //       cryptoType: 'Crypto',
  //     );
  //
  //     if (newNews.isEmpty) {
  //       hasMoreData(false);
  //     } else {
  //       newsList.addAll(newNews);
  //       page++;
  //     }
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     // Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading(false);
  //     isMoreLoading(false);
  //   }
  // }
  final ApiService _apiService = ApiService();

  /// 'All' | 'Crypto' | 'Stock'
  final String newsType;
  var newsList = <CryptoNewsModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isMoreLoading = false.obs;
  var page = 0;
  final int limit = 10;
  var hasMoreData = true.obs;
  PressReleaseNewsController( {this.newsType = "Crypto"});
  @override
  void onInit() {
    super.onInit();
    fetchPaginatedNews(isFirstLoad: true);
  }

  Future<void> fetchPaginatedNews({bool isFirstLoad = false, String? type}) async {
    if (isFirstLoad) {
      newsList.clear();
      page = 0;
      hasMoreData(true);
    }
    if (!hasMoreData.value || isLoading.value || isMoreLoading.value) return;

    try {
      if (isFirstLoad) {
        isLoading(true);
      } else {
        isMoreLoading(true);
      }
      errorMessage('');
      final typeParam =  newsType;

      final newNews = await _apiService.fetchPressReleaseNewsWithPagination(
        page: page,
        limit: limit,
        cryptoType: type ??  typeParam ,
      );

      if (newNews.isEmpty) {
        hasMoreData(false);
      } else {
        newsList.addAll(newNews);
        page++;
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  Widget buildNewsSection(BuildContext context,{String type = "Crypto"}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionName(
          title: '${type} News',
          titleOnTap: 'View All',
          onTap: () {
            fetchPaginatedNews(isFirstLoad: true);
            Get.to(() => PressReleaseNewsViewScreen(type: type,));
          },
        ),
        addHeight(14),

        Obx(() {
          // ---------- LOADING: horizontal shimmer ----------
          if (isLoading.value && newsList.isEmpty) {
            final cardWidth = Get.width * 0.75;
            return SizedBox(
              height: marginVertical(190),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 12),
                itemCount: 2,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(width: cardWidth, child:  Shimmer.fromColors(
                    baseColor: Colors.black,
                    highlightColor: Colors.grey[700]!,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
                ),
              ),
            );
          }

          // ---------- EMPTY ----------
          if (newsList.isEmpty) {
            return Center(
              child: Empty(
                title: 'News',
                height: responTextHeight(70),
              ),
            );
          }

          // ---------- CONTENT: horizontal NewsCard feed (like new UI) ----------
          final itemCount = newsList.length >= 2 ? 2 : newsList.length;
          final cardWidth = Get.width * 0.75;

          return SizedBox(
            height: marginVertical(270),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final news = newsList[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: cardWidth,
                    child: NewsCard(
                      imageUrl: news.image ?? '',
                      title: news.title ?? '',
                      source: news.site ?? '',
                      date: news.publishedDate ?? '',
                      publishDate: news.publishedDate,
                      tag: "",
                      isHorizontal: false,
                      showRelativeDate: false,
                      relativeText: '',
                      url: news.url ?? '',
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
  String formatRelativeTime(String? dateTimeString) {
    try {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';
      final dt = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';

      // Yesterday?
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return 'Yesterday';
      }

      if (diff.inDays < 30) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
      final months = (diff.inDays / 30).floor();
      if (months < 12) return '$months month${months == 1 ? '' : 's'} ago';
      final years = (diff.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } catch (_) {
      return '';
    }
  }
}
