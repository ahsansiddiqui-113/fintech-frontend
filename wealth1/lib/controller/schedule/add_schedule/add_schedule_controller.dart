import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';

/// Simple model you can extend later
class Schedule {
  final String title;
  final double amount;
  final String date; // keeping as formatted string for now
  final String? time;
  final String? tag;
  final String description;

  final Rx<RecurrenceInterval> recurrence = RecurrenceInterval.weekly.obs;

  Schedule({
    required this.title,
    required this.amount,
    required this.date,
    this.time,
    this.tag,
    required this.description,
  });
}

enum RecurrenceInterval {
  daily,
  weekly,
  biweekly,
  semimonthly,
  monthly,
  yearly
}
enum Category {
  ENTERTAINMENT,
  FOOD_AND_DRINK,
  GENERAL_MERCHANDISE,
  GENERAL_SERVICES,
  INCOME,
  INVESTMENTS_CONTRIBUTION,
  INVESTMENTS_DIVIDEND,
  INVESTMENTS_INTEREST,
  INVESTMENTS_SELL,
  LOAN_PAYMENTS,
  PERSONAL_CARE,
  TRANSPORTATION,
  TRAVEL,
  Utility,
  Other,
}

extension RecurrenceLabel on RecurrenceInterval {
  String get label {
    switch (this) {
      case RecurrenceInterval.daily:
        return 'Daily';
      case RecurrenceInterval.weekly:
        return 'Weekly';
      case RecurrenceInterval.biweekly:
        return 'Biweekly';
      case RecurrenceInterval.semimonthly:
        return 'Semi-Monthly';
      case RecurrenceInterval.monthly:
        return 'Monthly';
      case RecurrenceInterval.yearly:
        return 'Annually';
    }
  }
  /// Exact string your API wants (lowercase)
  String get apiValue => name;
}
extension CategoryLabel on Category {
  String get label {
    switch (this) {
      case Category.ENTERTAINMENT: return 'Entertainment';
      case Category.FOOD_AND_DRINK: return 'Food & Drink';
      case Category.GENERAL_MERCHANDISE: return 'General Merchandise';
      case Category.GENERAL_SERVICES: return 'General Services';
      case Category.INCOME: return 'Income';
      case Category.INVESTMENTS_CONTRIBUTION: return 'Investments (Contribution)';
      case Category.INVESTMENTS_DIVIDEND: return 'Investments (Dividend)';
      case Category.INVESTMENTS_INTEREST: return 'Investments (Interest)';
      case Category.INVESTMENTS_SELL: return 'Investments (Sell)';
      case Category.LOAN_PAYMENTS: return 'Loan Payments';
      case Category.PERSONAL_CARE: return 'Personal Care';
      case Category.TRANSPORTATION: return 'Transportation';
      case Category.TRAVEL: return 'Travel';
      case Category.Utility: return 'Utility';
      case Category.Other: return 'Other';
    }
  }

  /// Exact string your API wants
  String get apiValue {
    switch (this) {
      case Category.ENTERTAINMENT: return 'entertainment';
      case Category.FOOD_AND_DRINK: return 'food_and_drink';
      case Category.GENERAL_MERCHANDISE: return 'general_merchandise';
      case Category.GENERAL_SERVICES: return 'general_services';
      case Category.INCOME: return 'income';
      case Category.INVESTMENTS_CONTRIBUTION: return 'investments_contribution';
      case Category.INVESTMENTS_DIVIDEND: return 'investments_dividend';
      case Category.INVESTMENTS_INTEREST: return 'investments_interest';
      case Category.INVESTMENTS_SELL: return 'investments_sell';
      case Category.LOAN_PAYMENTS: return 'loan_payments';
      case Category.PERSONAL_CARE: return 'personal_care';
      case Category.TRANSPORTATION: return 'transportation';
      case Category.TRAVEL: return 'travel';
      case Category.Utility: return 'utility';
      case Category.Other: return 'other';
    }
  }
}
class AddScheduleController extends GetxController {
  final formKey = GlobalKey<FormState>();

