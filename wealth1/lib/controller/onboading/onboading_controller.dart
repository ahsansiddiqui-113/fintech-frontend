import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/onboading_screen/slide_widget.dart';

class OnboadingController extends GetxController {
  int currentPage = 0;
  final pageController = PageController(initialPage: 0);
  Timer? _timer; // Timer for auto-scrolling

  final double screenWidth = Get.width;

  List<Widget> myWidgetList = [
    SlideWidget(title: 'wealthNx'.tr, subtitle: 'yourHyperPFCoPilot'.tr),
    SlideWidget(title: 'wealthNx'.tr, subtitle: 'smarterFDecisionsSHere'.tr),
    SlideWidget(title: 'wealthNx'.tr, subtitle: 'builtMGYWealth'.tr),
  ];

  /// Function to start auto-scrolling
  void startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentPage < myWidgetList.length - 1) {
        currentPage++;
      } else {
        currentPage = 0; // Reset to first screen
      }
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  getIntroImage(String image) {
    return Container(
      // height: 250,
      alignment: Alignment.center,
      // color: Colors.amber,
      child: Transform.scale(
        scale: 0.75,
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          image,
          width: screenWidth * (350 / screenWidth),
          // fit: BoxFit.contain,
          // color: Colors.blue,
        ),
      ),
    );
  }

  getProgressLine(BuildContext context,
      {required color1, required color2, required color3}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getContainer(color1),
        addWidth(screenWidth * (6 / screenWidth)),
        getContainer(color2),
        addWidth(screenWidth * (6 / screenWidth)),
        getContainer(color3),
      ],
    );
  }

  getContainer(Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(30)),
        // width: screenWidth * 0.29,
        height: 3.2,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    startAutoScroll();
  }

  @override
  void onClose() {
    _timer?.cancel(); // Cancel timer when widget is removed
    pageController.dispose();
    super.onClose();
  }
}
