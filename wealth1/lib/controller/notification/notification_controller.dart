import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/notification/notification_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  var groupedNotifications = <String, List<AppNotification>>{}.obs;
  var isLoading = false.obs;

  // Notification settings
  var portfolioUpdate = false.obs;
  var newsNotification = false.obs;
  var schedulePayments = true.obs;
  var investmentsUpdate = false.obs;
  var dailyRecap = false.obs;
  var stockInsights = false.obs;
  var cryptoWalletUpdate = false.obs;

  @override
  void onInit() {
    fetchNotifications();
    super.onInit();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final response = await BaseClient().get(AppEndpoints.notifications);
      if (response == null) {
        return;
      }
      final notificationResponse = NotificationResponse.fromJson(response);
      if (!notificationResponse.status) {
        return;
      }

      List<AppNotification> fetched = notificationResponse.body.notifications;
      if (fetched.isEmpty) {
        groupedNotifications.clear();
        return;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final twoDaysLater = today.add(Duration(days: 2));

      fetched = fetched.where((n) {
        final dueDate = DateTime(
          n.data.dueDate.year,
          n.data.dueDate.month,
          n.data.dueDate.day,
        );

        return dueDate.isAtSameMomentAs(today) ||
            (dueDate.isAfter(today) && dueDate.isBefore(twoDaysLater.add(Duration(days: 1))));
      }).toList();
      fetched.sort((a, b) => a.data.dueDate.compareTo(b.data.dueDate));
      // Group by dueDate
      Map<String, List<AppNotification>> grouped = {};
      for (var notif in fetched) {
        String dateKey;
        final dueDate = notif.data.dueDate;
        if (isSameDate(dueDate, now)) {
          dateKey = 'Today';
        }  else {
          dateKey = DateFormat('MM/dd/yyyy').format(dueDate);
        }

        grouped.putIfAbsent(dateKey, () => []).add(notif);
      }

      notifications.assignAll(fetched);
      groupedNotifications.assignAll(grouped);
      print('Notifications loaded: ${fetched.length}');
      print('Grouped notifications: ${grouped.keys}');
    } catch (e, stackTrace) {
      print('Error fetching notifications: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading(false);
    }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get settings map
  Map<String, RxBool> getSetting() => {
    "Everyday Portfolio Update": portfolioUpdate,
    "News Notification": newsNotification,
    "Schedule Payments": schedulePayments,
    "Investments Update": investmentsUpdate,
    "Daily Recap": dailyRecap,
    "Stock Insights": stockInsights,
    "Crypto Wallet Update": cryptoWalletUpdate,
  };

  // Update individual setting
  void updateSetting(String key, bool value) {
    switch (key) {
      case "Everyday Portfolio Update":
        portfolioUpdate.value = value;
        break;
      case "News Notification":
        newsNotification.value = value;
        break;
      case "Schedule Payments":
        schedulePayments.value = value;
        break;
      case "Investments Update":
        investmentsUpdate.value = value;
        break;
      case "Daily Recap":
        dailyRecap.value = value;
        break;
      case "Stock Insights":
        stockInsights.value = value;
        break;
      case "Crypto Wallet Update":
        cryptoWalletUpdate.value = value;
        break;
    }
  }
}