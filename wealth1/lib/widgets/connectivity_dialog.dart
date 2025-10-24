import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class ConnectivityDialog extends StatelessWidget {
  ConnectivityDialog({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 26),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: context.gc(AppColor.grey), width: 0.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onPressed ?? () => Get.back(),
                child: Icon(Icons.close, color: context.gc(AppColor.grey)),
              ),
            ),
            Image.asset(
              ImagePaths.merge,
              fit: BoxFit.contain,
              height: 56,
            ),
            addHeight(40),
            textWidget(context,
                title: "WealthNx uses Plaid to connect".tr,
                fontSize: 18,
                fontWeight: FontWeight.w500),
            textWidget(context,
                title: "With your accounts".tr,
                fontSize: 18,
                fontWeight: FontWeight.w500),
            addHeight(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: textWidget(context,
                  title:
                      "Connect account to view detail & personal financial experience"
                          .tr,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  color: context.gc(AppColor.grey),
                  fontWeight: FontWeight.w400),
            ),
            addHeight(20),
            buildAddButton(
              title: 'Connect Account',
              margin: EdgeInsets.only(top: 10),
              onPressed: () async {
                Get.to(() => ConnectAccounts());
              },
            ),
          ],
        ),
      ),
    );
  }
}
