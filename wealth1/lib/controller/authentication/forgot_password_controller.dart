import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/VERIFICATION/enter_authentication_code_page.dart';
import 'package:wealthnx/controller/authentication/change_password_controller.dart';
import 'package:wealthnx/home-screens/change_password.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';

import '../../services/crypto_news_services.dart';

class ForgotPasswordController extends GetxController {
  final ApiService _apiService = ApiService();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  // var isLoading = false.obs;

  void forgotPassSendOtp() async {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final email = emailController.text.trim();

    try {
      final response = await _apiService.forgotPassword(email);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.back();
        Get.to(() => EnterAuthenticationCodePage(
              phoneNumber: email,
              isNewUser: false,
            ));

        Get.snackbar(
            "Success", data["message"] ?? "Reset link sent to your email.");
      } else {
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar("Error", error["message"] ?? "Something went wrong");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    } finally {
      //  Get.back();
      // isLoading.value = false;
    }
  }

  // verify otp
  void forgotVerifyOtp() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final otpControl = otpController.text.trim();

    print("OTP data : $otpControl");

    try {
      final response = await _apiService.forgotOtpVerify(
          otpCode: otpControl, email: emailController.text.trim());

      print("Response:..... Otp Verify ${response.body}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.back();
        Get.to(() => ChangePassword(
              forgotPassword: true,
            ));

        Get.snackbar("Success", data["message"] ?? "your otp is verified.");
      } else {
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar("Error", error["message"] ?? "Your otp is not verified");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    } finally {
      //  Get.back();
      // isLoading.value = false;
    }
  }

  // changed password....
  void forgotChangePassword() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    // final newPasswordControl = newPasswordController.text.trim();

    try {
      final response = await _apiService.forgotChangePassword(
          email: emailController.text.trim(),
          password: Get.put(ChangePasswordController()).newPassword.text.trim(),
          otpCode: otpController.text.trim());

      print("Forgot Change Password Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Get.back();
        emailController.clear();
        otpController.clear();
        Get.put(ChangePasswordController()).newPassword.clear();
        Get.offAll(() => LoginPage());

        Get.snackbar("Success", data["message"] ?? "your password is changed.");
      } else {
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar(
            "Error", error["message"] ?? "Your password is not changed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    } finally {
      //  Get.back();
      // isLoading.value = false;
    }
  }

//ChangePassword
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
