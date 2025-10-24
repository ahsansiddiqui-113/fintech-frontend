import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/genral_news/genral_news_viewall_screen.dart';
import 'package:wealthnx/view/genral_news/trending_news_screen.dart';
import 'package:wealthnx/view/schedule/schedule_screen.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';


class RecentStoriesPage extends StatefulWidget {
  const RecentStoriesPage({super.key});

  @override
  State<RecentStoriesPage> createState() => _RecentStoriesPageState();
}

class _RecentStoriesPageState extends State<RecentStoriesPage> {
  final controller = Get.find<NewsController>();
  final ScrollController _listCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    if (controller.pressStocksList.isEmpty) {
      controller.fetchPressRelease(type: 'Stocks', isFirstLoad: true);
    }
    if (controller.pressCryptoList.isEmpty) {
      controller.fetchPressRelease(type: 'Crypto', isFirstLoad: true);
    }

    _listCtrl.addListener(_maybePaginate);
  }

  @override
  void dispose() {
    _listCtrl.removeListener(_maybePaginate);
    _listCtrl.dispose();
    super.dispose();
  }

  void _maybePaginate() {
    if (!_listCtrl.hasClients) return;
    final nearEnd = _listCtrl.position.pixels >= _listCtrl.position.maxScrollExtent - 300;
    if (!nearEnd) return;

    final idx = controller.selectedCategoryIndex.value;

    if (idx == 1) {
      // Stocks
      if (controller.hasMoreStocks.value && !controller.isMorePressStocksLoading.value) {
        controller.fetchPressRelease(type: 'Stocks');
      }
    } else if (idx == 2) {
      // Crypto
      if (controller.hasMoreCrypto.value && !controller.isMorePressCryptoLoading.value) {
        controller.fetchPressRelease(type: 'Crypto');
      }
    } else {
      final canStocks = controller.hasMoreStocks.value && !controller.isMorePressStocksLoading.value;
      final canCrypto = controller.hasMoreCrypto.value && !controller.isMorePressCryptoLoading.value;

      if (canStocks) controller.fetchPressRelease(type: 'Stocks');
      if (canCrypto) controller.fetchPressRelease(type: 'Crypto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Recent Stories"),
      body: Obx(() {
        final idx = controller.selectedCategoryIndex.value;

        // initial loading flags per selection
        final initialLoading = (idx == 1)
            ? (controller.isPressStocksLoading.value && controller.pressStocksList.isEmpty)
            : (idx == 2)
            ? (controller.isPressCryptoLoading.value && controller.pressCryptoList.isEmpty)
            : (controller.isPressStocksLoading.value && controller.pressStocksList.isEmpty) ||
            (controller.isPressCryptoLoading.value && controller.pressCryptoList.isEmpty);

        if (initialLoading) {
          return ListView.builder(
            controller: _listCtrl,
            itemCount: 8,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: buildInvestChartShimmerEffect(),
            ),
          );
        }

        // Build the list the user selected
        final items = _buildItemsFor(idx);

        // Loader row logic
        final showLoader = (idx == 1 && (controller.isMorePressStocksLoading.value || controller.hasMoreStocks.value)) ||
            (idx == 2 && (controller.isMorePressCryptoLoading.value || controller.hasMoreCrypto.value)) ||
            (idx == 0 && (controller.isMorePressStocksLoading.value || controller.hasMoreStocks.value ||
                controller.isMorePressCryptoLoading.value || controller.hasMoreCrypto.value));

        final itemCount = items.length + (showLoader ? 1 : 0);

        return RefreshIndicator(
          onRefresh: () async {
            if (idx == 1) {
              await controller.fetchPressRelease(type: 'Stocks', isFirstLoad: true);
            } else if (idx == 2) {
              await controller.fetchPressRelease(type: 'Crypto', isFirstLoad: true);
            } else {
              // All: refresh both
              await controller.fetchPressRelease(type: 'Stocks', isFirstLoad: true);
              await controller.fetchPressRelease(type: 'Crypto', isFirstLoad: true);
            }
          },
          child: ListView(
            controller: _listCtrl,
            children: [
              // Buttons row
              Padding(
                padding: const EdgeInsets.only(right: 40, left: 12, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomCategoryButton(
                      text: "All",
                      isActive: idx == 0,
                      onPressed: () => controller.selectCategory(0),
                    ),
                    SizedBox(width: 8,),
                    CustomCategoryButton(
                      text: "Stocks",
                      isActive: idx == 1,
                      onPressed: () => controller.selectCategory(1),
                    ),
                    SizedBox(width: 8,),
                    CustomCategoryButton(
                      text: "Crypto",
                      isActive: idx == 2,
                      onPressed: () => controller.selectCategory(2),
                    ),
                    Expanded(child: SizedBox())
                  ],
                ),
              ),
              addHeight(10),

              // The list itself
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('No news found', style: TextStyle(color: Colors.white54)),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    if (i < items.length) {
                      final news = items[i];
                      final rel = controller.formatRelativeTime(news.publishedDate);

                      return NewsCard(
                        publishDate: news.publishedDate,
                        imageUrl: news.image,
                        title: news.title ?? '',
                        source: news.site ?? '',
                        date: news.publishedDate ?? '',
                        tag: "",
                        isHorizontal: true,
                        showRelativeDate: false,
                        relativeText: rel,
                        url: news.url,
                      );
                    }

                    // loader row at the end
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
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Build items for current selection.
  /// For All: merge stocks + crypto by publishedDate desc.
  List _buildItemsFor(int idx) {
    if (idx == 1) {
      // Stocks only
      return controller.pressStocksList;
    } else if (idx == 2) {
      // Crypto only
      return controller.pressCryptoList;
    } else {
      // All: merged & sorted list
      final merged = [...controller.pressStocksList, ...controller.pressCryptoList];

      merged.sort((a, b) {
        DateTime pa, pb;
        try {
          pa = DateTime.parse(a.publishedDate ?? '').toLocal();
        } catch (_) {
          pa = DateTime.fromMillisecondsSinceEpoch(0);
        }
        try {
          pb = DateTime.parse(b.publishedDate ?? '').toLocal();
        } catch (_) {
          pb = DateTime.fromMillisecondsSinceEpoch(0);
        }
        return pb.compareTo(pa); // newest first
      });

      return merged;
    }
  }
}
