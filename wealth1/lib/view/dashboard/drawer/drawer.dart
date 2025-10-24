import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/drawer/drawer_controller.dart';
import 'package:wealthnx/controller/profile/profile_controller.dart';
import 'package:wealthnx/view/feedback/feedback_screen_dialog.dart';
import 'package:wealthnx/view/vitals/accounts/accounts_page.dart';
import 'package:wealthnx/home-screens/authentication_page.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/profile/profile_screen.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';
import 'package:wealthnx/widgets/app_button.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final CustomDrawerController _drawerController =
      Get.find<CustomDrawerController>();

  final CommonController _commonController = Get.put(CommonController());

  final ProfileController profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: context.gc(AppColor.black),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _commonController.sidemargin,
            vertical: _commonController.responsiveHeight *
                (24 / _commonController.responsiveHeight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(context),
              addHeight(32),
              // _drawerItem(
              //   context,
              //   backGroundImage:Padding(
              //     padding:  EdgeInsets.zero,
              //     child: CircleAvatar(
              //       radius: 17,
              //       backgroundColor: Colors.black,
              //       backgroundImage:  AssetImage(ImagePaths.WealthNXLogo) as ImageProvider,
              //     ),
              //   ),
              //   icon: CupertinoIcons.person_crop_circle_fill_badge_exclam,
              //   title: 'Get the Best Version ',
              //   subtitle: 'Upgrade now',
              //   onTap: () => Get.to(() => ConnectAccounts()),
              // ),
              _drawerItem(
                context,
                icon: CupertinoIcons.person_crop_circle_fill_badge_exclam,
                title: 'Profile',
                subtitle: 'Personal data, income, tax',
                onTap: () => Get.to(() => ProfilePage()),
              ),
              _drawerItem(
                context,
                icon: Icons.account_balance_outlined,
                title: 'Accounts',
                subtitle: 'Manage Connected Accounts',
                // onTap: () => Get.to(() => ConnectAccounts()),
                onTap: () => Get.to(() => const AccountsPage()),
              ),
              _drawerItem(
                context,
                icon: Icons.fingerprint_outlined,
                title: 'Authentication',
                subtitle: 'Password, biometric login',
                onTap: () => Get.to(() => const AuthenticationPage()),
              ),
              _drawerItem(
                context,
                icon: Icons.headset_mic_outlined,
                title: 'Support',
                subtitle: 'Help and contact',
                onTap: () => _showConnectAccountDialog(context),
              ),
              _drawerItem(
                context,
                icon: Icons.delete_outline_sharp,
                title: 'Delete Account',
                subtitle: 'Remove account permanently',
                onTap: () => _showDeleteUserDialog(context),
              ),
              _drawerItem(
                context,
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                subtitle: 'WealthNX documents',
                onTap: () {},
              ),
              _drawerItem(
                context,
                icon: Icons.note_alt_outlined,
                title: 'Feedback',
                subtitle: 'User Feedback',
                onTap: () {
                  Get.dialog(FeedbackScreenDialog());
                },
              ),
              _drawerItem(
                context,
                icon: Icons.logout,
                title: 'Log out',
                subtitle: '',
                onTap: () => _showLogoutDialog(context),
              ),
              // const Spacer(),
              // Container(
              //     width: double.infinity,
              //     height: 80,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(8),
              //       image: DecorationImage(
              //           image: AssetImage(
              //               'assets/images/app_version_background.png'),
              //           fit: BoxFit.cover),
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         CircleAvatar(
              //           radius: 22,
              //           backgroundColor: context.gc(AppColor.grey),
              //           backgroundImage: AssetImage(ImagePaths.person),
              //         ),
              //         addWidth(5),
              //         Container(
              //           width: 180,
              //           child: textWidget(context,
              //               title: "Get the Best Version Upgrade now".tr,
              //               fontSize: Get.width * (16 / Get.width),
              //               maxLines: 2,
              //               fontWeight: FontWeight.w600),
              //         ),
              //       ],
              //     ))
              // _drawerItem(
              //   context,
              //   icon: Icons.logout,
              //   title: 'Log out',
              //   subtitle: '',
              //   onTap: () => _showLogoutDialog(context),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => CircleAvatar(
            radius: 22,
            backgroundColor: context.gc(AppColor.grey),
            backgroundImage: profileController.profilePic.value != ''
                ? NetworkImage(AppEndpoints.profileBaseUrl +
                    '${profileController.profilePic.value}')
                : AssetImage(ImagePaths.person),
          ),
        ),
        addWidth(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => _commonController.textWidget(context,
                  title: "${profileController.fullNameProfile}".tr,
                  fontSize: _commonController.responsiveWidth *
                      (18 / _commonController.responsiveWidth),
                  fontWeight: FontWeight.w600),
            ),
            _commonController.textWidget(context,
                title: "profileASettings".tr,
                fontSize: _commonController.responsiveWidth *
                    (12 / _commonController.responsiveWidth),
                fontWeight: FontWeight.w400),
          ],
        ),
      ],
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    Widget? backGroundImage,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: backGroundImage ??
          Icon(icon, size: 34, color: context.gc(AppColor.grey)),
      title: _commonController.textWidget(context,
          title: title,
          fontSize: _commonController.responsiveWidth *
              (16 / _commonController.responsiveWidth),
          fontWeight: FontWeight.w400),
      subtitle: subtitle.isNotEmpty
          ? _commonController.textWidget(context,
              title: subtitle,
              color: context.gc(AppColor.grey),
              fontSize: _commonController.responsiveWidth *
                  (12 / _commonController.responsiveWidth),
              fontWeight: FontWeight.w300)
          : null,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      backgroundColor: context.gc(AppColor.greyDialog),
      titlePadding: EdgeInsets.zero,
      title: ''.tr,
      titleStyle: TextStyle(
          color: context.gc(AppColor.white),
          fontSize: _commonController.responsiveWidth *
              (22 / _commonController.responsiveWidth),
          fontWeight: FontWeight.w500),
      content: Column(
        spacing: 20,
        children: [
          _commonController.textWidget(context,
              title: 'logoutWantTo'.tr,
              color: context.gc(AppColor.grey),
              fontSize: _commonController.responsiveWidth *
                  (14 / _commonController.responsiveWidth),
              fontWeight: FontWeight.w400),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                width: _commonController.responsiveWidth *
                    (80 / _commonController.responsiveWidth),
                height: 45,
                onTap: () {
                  Get.back();
                },
                txt: 'no'.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                borderColor: context.gc(AppColor.white),
                txtColor: context.gc(AppColor.white),
                backgroundColor: context.gc(AppColor.black),
              ),
              addWidth(16),
              AppButton(
                width: _commonController.responsiveWidth *
                    (80 / _commonController.responsiveWidth),
                height: 45,
                onTap: () {
                  _drawerController.logout();
                  Get.offAll(() => LoginPage());
                },
                txt: 'yes'.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                borderColor: context.gc(AppColor.redColor),
                txtColor: context.gc(AppColor.white),
                backgroundColor: context.gc(AppColor.redColor),
              ),
            ],
          ),
        ],
      ),

      /*actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                width: _commonController.responsiveWidth *
                    (80 / _commonController.responsiveWidth),
                height: 45,
                onTap: () {
                  Get.back();
                },
                txt: 'no'.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                borderColor: context.gc(AppColor.white),
                txtColor: context.gc(AppColor.white),
                backgroundColor: context.gc(AppColor.black),
              ),
              addWidth(16),
              AppButton(
                width: _commonController.responsiveWidth *
                    (80 / _commonController.responsiveWidth),
                height: 45,
                onTap: () {
                  _drawerController.logout();
                  Get.offAll(() => LoginPage());
                },
                txt: 'yes'.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                borderColor: context.gc(AppColor.redColor),
                txtColor: context.gc(AppColor.white),
                backgroundColor: context.gc(AppColor.redColor),
              ),
            ],
          ),
        ]*/
    );
  }

  void _showDeleteUserDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: context.gc(AppColor.grey), width: 0.25),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: context.gc(AppColor.grey)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: textWidget(
                          context,
                          title: "Delete Account".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      addHeight(6),
                      textWidget(
                        context,
                        title: "Are you sure you want to delete your account?".tr,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                      addHeight(12),
                      TextFormField(
                        focusNode: focusNode,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: context.gc(AppColor.white)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (savedEmail != null && value.trim() != savedEmail) {
                            return "Email does not match";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          context,
                          'xyz@gmail.com',
                        ),
                      ),
                    ],
                  ),
                  addHeight(20),
                  buildAddButton(
                    title: 'Delete Account'.tr,
                    padding: EdgeInsets.zero,
                    margin: const EdgeInsets.only(top: 10),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _drawerController.deleteUserAccount();
                        emailController.clear();

                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _showConnectAccountDialog(BuildContext context) {
    Get.defaultDialog(
      backgroundColor: context.gc(AppColor.greyDialog),

      title: '',
      //'Connect your account'.tr,
      titlePadding: EdgeInsets.zero,
      titleStyle: TextStyle(
          color: context.gc(AppColor.white),
          fontSize: _commonController.responsiveWidth *
              (20 / _commonController.responsiveWidth),
          fontWeight: FontWeight.w500),
      content: Column(
        // spacing: 23,

        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image(
                image: AssetImage('assets/icons/connect_account.png'),
                height: 128,
                width: 128,
              )),
          SizedBox(
            height: 23,
          ),
          _commonController.textWidget(context,
              title: 'Connect your account'.tr,
              color: context.gc(AppColor.white),
              textAlign: TextAlign.center,
              fontSize: _commonController.responsiveWidth *
                  (20 / _commonController.responsiveWidth),
              fontWeight: FontWeight.w400),
          SizedBox(
            height: 10,
          ),
          _commonController.textWidget(context,
              title:
                  'Securely link your bank, credit, or investment accounts using Plaid.'
                      .tr,
              color: context.gc(AppColor.grey),
              textAlign: TextAlign.center,
              fontSize: _commonController.responsiveWidth *
                  (14 / _commonController.responsiveWidth),
              fontWeight: FontWeight.w400),
          SizedBox(
            height: 23,
          ),
          AppButton(
            width: _commonController.responsiveWidth *
                (230 / _commonController.responsiveWidth),
            height: 45,
            onTap: () {
              Get.back();
            },
            txt: 'Add Account'.tr,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            borderColor: context.gc(AppColor.primary),
            txtColor: context.gc(AppColor.white),
            backgroundColor: context.gc(AppColor.primary),
          ),
        ],
      ),
      /*actions: [
          AppButton(
            width: _commonController.responsiveWidth *
                (230 / _commonController.responsiveWidth),
            height: 45,
            onTap: () {
              Get.back();
            },
            txt: 'Add Account'.tr,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            borderColor: context.gc(AppColor.primary),
            txtColor: context.gc(AppColor.white),
            backgroundColor: context.gc(AppColor.primary),
          ),
        ]*/
    );
  }
}
