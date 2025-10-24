import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/VERIFICATION/number_verification_page.dart';
import 'package:wealthnx/controller/login/login_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/login-pages/signup_page.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/auth_screen/ph_login_screen.dart';
import 'package:wealthnx/widgets/app_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController _loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc(AppColor.bodyBackground),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: marginSide(), vertical: marginVertical(40)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addHeight(21),
                textWidget(context,
                    title: "welcomeBack".tr,
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
                textWidget(context,
                    title: "loginToAccount".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                addHeight(40),
                textWidget(context,
                    title: "email".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                addHeight(8),
                TextFormField(
                  controller: _loginController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: context.gc(AppColor.white)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEYEmail'.tr;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'pleaseEValidEmail'.tr;
                    }
                    return null;
                  },
                  decoration: inputDecoration(context, 'john@gmail.com'),
                ),
                addHeight(12),
                textWidget(context,
                    title: "password".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                addHeight(8),
                Obx(
                  () => TextFormField(
                    controller: _loginController.passwordController,
                    obscureText: !_loginController.isPasswordVisible.value,
                    style: TextStyle(color: context.gc(AppColor.white)),
                    validator: (value) => value == null || value.isEmpty
                        ? 'pleaseEYPassword'.tr
                        : null,
                    decoration: inputDecoration(context, '******').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _loginController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: context.gc(AppColor.grey),
                        ),
                        onPressed: _loginController.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),
                addHeight(12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      final email =
                          _loginController.emailController.text.trim();
                      Get.to(() => PhoneVerificationPage());
                    },
                    child: textWidget(context,
                        title: "forgotPassword".tr,
                        color: context.gc(AppColor.primary),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                addHeight(21),
                Obx(() => _loginController.isLoading.value == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: context.gc(AppColor.white),
                        ),
                      )
                    : AppButton(
                        onTap: () {
                          _loginController.isLoading.value
                              ? null
                              : _loginController.signIn();
                        },
                        txt: 'Log In'.tr,
                        borderColor: context.gc(AppColor.primary),
                        txtColor: context.gc(AppColor.white),
                        backgroundColor: context.gc(AppColor.primary),
                      )),
                addHeight(12),
                AppButton(
                  onTap: () {
                    Get.to(() => SignupPage());
                  },
                  txt: 'Register'.tr,
                  borderColor: context.gc(AppColor.grey),
                  txtColor: context.gc(AppColor.white),
                  backgroundColor: context.gc(AppColor.transparent),
                ),
                addHeight(21),
                Center(
                  child: textWidget(context,
                      title: "Login wit touch ID".tr,
                      fontSize: 16,
                      color: context.gc(AppColor.grey),
                      fontWeight: FontWeight.w400),
                ),
                addHeight(12),
                GestureDetector(
                  onTap: () => _loginController.loginWithBiometrics(),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 0.5, color: context.gc(AppColor.white))),
                      child: Image.asset(
                        ImagePaths.fingureprint,
                        width: marginSide(26),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                addHeight(21),
                orDivider(context, title: 'orConnectWith'.tr),
                addHeight(21),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onTap: () {
                          _loginController.signInWithGoogle();
                          // Get.to(() => StockSocket());
                        },
                        addWidget: Image.asset(
                          ImagePaths.googleauth,
                          width: marginSide(28),
                          fit: BoxFit.contain,
                        ),
                        txt: 'google'.tr,
                        fontWeight: FontWeight.w500,
                        borderColor: context.gc(AppColor.white),
                        txtColor: context.gc(AppColor.white),
                        backgroundColor: context.gc(AppColor.black),
                      ),
                    ),
                    if (Platform.isIOS) ...[
                      addWidth(),
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            // _loginController.signInWithGoogle();
                            // Get.to(() => StockSocket());
                          },
                          addWidget: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              ImagePaths.apple,
                              width: marginSide(20),
                              fit: BoxFit.contain,
                            ),
                          ),
                          txt: 'Apple'.tr,
                          fontWeight: FontWeight.w500,
                          borderColor: context.gc(AppColor.white),
                          txtColor: context.gc(AppColor.white),
                          backgroundColor: context.gc(AppColor.black),
                        ),
                      ),
                    ],
                  ],
                ),
                addHeight(12),
                AppButton(
                  onTap: () {
                    Get.to(() => PhoneNoLogin());
                  },
                  txt: 'Continue with Phone Number'.tr,
                  fontWeight: FontWeight.w400,
                  borderColor: context.gc(AppColor.grey),
                  txtColor: context.gc(AppColor.white),
                  backgroundColor: context.gc(AppColor.transparent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
