import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/splach/splach_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController _splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: context.gc(AppColor.bodyBackground),
        body: UpgradeAlert(
          dialogStyle: Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
          barrierDismissible: false,
          showLater: false,
          showIgnore: false,
          showReleaseNotes: false,

          upgrader: Upgrader(
            durationUntilAlertAgain: const Duration(days: 1),
          ),
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(ImagePaths.grad),
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(ImagePaths.finlogo),
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter),
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _splashController.animation,
                  child: FadeTransition(
                    opacity: _splashController.animation,
                    child: Image.asset(
                      ImagePaths.wealthnx,
                      // color: Colors.blue,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
