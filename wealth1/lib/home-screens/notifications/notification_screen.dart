import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/notification/notification_controller.dart';
import 'package:wealthnx/home-screens/notifications/notification_screen_shimmer.dart';
import 'package:wealthnx/home-screens/notifications/notification_settings_screen.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = Get.find<NotificationController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchNotifications();
  }
  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            customAppBar(
              title: "Notification",
              showAddIcon: true,
              onAddPressed: () async {
                Get.to(() => const NotificationSettingsScreen());
              },
              leadingIcon: Icons.settings_outlined,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return NotificationScreenShimmer();
                }
                if (controller.schedulePayments.value == false ) {
                  return const Center(
                    child: Text(
                      "Schedule Notifications are turned off",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                if (controller.groupedNotifications.isEmpty ) {
                  return const Center(
                    child: Text(
                      "No recent notifications",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: controller.groupedNotifications.entries.map((entry) {
                    if (entry.value.isEmpty) return const SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        ...entry.value.map((n) {
                          return _buildNotificationItem(
                            n.title,
                            n.message,
                            DateFormat('hh:mm a').format(n.createdAt),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, String time) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            child: const CircleAvatar(
              // radius: 20,
              backgroundColor: Colors.white10,
              child: Icon(
                size: 22,
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(right: 20, top: 4),
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
      ],
    );
  }
}