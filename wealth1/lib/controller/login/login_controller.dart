import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/models/auth/signin_model.dart';
import 'package:wealthnx/providers/user_provider.dart';
import 'package:wealthnx/services/crypto_news_services.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();

  // final GlobalKey<FormState> formKeylogin = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final logInModel = Rx<SignInModel?>(null);

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final RxString _token = ''.obs;

  final signUpModel = Rx<SignInModel?>(null);

  final LocalAuthentication auth = LocalAuthentication();

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> loginWithBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      // final userId = prefs.getString('userId');
      // final email = prefs.getString('email');
      // final password = prefs.getString('password');
      final bioUserId = prefs.getString('bioUserId');
      final bioEmail = prefs.getString('bioEmail');
      final bioPassword = prefs.getString('bioPassword');

      if (canCheckBiometrics) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Scan your face to login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }

      if (isAuthenticated) {
        if (bioUserId.toString() == '' || bioUserId.toString().isEmpty) {
          Get.snackbar("Failed", "Biometric not Enable");
        } else {
          print('Email: $bioEmail');
          print('Password: $bioPassword');
          signInBio(bioEmail, bioPassword);
        }
      } else {
        Get.snackbar("Failed", "Biometric authentication failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Biometric auth error: $e");
    }
  }

  Future<void> signInBio(email, password) async {
    // if (!formKey.currentState!.validate()) return;

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      print('Email: $email');
      print('Password: $email');
      // final email = emailController.text.trim();
      // final password = passwordController.text;

      final response =
          await _apiService.loginApi(email: email, password: password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        logInModel.value = SignInModel.fromJson(data);

        _token.value = logInModel.value?.body?.token ?? '';
        _user.value = UserModel(
          id: logInModel.value?.body?.userId ?? '',
          fullName: logInModel.value?.body?.name ?? '',
          email: logInModel.value?.body?.email ?? '',
          token: logInModel.value?.body?.token ?? '',
        );

        // print('Responce In Fun: ${response}');
        print("ddddd ${_user.value!.id} || ${_token.value} ||");
        final prefs = await SharedPreferences.getInstance();

        if (_user.value != null) {

          await prefs.setString('userId', _user.value!.id);
          await prefs.setString('auth_token', _token.value);
          await prefs.setString('name', _user.value!.fullName);
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setBool('isLoggedIn', true);
        }

        Get.snackbar(
          "Success",
          data["message"] ?? "Success",
          backgroundColor: Get.context?.gc(AppColor.primary),
          colorText: Get.context?.gc(AppColor.white),
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
        final error = jsonDecode(response.body);

        Get.snackbar(
          "Error",
          error["message"] ?? "Something went wrong",
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (error) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    }
  }

  Future<void> signIn() async {
    // if (!formKeylogin.currentState!.validate()) return;

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final response =
          await _apiService.loginApi(email: email, password: password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        logInModel.value = SignInModel.fromJson(data);

        _token.value = logInModel.value?.body?.token ?? '';
        _user.value = UserModel(
          id: logInModel.value?.body?.userId ?? '',
          fullName: logInModel.value?.body?.name ?? '',
          email: logInModel.value?.body?.email ?? '',
          token: logInModel.value?.body?.token ?? '',
        );

        // print('Responce In Fun: ${response}');

        final prefs = await SharedPreferences.getInstance();

        if (_user.value != null) {
          await prefs.setString('userId', _user.value!.id);
          await prefs.setString('auth_token', _token.value);
          await prefs.setString('name', _user.value!.fullName);
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setBool('isLoggedIn', true);
        }

        // Get.snackbar(
        //   "Success",
        //   data["message"] ?? "Success",
        //   backgroundColor: Get.context?.gc(AppColor.primary),
        //   colorText: Get.context?.gc(AppColor.white),
        //   duration: const Duration(seconds: 2),
        // );

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
        final error = jsonDecode(response.body);
        Get.back();
        Get.snackbar(
          "Error",
          error["message"] ?? "Something went wrong",
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
          duration: const Duration(seconds: 2),
        );
        // isLoading.value = false;
      }
    } catch (error) {
      Get.back();
      Get.snackbar("Network Error", "Please check your internet connection.");
    }
  }

  // google login sign in api calling

  Future<void> googleSignIn(String userId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final headers = {'Content-Type': 'application/json'};

    final request = http.Request(
      'POST',
      Uri.parse(
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/google-login'),
    );

    request.body = json.encode({"userId": userId});
    request.headers.addAll(headers);

    final response = await request.send();

    // Get.back(); // Close the loading dialog

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      if (decoded['status'] == true) {
        final user = decoded['body'];

        logInModel.value = SignInModel.fromJson(user);

        _token.value = user['token'] ?? '';
        _user.value = UserModel(
          id: user['user_id'] ?? '',
          fullName: user['name'] ?? '',
          email: user['email'] ?? '',
          token: user['token'] ?? '',
        );
        // Store the data (example using GetStorage or shared_preferences)
        print("User ID: ${user['user_id']}");
        print("Token: ${user['token']}");
        print("Refresh Token: ${user['refreshToken']}");
        print("Name: ${user['name']}");
        print("Email: ${user['email']}");
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('userId', user['user_id']);
        await prefs.setString('auth_token', user['token']);
        await prefs.setString('name', user['name']);
        await prefs.setString('email', user['email']);
        // await prefs.setString('password', password);
        await prefs.setBool('isLoggedIn', true);
      }
      Get.back();
      // Or navigate to home screen
      Get.offAll(Dashboard());
    } else {
      Get.back();
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      Get.snackbar('Error', decoded["message"]);
    }
  }

  // for google new user sign up api calling

  Future<void> signupGoogleNewUser({
    required String userId,
    required String userName,
    required String email,
  }) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final headers = {'Content-Type': 'application/json'};

    final request = http.Request(
      'POST',
      Uri.parse(
          'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/google-auth'),
    );

    request.body = json.encode({
      "userId": userId,
      "userName": userName,
      "email": email,
    });

    request.headers.addAll(headers);

    final response = await request.send();

    // Get.back(); // Close the loading dialog

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      if (decoded['status'] == true) {
        final user = decoded['body'];

        logInModel.value = SignInModel.fromJson(user);

        _token.value = user['token'] ?? '';
        _user.value = UserModel(
          id: user['user_id'] ?? '',
          fullName: user['name'] ?? '',
          email: user['email'] ?? '',
          token: user['token'] ?? '',
        );
        print("User ID: ${user['user_id']}");
        print("Token: ${user['token']}");
        print("Refresh Token: ${user['refreshToken']}");
        print("Name: ${user['name']}");
        print("Email: ${user['email']}");

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('userId', user['user_id']);
        await prefs.setString('auth_token', user['token']);
        await prefs.setString('name', user['name']);
        await prefs.setString('email', user['email']);
        // await prefs.setString('password', password);
        await prefs.setBool('isLoggedIn', true);
        // Optional: Store using GetStorage
        // final box = GetStorage();
        // box.write('token', user['token']);
        // box.write('refreshToken', user['refreshToken']);
        // box.write('userId', user['user_id']);
        Get.back();
        // Navigate to next screen or show success
        Get.offAll(Dashboard());
      } else {
        Get.back();
        Get.snackbar('Error', decoded['message'] ?? 'Unknown error occurred');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Step 1: Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.back(); // Close loading dialog
        print("Google sign-in cancelled by user");
        return;
      }

      // Step 2: Get Google Auth tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Step 3: Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        Get.back();
        Get.snackbar(
          'Error'.tr,
          'Failed to authenticate with Firebase',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
        );
        return;
      }

      print("Firebase User ID: ${user.uid}");
      print("Is New User: ${userCredential.additionalUserInfo?.isNewUser}");

      // Step 5: Call backend API (same endpoint for both signup and login)
      final response = await BaseClient().post(
        AppEndpoints.googleNewUserAuth,
        isCustom: true,
        {
          "userId": user.uid,
          "userName": user.displayName ?? '',
          "email": user.email ?? '',
        },
      );

      // Step 6: Handle backend response
      if (response == null || response is! Map<String, dynamic>) {
        Get.back();
        Get.snackbar(
          'Error'.tr,
          'Invalid response from server',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
        );
        return;
      }

      print("✅ Backend Response: $response");

      // Check if backend returned error
      if (response['status'] == false) {
        Get.back();
        Get.snackbar(
          'Error'.tr,
          response['message'] ?? 'Authentication failed',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
        );
        return;
      }

      // Step 7: Parse response
      signUpModel.value = SignInModel.fromJson(response);

      final token = signUpModel.value?.body?.token ?? '';
      final userId = signUpModel.value?.body?.userId ?? '';
      final name = signUpModel.value?.body?.name ?? '';
      final email = signUpModel.value?.body?.email ?? '';

      if (token.isEmpty || userId.isEmpty) {
        Get.back();
        Get.snackbar(
          'Error'.tr,
          'Invalid authentication data received',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          colorText: Get.context!.gc(AppColor.white),
        );
        return;
      }

      // Step 8: Update app state
      _token.value = token;
      _user.value = UserModel(
        id: userId,
        fullName: name,
        email: email,
        token: token,
      );

      print('🟩 User authenticated: $name ($email)');
      print('🔑 Token: ${token.substring(0, 20)}...');

      // Step 9: Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('auth_token', token);
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      await prefs.setBool('isLoggedIn', true);

      // Step 10: Clear form fields
      emailController.clear();
      passwordController.clear();

      // Step 11: Close loading and show success
      Get.back();
      Get.snackbar(
        'Success'.tr,
        userCredential.additionalUserInfo?.isNewUser == true
            ? 'Account created successfully'.tr
            : 'Login successful'.tr,
        backgroundColor: Get.context!.gc(AppColor.primary),
        colorText: Get.context!.gc(AppColor.white),
        duration: const Duration(seconds: 2),
      );

      // Step 12: Navigate to dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(() => Dashboard());

    } on FirebaseAuthException catch (e) {
      Get.back();
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Account exists with different sign-in method';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }

      Get.snackbar(
        'Error'.tr,
        errorMessage,
        backgroundColor: Get.context!.gc(AppColor.redColor),
        colorText: Get.context!.gc(AppColor.white),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.back();
      print("❌ Unexpected Error: $e");
      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred. Please try again.',
        backgroundColor: Get.context!.gc(AppColor.redColor),
        colorText: Get.context!.gc(AppColor.white),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
