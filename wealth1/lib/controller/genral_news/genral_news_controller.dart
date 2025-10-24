import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
import 'package:wealthnx/services/crypto_news_services.dart';

class NewsController extends GetxController {
  final ApiService _apiService = ApiService();

  /// Tabs on ViewAllNewsPage: 0 = All, 1 = Stocks, 2 = Crypto
  final selectedCategoryIndex = 0.obs;

  /// General "trending" feed (source for Trending carousel)
  final newsList = <CryptoNewsModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final errorMessage = ''.obs;
  int page = 0;
  final int limit = 10;
  final hasMoreData = true.obs;

  /// Press Release: split into Stocks & Crypto
  final pressStocksList = <CryptoNewsModel>[].obs;
  final pressCryptoList = <CryptoNewsModel>[].obs;

  // Stocks state
  final isPressStocksLoading = false.obs;
  final isMorePressStocksLoading = false.obs;
  final errorPressStocks = ''.obs;
  int pagePressStocks = 0;
  final hasMoreStocks = true.obs;

  // Crypto state
  final isPressCryptoLoading = false.obs;
  final isMorePressCryptoLoading = false.obs;
  final errorPressCrypto = ''.obs;
  int pagePressCrypto = 0;
  final hasMoreCrypto = true.obs;

  /// View All should load 10 each time
  final int limitPress = 10;

  /// --- UI getters ---

  /// Trending: up to 6 items from general feed
  List<CryptoNewsModel> get trending6 =>
      newsList.length <= 6 ? newsList : newsList.take(6).toList();

  /// All tab on main screen: 3 stocks + 3 crypto (total 6)
  List<CryptoNewsModel> get allMix6 {
    final s = pressStocksList.take(3).toList();
    final c = pressCryptoList.take(3).toList();
    return [...s, ...c];
  }

  /// Current items for main screen list (capped to 6 in the widget)
  List<CryptoNewsModel> get currentItems {
    switch (selectedCategoryIndex.value) {
      case 1:
        return pressStocksList.take(6).toList();
      case 2:
        return pressCryptoList.take(6).toList();
      default:
        return allMix6;
    }
  }

  /// Switch category and (re)load minimal data
  Future<void> selectCategory(int index) async {
    selectedCategoryIndex.value = index;

    if (index == 0) {
      if (newsList.isEmpty) {
        await fetchPaginatedNews(isFirstLoad: true);
      }
      await _ensureMinimumForAll();
    } else if (index == 1) {
      if (pressStocksList.isEmpty) {
        await fetchPressRelease(type: 'Stocks', isFirstLoad: true);
      }
    } else {
      if (pressCryptoList.isEmpty) {
        await fetchPressRelease(type: 'Crypto', isFirstLoad: true);
      }
    }
  }

  /// General feed (source for Trending)
  Future<void> fetchPaginatedNews({bool isFirstLoad = false}) async {
    if (isFirstLoad) {
      newsList.clear();
      page = 0;
      hasMoreData(true);
      errorMessage('');
    }
    if (!hasMoreData.value || isLoading.value || isMoreLoading.value) return;

    try {
      (isFirstLoad ? isLoading : isMoreLoading).value = true;

      final newNews = await _apiService.fetchGeneralNewsWithPagination(
        page: page,
        limit: limit,
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

  /// Press release lists (separate states for Stocks/Crypto)
  Future<void> fetchPressRelease({
    required String type, // 'Stocks' | 'Crypto'
    bool isFirstLoad = false,
  }) async {
    final isStocks = type == 'Stocks';

    // refs
    final list = isStocks ? pressStocksList : pressCryptoList;
    final isLoadingRx = isStocks ? isPressStocksLoading : isPressCryptoLoading;
    final isMoreRx = isStocks ? isMorePressStocksLoading : isMorePressCryptoLoading;
    final errorRx = isStocks ? errorPressStocks : errorPressCrypto;
    final hasMoreRx = isStocks ? hasMoreStocks : hasMoreCrypto;

    if (isFirstLoad) {
      list.clear();
      if (isStocks) {
        pagePressStocks = 0;
        hasMoreStocks(true);
      } else {
        pagePressCrypto = 0;
        hasMoreCrypto(true);
      }
      errorRx('');
    }

    if (!hasMoreRx.value || isLoadingRx.value || isMoreRx.value) return;

    try {
      (isFirstLoad ? isLoadingRx : isMoreRx).value = true;

      final pageToUse = isStocks ? pagePressStocks : pagePressCrypto;

      final newNews = await _apiService.fetchPressReleaseNewsWithPagination(
        page: pageToUse,
        limit: limitPress, // 10
        cryptoType: type,
      );

      if (newNews.isEmpty) {
        hasMoreRx(false);
      } else {
        list.addAll(newNews);
        if (isStocks) {
          pagePressStocks++;
        } else {
          pagePressCrypto++;
        }
      }
    } catch (e) {
      errorRx(e.toString());
    } finally {
      isLoadingRx(false);
      isMoreRx(false);
    }
  }

  /// Ensure All tab can show 3 stocks + 3 crypto
  Future<void> _ensureMinimumForAll() async {
    if (pressStocksList.length < 3) {
      await fetchPressRelease(type: 'Stocks', isFirstLoad: pressStocksList.isEmpty);
    }
    if (pressCryptoList.length < 3) {
      await fetchPressRelease(type: 'Crypto', isFirstLoad: pressCryptoList.isEmpty);
    }
  }

  // ---- Formatting helpers ----

  String formatDateTime(String? dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString ?? '').toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return 'Invalid Date';
    }
  }

  /// Returns "Just now", "12 min ago", "3 hours ago", "Yesterday", "5 days ago", etc.
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


  /// 🔹 only for tab switching shimmer (bottom list)
  final isTabLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial data load for "All" without tab shimmer
    selectedCategoryIndex.value = 0;
    selectCategory(0);
  }

  /// 🔹 switch tab -> show 1s shimmer on bottom list, then reveal items
  Future<void> switchCategoryWithShimmer(int index) async {
    isTabLoading(true);
    selectedCategoryIndex.value = index;

    if (index == 0) {
      if (newsList.isEmpty) {
        await fetchPaginatedNews(isFirstLoad: true);
      }
      await _ensureMinimumForAll();
    } else if (index == 1) {
      if (pressStocksList.isEmpty) {
        await fetchPressRelease(type: 'Stocks', isFirstLoad: true);
      }
    } else {
      if (pressCryptoList.isEmpty) {
        await fetchPressRelease(type: 'Crypto', isFirstLoad: true);
      }
    }

    // keep shimmer visible for 1 second
    await Future.delayed(const Duration(seconds: 1));
    isTabLoading(false);
  }

}
