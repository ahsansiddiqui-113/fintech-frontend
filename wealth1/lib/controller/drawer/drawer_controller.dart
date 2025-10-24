import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart' show AppEndpoints;
class CustomDrawerController extends GetxController {
  RxString? userId = RxString('');
  RxString? fullName = RxString('');
  RxString? token = RxString('');

  @override
  void onInit() {
    super.onInit();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId?.value = prefs.getString('userId') ?? '';
    fullName?.value = prefs.getString('name') ?? '';
    token?.value = prefs.getString('auth_token') ?? '';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('name');
    await prefs.setBool('isLoggedIn', false);

    // await prefs.clear();

    // // Reset GetX: clears all controllers, bindings, services
    // Get.reset();

    Get.deleteAll(force: true);
  }
  Future<void> deleteUserAccount() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await BaseClient().delete(AppEndpoints.Delete, {});
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back();
      if (response != null && response['status'] == true) {
        Get.rawSnackbar(
          title: 'Success',
          message: response['message'] ??
              'Your account has been scheduled for deletion. You have 7 days to restore it.',
          backgroundColor: Get.context!.gc(AppColor.primary),
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        );

      } else {
        Get.rawSnackbar(
          title: 'Error',
          message: response?['message'] ?? 'Failed to delete account. Please try again.',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        );
      }
    } catch (e, stack) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Delete Account Error: $e\n$stack');
      Get.rawSnackbar(
        title: 'Error',
        message: 'Something went wrong. Please check your connection and try again.',
        backgroundColor: Get.context!.gc(AppColor.redColor),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }


  @override
  void onClose() {
    super.onClose();
  }
}
