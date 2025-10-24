import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/app_text_theme.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/app_text.dart';

class AppButton extends StatelessWidget {
  AppButton(
      {super.key,
      this.txt,
      this.width = double.infinity,
      this.height = 48,
      this.backgroundColor,
      this.borderColor,
      this.txtColor,
      this.fontSize,
      this.iconSize,
      this.fontWeight,
      this.borderRadius,
      this.iconData,
      this.prefixIcon,
      this.childType = 0,
      this.addWidget,
      required this.onTap});

  final IconData? iconData, prefixIcon;
  final String? txt;
  final FontWeight? fontWeight;
  final double? width, height, borderRadius, fontSize, iconSize;
  final Color? backgroundColor, borderColor, txtColor;
  final int childType; //0 -> Text | 1 -> Icon
  final VoidCallback onTap;
  Widget? addWidget;

  //change to elevated button
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                backgroundColor ?? context.gc(AppColor.gradientColor2),
            padding: EdgeInsets.symmetric(horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
              side: BorderSide(
                  color: borderColor ?? CustomAppTheme.transparent, width: 0.5),
            ),
            elevation: 0.0,
          ),
          child: childType == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (addWidget != null) ...[
                      Container(child: addWidget),
                      addWidth(16),
                    ],
                    if (prefixIcon != null)
                      Row(
                        children: [
                          Icon(
                            prefixIcon,
                            color: txtColor,
                            size: Get.width * ((fontSize ?? 20) / Get.width),
                          ),
                          addWidth(5)
                        ],
                      ),
                    AppText(
                      txt: txt,
                      style: context.interMedTextStyle().copyWith(
                          fontWeight: fontWeight ?? FontWeight.bold,
                          fontSize: Get.width * ((fontSize ?? 16) / Get.width),
                          color: txtColor ?? context.gc(AppColor.black)),
                    ),
                  ],
                )
              : Icon(
                  iconData,
                  color: txtColor ?? context.gc(AppColor.black),
                )),
    );
  }
}
