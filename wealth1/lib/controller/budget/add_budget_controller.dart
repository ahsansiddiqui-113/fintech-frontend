import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/budget/add_budget_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';

import 'budget_controller.dart';

class AddBudgetController extends GetxController {
  // Constants
  static const List<String> categories = [
    'Food',
    'Housing',
    'Shopping',
    'Travel',
    'Salary',
    'Utilities',
    'Transportation',
    'Entertainment',
    'Other'
  ];
  final budgetDateController = TextEditingController();
  // State variables
  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedIncomeType = 'Food'.obs;

  final isLoading = false.obs;

  // Controllers
  final TextEditingController budgetAmountController = TextEditingController();

  final addBudgetModel = Rx<AddBudgetModel?>(null);

  Future<void> postAddIncome() async {
    // if (!formKey.currentState!.validate()) return;

    // isLoading.value = true;
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    try {
      final category = selectedIncomeType.toString();
      final amount = budgetAmountController.text;

      final response = await BaseClient().post('${AppEndpoints.addBudget}', {
        "category": category,
        "budgetAmount": amount,
      });

      if (response != null) {
        // Get.back(); // Loading Dialog Close

        final budgetCtrl = Get.isRegistered<BudgetController>()
            ? Get.find<BudgetController>()
            : Get.put(BudgetController());
        budgetCtrl.fetchBudgets(force: true);

        // Delay lagao taake pehle Dialog band ho, phir Snackbar dikhe
        // Future.delayed(const Duration(milliseconds: 300), () {
        //
        //   // Phir 2 second baad page se back jao
        //   Future.delayed(const Duration(seconds: 1), () {
        //     Get.back();
        //     Get.back();
        //   });
        // });
        Get.back();
        // Get.snackbar(
        //   'Success',
        //   'Budget Added Successfully',
        //   backgroundColor: Get.context!.gc(AppColor.primary),
        //   colorText: Get.context!.gc(AppColor.white),
        //   // duration: const Duration(seconds: 2),
        // );
        // Future.delayed(const Duration(seconds: 3), () {
        //       Get.back();
        Get.back();
        Get.snackbar(
          'Success',
          'Budget Added Successfully',
          backgroundColor: Get.context!.gc(AppColor.primary),
          colorText: Get.context!.gc(AppColor.white),
          // duration: const Duration(seconds: 2),
        );
        // });

        budgetAmountController.clear();
      } else {
        Get.snackbar(
          'Error'.tr,
          '${response}',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );
        // isLoading.value = false;
        Get.back();
      }
    } catch (error) {
      print('Data : ${error}');
      // isLoading.value = false;
      Get.back();
    }
  }

  Future<void> updateBudget(id, category, amount) async {
    // if (!formKey.currentState!.validate()) return;

    // isLoading.value = true;
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    try {
      // final category = selectedIncomeType.toString();
      // final amount = budgetAmountController.text;

      customLog("Id: $id, Category: $category, Amount: $amount");

      final response = await BaseClient().put('${AppEndpoints.addBudget}/$id',  {"category": category, "budgetAmount": amount});

      if (response != null) {
        // Get.back(); // Loading Dialog Close

        print("OutPut print: $response");
        final budgetCtrl = Get.find<BudgetController>();
        await budgetCtrl.fetchBudgets(force: true);
        // budgetCtrl.updateBudgetLocally(id: id, newCategoryName: category, newBudgetAmount: amount,newBudgetRemaining: amount);
        // Get.put(BudgetController()).fetchBudgets();

        Get.back();

        Get.back();
        Get.snackbar(
          'Success',
          'Budget Updated Successfully',
          backgroundColor: Get.context!.gc(AppColor.primary),
          colorText: Get.context!.gc(AppColor.white),
          // duration: const Duration(seconds: 2),
        );
        // });

        budgetAmountController.clear();
      } else {
        Get.snackbar(
          'Error'.tr,
          '${response}',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );
        // isLoading.value = false;
        Get.back();
      }
    } catch (error) {
      print('Data : ${error}');
      // isLoading.value = false;
      Get.back();
    }

  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    selectedCategories.refresh();
  }

  @override
  void onClose() {
    budgetAmountController.dispose();
    super.onClose();
  }
}
