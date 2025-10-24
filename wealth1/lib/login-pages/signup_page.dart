import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/login/login_controller.dart';
import 'package:wealthnx/controller/signup/signup_controller.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/authencation/team_n_condition/terms_and_conditions_page.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/app_button.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final SignupController _controller = Get.find<SignupController>();
  final LoginController _loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    title: "Create account".tr,
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
                textWidget(context,
                    title:
                        "Fill the information below to create an account or sign up with your social accounts."
                            .tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                addHeight(40),
                textWidget(context,
                    title: "Full Name".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                addHeight(8),
                TextFormField(
                  controller: _controller.nameController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: context.gc(AppColor.white)),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your full name'
                      : null,
                  decoration: inputDecoration(context, 'John Doe'),
                ),
                addHeight(12),
                textWidget(context,
                    title: "Email".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                addHeight(8),
                TextFormField(
                  controller: _controller.emailController,
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
                    title: "Password".tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                addHeight(8),
                Obx(
                  () => TextFormField(
                    controller: _controller.passwordController,
                    obscureText: !_controller.isPasswordVisible.value,
                    style: TextStyle(color: context.gc(AppColor.white)),
                    validator: (value) => value == null || value.isEmpty
                        ? 'pleaseEYPassword'.tr
                        : null,
                    decoration: inputDecoration(context, '******').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: context.gc(AppColor.grey),
                        ),
                        onPressed: _controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),
                addHeight(12),
                buildTermsAgreement(context),
                addHeight(21),
                // Obx(() => buildSignupButton()),
                Obx(() => _controller.isLoading.value == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: context.gc(AppColor.white),
                        ),
                      )
                    : AppButton(
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (_controller.isAgreed.value) {
                              _controller.signupSendOtp();
                            } else {
                              _controller.showErrorDialog(
                                  'Please agree with terms and conditions'.tr);
                            }
                            // _controller.signUp();
                            // _controller.signupSendOtp();
                          } else {
                            // _controller.signUp();
                          }
                        },
                        txt: 'Sign Up'.tr,
                        borderColor: context.gc(AppColor.primary),
                        txtColor: context.gc(AppColor.white),
                        backgroundColor: context.gc(AppColor.primary),
                      )),
                addHeight(12),
                AppButton(
                  onTap: () {
                    Get.offAll(() => LoginPage());
                    // Get.back();
                  },
                  txt: 'Log In'.tr,
                  borderColor: context.gc(AppColor.grey),
                  txtColor: context.gc(AppColor.white),
                  backgroundColor: context.gc(AppColor.transparent),
                ),
                addHeight(21),
                orDivider(context, title: 'orConnectWith'.tr),
                addHeight(21),
                AppButton(
                  onTap: () {
                    _loginController.signInWithGoogle();
                    // Get.to(() => StockSocket());
                  },
                  addWidget: Image.asset(
                    ImagePaths.googleauth,
                    width: marginSide(31),
                    fit: BoxFit.contain,
                  ),
                  txt: 'google'.tr,
                  fontWeight: FontWeight.w400,
                  borderColor: context.gc(AppColor.white),
                  txtColor: context.gc(AppColor.white),
                  backgroundColor: context.gc(AppColor.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTermsAgreement(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() => SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _controller.isAgreed.value,
                onChanged: _controller.toggleTermsAgreement,
                checkColor: context.gc(AppColor.white),
                activeColor: context.gc(AppColor.primary),
              ),
            )),
        const Text(
          '  Agree with ',
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () => Get.to(() => TermsAndConditionsPage()),
          child: const Text(
            'Terms & Conditions',
            style: TextStyle(color: Color.fromRGBO(46, 173, 165, 1)),
          ),
        ),
      ],
    );
  }
}
