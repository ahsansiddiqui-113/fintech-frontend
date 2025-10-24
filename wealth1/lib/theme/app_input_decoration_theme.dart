import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';

// import '../utils/export.dart';

class AppInputDecorationTheme {
  AppInputDecorationTheme._();

  static InputDecorationTheme lightInputDecorationTheme() {
    InputBorder activeBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: CustomAppTheme.lightColors[AppColor.strokeColor] ??
              CustomAppTheme.primaryColor,
        ),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    InputBorder inActiveBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: CustomAppTheme.lightColors[AppColor.strokeColor] ??
                CustomAppTheme.primaryColor),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    InputBorder errorBorder = OutlineInputBorder(
        borderSide: const BorderSide(color: CustomAppTheme.red),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    return InputDecorationTheme(
      border: activeBorder,
      enabledBorder: activeBorder,
      focusedBorder: activeBorder,
      disabledBorder: inActiveBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      isCollapsed: true,
      contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    );
  }

  static InputDecorationTheme darkInputDecorationTheme() {
    InputBorder activeBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: CustomAppTheme.lightColors[AppColor.strokeColor] ??
                CustomAppTheme.primaryColor),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    InputBorder inActiveBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: CustomAppTheme.lightColors[AppColor.strokeColor] ??
                CustomAppTheme.primaryColor),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    InputBorder errorBorder = OutlineInputBorder(
        borderSide: const BorderSide(color: CustomAppTheme.red),
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2);

    return InputDecorationTheme(
      border: activeBorder,
      enabledBorder: activeBorder,
      focusedBorder: activeBorder,
      disabledBorder: inActiveBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      isCollapsed: true,
      contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    );
  }
}
