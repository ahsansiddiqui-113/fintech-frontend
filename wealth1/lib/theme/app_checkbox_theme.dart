import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';

class AppCheckboxTheme {
  AppCheckboxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(color: CustomAppTheme.lightColors[AppColor.bodyColor2]!),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(color: CustomAppTheme.lightColors[AppColor.bodyColor2]!),
  );
}
