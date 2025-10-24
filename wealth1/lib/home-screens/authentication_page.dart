import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/authentication/authentication_page_controller.dart';
import 'package:wealthnx/home-screens/change_password.dart';
import 'package:wealthnx/home-screens/email_auth_page.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationPageController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Authentication'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildNavTile(
              title: 'Change Password',
              onTap: () {
                Get.to(() => ChangePassword(forgotPassword: false));
              },
            ),
            const Divider(color: Colors.white12),
            _buildNavTile(
              title: 'Email & Password Authentication',
              onTap: () {
                Get.to(() => const EmailAuthPage());
              },
            ),
            const Divider(color: Colors.white12),
            Obx(() => _buildSwitchTile(
                  title: 'Face ID / Fingerprint ',
                  value: controller.faceIdEnabled.value,
                  onChanged: controller.toggleFaceId,
                )),
            // const Divider(color: Colors.white12),
            // Obx(() => _buildSwitchTile(
            //       title: 'Fingerprint Login',
            //       value: controller.fingerprintEnabled.value,
            //       onChanged: controller.toggleFingerprint,
            //     )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      activeColor: Colors.teal,
      inactiveTrackColor: Colors.white24,
      onChanged: onChanged,
    );
  }
}
