import 'package:get/get.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import '../../models/investment/investment_overview_model.dart';
import '../../services/crypto_news_services.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final exploreItems = <Map<String, dynamic>>[].obs;
  final hubItems = <HubItem>[].obs;
  final isBalanceVisible = true.obs;
  final ApiService _apiService = ApiService();
  var myPortfolio = <CryptoModel>[].obs;
  var isLoadingPortfolio = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchTodaySchedules();
    fetchExpenseCategories();
    // initializeData();

  }
  // Future<void> fetchTodaySchedules() async {
  //   try {
  //     isLoading.value = true; // start shimmer
  //
  //     final controller = Get.put(ScheduleController());
  //     await controller.fetchSchedules(DateTime.now());
  //     final todayList = controller.todaySchedules;
  //
  //     final mapped = todayList.map((item) {
  //       return HubItem(
  //         title: item.name,
  //         description: item.description,
  //         recurralInterval: item.recurrenceInterval,
  //         price: item.amount.toInt().toString(),
  //           date: item.date
  //       );
  //     }).toList();
  //
  //     hubItems.assignAll(mapped);
  //   } catch (e) {
  //     errorMessage.value = e.toString();
  //   } finally {
  //     isLoading.value = false; // stop shimmer
  //   }
  // }

  // void initializeData() {
  //   hubItems.assignAll([
  //     {
  //       "title": "🎬 Streaming Subscription Renewal",
  //       "description":
  //           "Today is the last day for paying Sub of Netflix otherwise the account will be suspended",
  //       "priority": "Urgent",
  //       "date": "Today",
  //     },
  //     {
  //       "title": "🎬 Streaming Subscription Renewal",
  //       "description":
  //           "Today is the last day for paying Sub of Netflix otherwise the account will be suspended",
  //       "priority": "Normal",
  //       "date": "Today",
  //     },
  //     // Add other hub items...
  //   ]);
  // }

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }

  // my protofolio

  // expense category summary


  Future<void> fetchExpenseCategories() async {
    try {
      isLoadingPortfolio.value = true;
      errorMessage.value = '';
      final data = await _apiService.fetchHomeMyPortfolio();
      myPortfolio.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      // Get.snackbar('Error', errorMessage.value,
      //     snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPortfolio.value = false;
    }
  }
}


class HubItem {
  final String title;
  final String description;
  final String recurralInterval;
  final String price;
  final DateTime date;

  HubItem({
    required this.title,
    required this.description,
    required this.recurralInterval,
    required this.price,
    required this.date,
  });
}
