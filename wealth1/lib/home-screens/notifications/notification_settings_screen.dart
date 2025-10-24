import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/notification/notification_controller.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final settings = notificationController.getSetting();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            customAppBar(
              title: "Notification Settings",
              showAddIcon: false,
              leadingIcon: Icons.settings,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: settings.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                itemBuilder: (context, index) {
                  String key = settings.keys.elementAt(index);
                  RxBool settingValue = settings[key]!;

                  return Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: settingValue.value,
                          activeColor: Colors.white,
                          inactiveThumbColor: Colors.white,
                          activeTrackColor: CustomAppTheme.primaryColor,
                          inactiveTrackColor: Colors.grey.withOpacity(0.4),
                          onChanged: (val) {
                            notificationController.updateSetting(key, val);
                          },
                        ),
                      ),
                    ],
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}