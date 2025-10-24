import 'package:flutter/material.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';

enum AppColor {
  primary,
  darkPrimary,
  bodyBackground,
  lightBlue,
  darkBlue,
  borderColor,
  headingColor,
  bodyColor1,
  bodyColor2,
  strokeColor,
  gradientColor1,
  gradientColor2,
  white,
  black,
  grey,
  greyDialog,
  backArrowBackground,
  cardShadowColor,
  greenColor,
  transparent,
  redColor,
  bottomNav,
}

extension GetColor on BuildContext {
  Color gc(AppColor key) {
    Color? toReturn;
    try {
      toReturn = Theme.of(this).brightness == Brightness.light
          ? CustomAppTheme.lightColors[key]
          : CustomAppTheme.darkColors[key];
    } catch (e) {
      toReturn = null;
    }
    return toReturn ?? Colors.orange;
  }
}
