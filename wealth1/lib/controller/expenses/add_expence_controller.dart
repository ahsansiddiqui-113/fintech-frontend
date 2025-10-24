import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/models/expense/add_expense_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';

class AddExpensesController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController incomeNameController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();

  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final selectedIncomeType = 'Shopping'.obs;
  final isLoading = false.obs;

  final addExpenceModel = Rx<AddExpenseModel?>(null);

  final List<String> incomeTypes = [
    'Shopping',
    'Food',
    'Entertainment',
    'Travel',
    'Housing',
    'Other'
  ];

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      paymentDateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> postAddExpense() async {
    if (!formKey.currentState!.validate()) return;

    // isLoading.value = true;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    try {
      final name = incomeNameController.text;
      final category = selectedIncomeType.toString();
      final amount = incomeAmountController.text;
      final date = paymentDateController.text;

      final response = await BaseClient().post('${AppEndpoints.addExpenses}', {
        "category": category,
        "amount": amount,
        "date": date,
        "description": name,
        "isRecurring": false,
        "recurrenceInterval": null,
        "nextOccurrence": null
      });

      if (response != null) {
        Get.back(); // Loading Dialog Close

        Get.put(ExpensesController()).fetchExpense();

        // Delay lagao taake pehle Dialog band ho, phir Snackbar dikhe
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            'Success',
            'Expense Added Successfully',
            backgroundColor: Get.context!.gc(AppColor.primary),
            colorText: Get.context!.gc(AppColor.white),
            duration: const Duration(seconds: 2),
          );

          // Phir 2 second baad page se back jao
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
            Get.back();
          });
        });
        Get.back();

        incomeNameController.clear();
        incomeAmountController.clear();
        paymentDateController.clear();
        isLoading.value = false;
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
}
