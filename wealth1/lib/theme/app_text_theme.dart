import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: "inter",
      fontWeight: FontWeight.normal,
      color: CustomAppTheme.lightColors[AppColor.bodyColor1],
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CustomAppTheme.lightColors[AppColor.bodyColor1],
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: "inter",
      fontWeight: FontWeight.normal,
      color: CustomAppTheme.darkColors[AppColor.bodyColor1],
    ),
    bodyLarge: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CustomAppTheme.darkColors[AppColor.bodyColor1],
    ),
  );
}

extension GetTextStyle on BuildContext {
  TextStyle interMedTextStyle() {
    return Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
  }

  TextStyle interLargeTextStyle() {
    return Theme.of(this).textTheme.bodyLarge ?? const TextStyle();
  }

  // TextStyle sfProTextStyle() {
  //   return Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
  // }
}
