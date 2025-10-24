import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final reNewPassword = TextEditingController();
  final isCurrentPassVis = false.obs;
  final isNewPassVis = false.obs;
  final isConfPassVis = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isCurrentPassVis.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPassVis.toggle();
  }

  void toggleConfPasswordVisibility() {
    isConfPassVis.toggle();
  }

  Future<void> changePassword() async {
    try {
      if (!formKey.currentState!.validate()) return;

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(AppEndpoints.baseUrl + 'change-password'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken'
        },
        body: jsonEncode({
          'oldPassword': oldPassword.text.trim(),
          'newPassword': newPassword.text.trim(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Success - password changed
        oldPassword.clear();
        newPassword.clear();
        reNewPassword.clear();

        Get.back(); // Close dialog
        Get.back(); // Go back to previous screen
        Get.snackbar(
          'Success',
          'Change password successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 400) {
        // Bad request - likely old password same as new password
        Get.back(); // Close dialog

        String errorMessage = 'New password cannot be the same as old password';

        // Try to decode the response body if it exists
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            errorMessage = data['message'] ?? errorMessage;
            print('Error message from server: $errorMessage');
          } catch (e) {
            print('Could not decode response body: $e');
          }
        }
        Get.snackbar("Error", errorMessage);
      } else if (response.statusCode == 401) {
        Get.back();
        Get.snackbar(
          'Error',
          'Old password is incorrect.'
        );
      } else {
        Get.back(); // Close dialog
        String errorMessage = 'Failed to change password';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (_) {}

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Network error: Please check your connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('Change password error: $e');
    }
  }

  @override
  void onClose() {
    oldPassword.dispose();
    newPassword.dispose();
    reNewPassword.dispose();
    super.onClose();
  }
}