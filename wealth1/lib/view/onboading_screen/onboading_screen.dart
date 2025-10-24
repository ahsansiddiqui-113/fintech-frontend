import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/onboading/onboading_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_screens.dart';
import 'package:wealthnx/widgets/app_button.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final CommonController _commonController = Get.put(CommonController());
  final OnboadingController _onboadingController =
      Get.find<OnboadingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc(AppColor.bodyBackground),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImagePaths.grad),
              fit: BoxFit.contain,
              alignment: Alignment.topLeft),
        ),
        child: Container(
          margin:
              EdgeInsets.symmetric(horizontal: _commonController.sidemargin),
          child: Column(
            children: [
              addHeight(60),
              if (_onboadingController.currentPage == 0) ...[
                _onboadingController.getProgressLine(context,
                    color1: context.gc(AppColor.white),
                    color2: context.gc(AppColor.grey),
                    color3: context.gc(AppColor.grey)),
              ],
              if (_onboadingController.currentPage == 1) ...[
                _onboadingController.getProgressLine(context,
                    color1: context.gc(AppColor.white),
                    color2: context.gc(AppColor.white),
                    color3: context.gc(AppColor.grey)),
              ],
              if (_onboadingController.currentPage == 2) ...[
                _onboadingController.getProgressLine(context,
                    color1: context.gc(AppColor.white),
                    color2: context.gc(AppColor.white),
                    color3: context.gc(AppColor.white)),
              ],
              SizedBox(
                height: 350,
                child: PageView(
                  controller: _onboadingController.pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _onboadingController.currentPage = index;
                    });
                  },
                  children: [
                    _onboadingController.getIntroImage(ImagePaths.one),
                    _onboadingController.getIntroImage(ImagePaths.two),
                    _onboadingController.getIntroImage(ImagePaths.three),
                  ],
                ),
              ),
              Spacer(),
              _onboadingController
                  .myWidgetList[_onboadingController.currentPage],
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppButton(
                      onTap: () {
                        Get.toNamed(AppScreens.login);
                      },
                      txt: 'signIn'.tr,
                      borderColor: context.gc(AppColor.white),
                      txtColor: context.gc(AppColor.white),
                      backgroundColor: context.gc(AppColor.black),
                    ),
                  ),
                  addWidth(16),
                  Expanded(
                    child: AppButton(
                      onTap: () {
                        Get.toNamed(AppScreens.signup);
                      },
                      txt: 'signUp'.tr,
                      borderColor: context.gc(AppColor.primary),
                      txtColor: context.gc(AppColor.white),
                      backgroundColor: context.gc(AppColor.primary),
                    ),
                  ),
                ],
              ),
              addHeight(62),
            ],
          ),
        ),
      ),
    );
  }
}
