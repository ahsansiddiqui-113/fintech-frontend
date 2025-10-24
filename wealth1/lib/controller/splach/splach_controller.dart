import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/utils/app_screens.dart';
import 'package:wealthnx/utils/session_manager.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  bool isLoggedIn = false;

  @override
  void onInit() {
    super.onInit();

    checkSession();

    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // GetX provides TickerProviderStateMixin
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();

    Timer(const Duration(seconds: 3), checkNavigation);
  }

  Future<void> checkNavigation() async {
    Get.offNamed(isLoggedIn ? AppScreens.dashboard : AppScreens.onboarding);
  }

  //----- Check Sessions -----
  Future<void> checkSession() async {
    isLoggedIn = await SessionManager.isLoggedIn();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