  /// Form Controllers
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final tagController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final Rx<Category?> selectedCategory = Rx<Category?>(null);
  final Rx<RecurrenceInterval?> recurrence = Rx<RecurrenceInterval?>(null);

  final RxList<Schedule> schedules = <Schedule>[].obs;

  void setDate(DateTime picked) {
    dateController.text = "${picked.month}/${picked.day}/${picked.year}";
  }

  void setTime(TimeOfDay picked) {
    timeController.text = picked.format(Get.context!);
  }

  void setRecurrence(RecurrenceInterval? value) {
    recurrence.value = value;
  }

  void setCategory(Category? value) {
    selectedCategory.value = value;
  }

  /// Reusable snackbar helper
  void showSnack(String title, String message, {bool success = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  final isSaving = false.obs;

  Future<bool> saveSchedule() async {
    if (isSaving.value) return false;                 // prevent double-taps
    if (!formKey.currentState!.validate()) return false;

    // Validate amount
    final amountText = amountController.text.trim();
    final parsedAmount = double.tryParse(amountText);
    // if (parsedAmount == null) {
    //   Get.snackbar(
    //     'Invalid',
    //     'Amount must be a number',
    //     backgroundColor: Get.context!.gc(AppColor.redColor),
    //     colorText: Get.context!.gc(AppColor.white),
    //     duration: const Duration(seconds: 2),
    //   );
    //   return false;
    // }

    // Validate date
    final pickedDateUi = dateController.text.trim();
    if (pickedDateUi.isEmpty) {
      Get.snackbar(
        'Missing Date',
        'Please select date',
        backgroundColor: Get.context!.gc(AppColor.redColor),
        colorText: Get.context!.gc(AppColor.white),
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    // Build safe values
    final String name = titleController.text.trim();
    final String dateApi = _toApiDate(pickedDateUi);
    final String? description =  descriptionController.text.isEmpty ? null : descriptionController.text;
    final String? categoryApi = selectedCategory.value?.apiValue ?? 'other';
    final String? recurrenceApi = recurrence.value?.apiValue ?? 'onetime';

    final payload = {
      "name": name,
      "category": categoryApi,
      "amount": parsedAmount?.toInt() ?? 0,
      "date": dateApi,
      "description": description,
      "recurrenceInterval": recurrenceApi,
    };
    isSaving(true);
    // Lightweight blocking loader (auto closed in finally)
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await BaseClient().post(AppEndpoints.expenseRecur, payload);

      // Be strict about success; don’t treat any non-null as success
      final bool ok = response is Map<String, dynamic>
          ? (response['status'] == true || response['success'] == true)
          : false;

      if (!ok) {
        final msg = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : 'Failed';
        _showError(msg);
        return false;
      }
      _clearFields();
      try {
        final sched = Get.isRegistered<ScheduleController>()
            ? Get.find<ScheduleController>()
            : Get.put(ScheduleController());
        // ignore: unawaited_futures
        sched.fetchSchedules(DateTime.now());
        sched.rebuildFor(DateTime.now());
      } catch (_) {
        // safe to ignore; not critical to the save flow
      }

      return true;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isSaving(false);
      if (Get.isDialogOpen ?? false) Get.back(); // close loader
    }
  }

  void _clearFields() {
    titleController.clear();
    amountController.clear();
    dateController.clear();
    timeController.clear();
    tagController.clear();
    descriptionController.clear();
    categoryController.clear();
    recurrence.value = RecurrenceInterval.weekly;
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Get.context!.gc(AppColor.redColor),
      colorText: Get.context!.gc(AppColor.white),
      duration: const Duration(seconds: 2),
    );
  }

  void resetForm() {
    formKey.currentState?.reset();
    titleController.clear();
    amountController.clear();
    dateController.clear();
    timeController.clear();
    tagController.clear();
    descriptionController.clear();
    categoryController.clear();
    recurrence.value = RecurrenceInterval.weekly;
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    dateController.dispose();
    timeController.dispose();
    tagController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.onClose();
    recurrence.value = null;
    selectedCategory.value = null;
  }

  String _toApiDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return "$year-$day-$month";
      }
      return input;
    } catch (_) {
      return input;
    }
  }
}
