import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/controller/authentication/forgot_password_controller.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/models/auth/signin_model.dart';
import 'package:wealthnx/providers/user_provider.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

import '../../VERIFICATION/enter_authentication_code_page.dart';

class SignupController extends GetxController {
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isAgreed = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final signUpModel = Rx<SignInModel?>(null);

  final Rxn<UserModel> _user = Rxn<UserModel>();
  final RxString _token = ''.obs;


  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleTermsAgreement(bool? value) {
    if (value != null) {
      isAgreed.value = value;
    }
  }

  void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> signUp() async {
    // if (!formKey.currentState!.validate()) return;
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    // isLoading.value = true;
    try {
      final fullname = nameController.text;
      final email = emailController.text.trim();
      final password = passwordController.text;

      final response = await BaseClient().post(
          '${AppEndpoints.signUp}',
          {
            'fullName': fullname,
            'email': email,
            'password': password,
            "otp": Get.put(ForgotPasswordController()).otpController.text.trim()
          },
          isCustom: true);
      print('Responce In Fun: ${response.statusCode}');
      if (response != null) {
        signUpModel.value = SignInModel.fromJson(response);

        _token.value = signUpModel.value?.body?.token ?? '';
        _user.value = UserModel(
            id: signUpModel.value?.body?.userId ?? '',
            fullName: signUpModel.value?.body?.name ?? '',
            email: signUpModel.value?.body?.email ?? '',
            token: signUpModel.value?.body?.token ?? '');



        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _user.value!.id);
        await prefs.setString('auth_token', _token.value);
        await prefs.setString('name', _user.value!.fullName);
        await prefs.setString('email', email);
        await prefs.setBool('isLoggedIn', true);

        Get.snackbar(
          'Success'.tr,
          'Login Successful'.tr,
          backgroundColor: Get.context!.gc(AppColor.primary),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );

        emailController.clear();
        passwordController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.put(NewsController()).fetchPaginatedNews(isFirstLoad: true);
          Get.put(PressReleaseNewsController())
              .fetchPaginatedNews(isFirstLoad: true);

          // if (!_tarnsController.hasFetched.value) {
          //   _tarnsController.fetchTransations();
          // }
        });
        Get.back();
        Get.offAll(() => Dashboard());
        // isLoading.value = false;
      } else {
        Get.back();
        Get.snackbar(
          'Error'.tr,
          '${response}',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );
        // isLoading.value = false;
      }
    } catch (error) {
      Get.back();
      print('Data : ${error}');
      // isLoading.value = false;
    }
  }

/*  final  otpController = TextEditingController();
  final  newPasswordController = TextEditingController();*/
  // var isLoading = false.obs;
// send otp
  void signupSendOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final email = emailController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('${AppEndpoints.baseUrl}${AppEndpoints.sendOtp}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.back();
        Get.to(() =>
            EnterAuthenticationCodePage(phoneNumber: email, isNewUser: true));

        Get.snackbar("Success", data["message"] ?? "Otp sent to your email.");
      } else {
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar("Error", error["message"] ?? "Something went wrong");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    }
  }

  // verify otp
  void signupVerifyOtp() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final otpControl =
        Get.put(ForgotPasswordController()).otpController.text.trim();
     final email = Get.find<SignupController>().emailController.text.trim();
    try {
      final response = await http.post(
        Uri.parse('${AppEndpoints.baseUrl}verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'email': email, 'otp': otpControl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.back();
        await signUp();
        // Get.to(()=> ChangePassword(forgotPassword: true,));

        Get.snackbar("Success", data["message"] ?? "your otp is verified.");
      } else {
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar("Error", error["message"] ?? "Your otp is not verified");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
