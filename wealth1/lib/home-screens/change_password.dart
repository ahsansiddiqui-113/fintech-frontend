import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/authentication/change_password_controller.dart';
import 'package:wealthnx/controller/authentication/forgot_password_controller.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key, required this.forgotPassword});
  final bool forgotPassword;

  final CommonController _commonController = Get.put(CommonController());

  final controller = Get.put(ChangePasswordController());
  final changePassController =
      Get.put(ForgotPasswordController()); // Get.find<>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Change Password'),
      body: Form(
        key: controller.formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (forgotPassword == false)
                _commonController.textWidget(context,
                    title: "Current Password".tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                color: Colors.white),
              if (forgotPassword == false)
              addHeight(8),
              if (forgotPassword == false)
              Obx(
                () => TextFormField(
                  controller: controller.oldPassword,
                  obscureText: !controller.isCurrentPassVis.value,
                  style: TextStyle(color: context.gc(AppColor.white)),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required'.tr : null,
                  decoration: inputDecoration(context, 'Enter Current Password').copyWith(
                    suffixStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isCurrentPassVis.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: context.gc(AppColor.grey),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              addHeight(30),
              if (forgotPassword == false) _passwordRules(),
              addHeight(20),
              _commonController.textWidget(context,
                  title: "New Password".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
              color: Colors.white),
              addHeight(8),
              Obx(
                () => TextFormField(
                  controller: controller.newPassword,
                  obscureText: !controller.isNewPassVis.value,
                  style: TextStyle(color: context.gc(AppColor.white)),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required'.tr : null,
                  decoration: inputDecoration(context, 'Enter New Password').copyWith(

                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPassVis.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: context.gc(AppColor.grey,),
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                ),
              ),
              addHeight(12),
              _commonController.textWidget(context,
                  title: "Confirm New Password".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              addHeight(8),
              Obx(
                () => TextFormField(
                  controller: controller.reNewPassword,
                  obscureText: !controller.isConfPassVis.value,
                  style: TextStyle(color: context.gc(AppColor.white)),
                  validator: (value) {
                    if(value != controller.newPassword.text) {
                      return 'Password Not Match'.tr;
                    }
                    return value == null || value.isEmpty
                      ? 'Password Not Match'.tr
                      : null;
                  },
                  decoration: inputDecoration(context, 'Enter Confirm New Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfPassVis.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: context.gc(AppColor.grey),
                      ),
                      onPressed: controller.toggleConfPasswordVisibility,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildChangeButton(context),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commonController.textWidget(
            context,
            title: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            validator: validator,
            obscureText: true,
            style: TextStyle(color: context.gc(AppColor.white)),
            decoration: inputDecoration(context, label),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
        top: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (forgotPassword == true) {
            if (controller.formKey.currentState!.validate()) {
              changePassController.forgotChangePassword();
            }
            // changePassController.forgotChangePassword();
          } else {
            if (controller.formKey.currentState!.validate()) {
              controller.changePassword();
            }

          }
        },
        child: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _passwordRules() {
    final rules = [
      'Between 8 & 24 numbers',
      'At least one uppercase letter',
      'At least one lowercase letter',
      'At least one number',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rules
          .map(
            (rule) => Row(
              children: [
                const Text('• ',
                    style: TextStyle(color: Color(0xFFB8B8B8), fontSize: 12,fontWeight: FontWeight.w300)),
                Expanded(
                  child: Text(rule,
                      style:
                          const TextStyle(color: Color(0xFFB8B8B8), fontSize: 12)),
                ),
                addHeight(20),
              ],
            ),
          )
          .toList(),
    );
  }
}
