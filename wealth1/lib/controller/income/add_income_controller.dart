import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/models/income/add_income_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';

class IncomeAddedController extends GetxController {
  // final formKey = GlobalKey<FormState>();
  final TextEditingController incomeNameController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();

  final selectedIncomeType = 'Monthly'.obs;
  final isLoading = false.obs;

  final addIncomeModel = Rx<AddIncomeModel?>(null);

  void updateIncomeType(String? newValue) {
    if (newValue != null) {
      selectedIncomeType.value = newValue;
    }
  }

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

  // void saveIncome() {
  //   // Validate inputs
  //   if (incomeNameController.text.isEmpty ||
  //       incomeAmountController.text.isEmpty ||
  //       paymentDateController.text.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'Please fill all required fields',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }

  //   isLoading.value = true;

  //   // Here you would typically save to database/API
  //   // For now, we'll just navigate after a delay
  //   Future.delayed(const Duration(seconds: 1), () {
  //     isLoading.value = false;
  //     Get.back(); // Or use Get.offNamed to remove current route
  //   });
  // }

  Future<void> postAddIncome() async {
    // if (!formKey.currentState!.validate()) return;

    Get.dialog(Center(
      child: CircularProgressIndicator(
        color: Get.context!.gc(AppColor.primary),
      ),
    ));

    // isLoading.value = true;
    try {
      final name = incomeNameController.text;
      final category = selectedIncomeType.toString();
      final amount = incomeAmountController.text;
      final date = paymentDateController.text;
      // final descrption = descriptionController.text;

      final response = await BaseClient().post('${AppEndpoints.addIncome}', {
        "name": name,
        "type": category,
        "amount": amount,
        "paymentDate": date,
      });

      if (response != null) {
        Get.back(); // Loading Dialog Close
        print('Responce In Fun: ${response}');

        Get.put(IncomeController()).fetchIncome();

        // Delay lagao taake pehle Dialog band ho, phir Snackbar dikhe
        /*Future.delayed(const Duration(milliseconds: 300), () {
          // Get.snackbar(
          //   'Success',
          //   'Income Added Successfully',
          //   backgroundColor: Get.context!.gc(AppColor.primary),
          //   colorText: Get.context!.gc(AppColor.white),
          //   duration: const Duration(seconds: 2),
          // );

          // Phir 2 second baad page se back jao
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
            // Get.back();
          });
        });*/
        Get.back();

        incomeNameController.clear();
        incomeAmountController.clear();
        paymentDateController.clear();

        // isLoading.value = false;
      }/*if (response != null) {
        addIncomeModel.value = AddIncomeModel.fromJson(response);

        // print('Responce In Fun: ${response}');
        Get.back(); // Navigate back to the previous screen

        Get.snackbar(
          'Success'.tr,
          '${addIncomeModel.value?.message}'.tr,
          backgroundColor: Get.context!.gc(AppColor.primary),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );

        incomeNameController.clear();
        incomeAmountController.clear();
        paymentDateController.clear();

        // Get.offAll(() => Dashboard());
        // isLoading.value = false;
        // Get.back(); // Navigate back to the previous screen
      } */else {
        print('Responce In Fun....: ${response}');
        // Get.snackbar(
        //   'Error'.tr,
        //   '${response}',
        //   backgroundColor: Get.context!.gc(AppColor.redColor),
        //   colorText: Get.context!.gc(AppColor.white),
        //   duration: const Duration(seconds: 2),
        // );
        // isLoading.value = false;
        Get.back(); // Navigate back to the previous screen
      }
    } catch (error) {
      print('Data : ${error}');
      // isLoading.value = false;
      Get.back(); // Navigate back to the previous screen
    }
  }

  @override
  void onClose() {
    incomeNameController.dispose();
    incomeAmountController.dispose();
    paymentDateController.dispose();
    // descriptionController.dispose();
    super.onClose();
  }
}
