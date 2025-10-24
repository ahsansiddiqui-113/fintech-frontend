import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/theme/app_color.dart';

customAppBar({
  String? title,
  Function()? onBackPressed,
  bool showAddIcon = false,
  bool automaticallyImplyLeading = false,
  Function()? onAddPressed,
  List<Widget>? actions,
  IconData? leadingIcon,
}) {
  return AppBar(
    backgroundColor: Get.context?.gc(AppColor.black),
    surfaceTintColor: Get.context?.gc(AppColor.black),
    elevation: 0,
    leadingWidth: automaticallyImplyLeading ? 16 : 40,
    centerTitle: false,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actionsPadding: EdgeInsets.only(right: 16),
    leading: automaticallyImplyLeading
        ? Container()
        : IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: onBackPressed ?? () => Get.back(result: true),
          ),
    title: Text(
      title.toString(),
      style: TextStyle(
        fontSize: automaticallyImplyLeading ? 20 : 18,
        fontWeight:
            automaticallyImplyLeading ? FontWeight.w600 : FontWeight.w500,
        color: Colors.white,
      ),
    ),
    actions: [
      if (actions != null) ...actions,
      if (showAddIcon)
        IconButton(
          icon: Icon(leadingIcon ?? Icons.add, color: Colors.white, size: 24),
          onPressed: onAddPressed ?? () {}, // fallback empty function
        ),
    ],
    titleSpacing: 0,
  );
}
