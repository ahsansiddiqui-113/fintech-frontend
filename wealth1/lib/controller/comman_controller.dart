import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/app_text_theme.dart';
import 'package:wealthnx/utils/app_constant.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/app_button.dart';
import 'package:wealthnx/widgets/app_text.dart';

class CommonController extends GetxController {
  var dwmyDropdown = "Monthly".obs;
  var selectedLanguage = "en".obs;
  var isDarkTheme = false.obs;
  final localStorage = GetSecureStorage(password: AppConstant.dbSecurityKey);
  double sidemargin = Get.width * (16 / Get.width);

  double responsiveWidth = Get.width;
  double responsiveHeight = Get.height;

  Map<int, Color> color = {
    50: Color.fromRGBO(255, 242, 0, .1),
    100: Color.fromRGBO(255, 242, 0, .2),
    200: Color.fromRGBO(255, 242, 0, .3),
    300: Color.fromRGBO(255, 242, 0, .4),
    400: Color.fromRGBO(255, 242, 0, .5),
    500: Color.fromRGBO(255, 242, 0, .6),
    600: Color.fromRGBO(255, 242, 0, .7),
    700: Color.fromRGBO(255, 242, 0, .8),
    800: Color.fromRGBO(255, 242, 0, .9),
    900: Color.fromRGBO(255, 242, 0, 1),
  };

  @override
  void onInit() {
    super.onInit();

    getThemeFromStorage();
    getLocaleFromStorage();
    // checkInternet();
  }

  Future<void> makeUserLogOut() async {
    try {
      // Clear all user-related data
      await _clearUserData();

      // Navigate to login screen and clear navigation stack
      Get.offAllNamed('/login');

      // Show logout confirmation
      showToast('logoutSuccess'.tr);
    } catch (e) {
      showToast('logoutFailed'.tr);
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all user-specific data
    await prefs.remove('auth_token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('name');
    // Add any other user data you need to clear

    // Optional: Clear all preferences (use carefully)
    // await prefs.clear();

    // Clear any in-memory user data
    // user.value = null;
    // isLoggedIn.value = false;
  }

  Widget textWidget(BuildContext context,
      {title, fontWeight, fontSize, color, textAlign, maxLines, overflow}) {
    return AppText(
      txt: title,
      textAlign: textAlign,
      style: context.interMedTextStyle().copyWith(
            color: color ?? context.gc(AppColor.white),
            fontSize: responsiveWidth * (fontSize / responsiveWidth),
            fontWeight: fontWeight,
            overflow: overflow,
          ),
      maxLines: maxLines,
    );
  }

  Future<void> getThemeFromStorage() async {
    var res = await localStorage.read(AppConstant.keyIsDarkTheme);
    if (res != null) {
      isDarkTheme.value = res;
      Get.changeThemeMode(isDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
      return;
    }
    isDarkTheme.value = false;
  }

  Future<void> setDarkTheme({required bool enableDarkTheme}) async {
    await localStorage.write(AppConstant.keyIsDarkTheme, enableDarkTheme);
    isDarkTheme.value = enableDarkTheme;
    Get.changeThemeMode(isDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> getLocaleFromStorage() async {
    var res = await localStorage.read(AppConstant.keySelectedLanguage);
    if (res != null) {
      selectedLanguage.value = res;
      Get.updateLocale(Locale(selectedLanguage.value));
      return;
    }
    selectedLanguage.value = "en";
  }

  Future<void> changeLocale(String languageCode) async {
    await localStorage.write(AppConstant.keySelectedLanguage, languageCode);
    selectedLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }

//Exit Dialog most of the Android plateform
  showExitDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Wrap(
            runAlignment: WrapAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color: context.gc(AppColor.black),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    AppText(
                      txt: 'areYouWantExit'.tr,
                      textAlign: TextAlign.left,
                      style: context.interMedTextStyle().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: context.gc(AppColor.white)),
                    ),
                    addHeight(30),
                    Row(
                      children: [
                        Expanded(
                            child: AppButton(
                          onTap: () => Get.back(),
                          txt: 'cancel'.tr,
                          backgroundColor: context.gc(AppColor.white),
                          txtColor: context.gc(AppColor.darkBlue),
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: AppButton(
                          onTap: () => exit(0),
                          txt: 'exit'.tr,
                          backgroundColor: context.gc(AppColor.white),
                          txtColor: context.gc(AppColor.darkBlue),
                        )),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  void launchURL({required String url, required String? type}) async {
    if (url.isEmpty) {
      // showToast(
      //   "lbl_invalid_url".trs,
      // );
      return;
    }

    if (type == "phone") {
      url = "tel:$url";
    } else if (type == "email") {
      url = "mailto:$url";
    } else if (type == "sms") {
      url = "sms:$url";
    } else {
      if (!(url.startsWith("http"))) {
        url = "http://" + url;
      }
    }

    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        showToast("lbl_cannot_launch_url".tr + " $url");
      }
    } catch (e) {
      showToast("lbl_cannot_launch_url".tr + " $url");
    }
  }
}
