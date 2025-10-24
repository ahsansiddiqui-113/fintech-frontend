import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_checkbox_theme.dart';
import 'package:wealthnx/theme/app_color.dart';

import 'app_input_decoration_theme.dart';
import 'app_text_theme.dart';

class CustomAppTheme {
  CustomAppTheme._();

  static const Color primaryColor = Color.fromRGBO(46, 173, 165, 1);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color red = Colors.red;
  static const Color green = Colors.green;
  static const transparent = Colors.transparent;
  static const gradientGreenColor = const Color(0xFF318578);
  static const redColor1 = const Color(0xFFC24835);
  static const redColor2 =  Color(0xFFBA4659);
  static const gradientBlueColor=  const Color(0xFF799BE4);
  static const darkPrimary = const Color(0xff004943);
  static const darkBlack = const  Color(0xff0c0c0c);
  static Map<AppColor, Color> lightColors = {
    AppColor.primary: primaryColor,
    AppColor.bodyBackground: white,
    AppColor.lightBlue: const Color(0xff3DAAE0),
    AppColor.darkPrimary: const Color(0xff004943),
    AppColor.darkBlue: const Color(0xffFFF200),
    AppColor.headingColor: const Color(0xff1B2559),
    AppColor.bodyColor1: Colors.white,
    AppColor.bodyColor2: const Color(0xffA3AED0),
    AppColor.strokeColor: const Color(0xffE0DEF1),

    AppColor.gradientColor1: const Color(0xFF0C3633),
    AppColor.gradientColor2: const Color(0xffDCDDD7),
    //new colors added
    AppColor.backArrowBackground: const Color(0xff819afd),
    AppColor.cardShadowColor: const Color(0x268271ee),
    AppColor.greenColor: green,

    AppColor.redColor: red,

    //new colors transprent
    AppColor.transparent: const Color(0x00000000),

    //new colors end
    AppColor.black: black,
    AppColor.white: white,
    AppColor.grey: grey,
    AppColor.greyDialog: Colors.grey.shade900,
    AppColor.bottomNav: Color(0xff0c0c0c),
    AppColor.borderColor: Color(0xff252525),
  };

  static Map<AppColor, Color> darkColors = {
    AppColor.primary: primaryColor,
    AppColor.bodyBackground: black,
    AppColor.lightBlue: const Color(0xff3DAAE0),
    AppColor.darkPrimary: const Color(0xff004943),
    AppColor.darkBlue: const Color(0xffFFF200),
    AppColor.headingColor: const Color(0xff1B2559),
    AppColor.bodyColor1: Colors.white,
    AppColor.bodyColor2: const Color(0xffA3AED0),
    AppColor.strokeColor: const Color(0xffE0DEF1),
    AppColor.gradientColor1: const Color.fromARGB(255, 5, 13, 12),
    AppColor.gradientColor2: const Color(0xffDCDDD7),
    //new colors added
    AppColor.backArrowBackground: const Color(0xff819afd),
    AppColor.cardShadowColor: const Color(0x268271ee),
    AppColor.greenColor: green,

    AppColor.redColor: red,

    //new colors transprent
    AppColor.transparent: const Color(0x00000000),

    //new colors end
    AppColor.black: black,
    AppColor.white: white,
    AppColor.grey: grey,
    AppColor.greyDialog: Colors.grey.shade900,
    AppColor.bottomNav: Color(0xff0c0c0c),
    AppColor.borderColor: Color(0xff252525),
  };

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightColors[AppColor.primary] ?? primaryColor,
      brightness: Brightness.light,
    ),
    fontFamily: "inter",
    scaffoldBackgroundColor: lightColors[AppColor.bodyBackground] ?? white,
    inputDecorationTheme: AppInputDecorationTheme.lightInputDecorationTheme(),
    indicatorColor: primaryColor,
    textTheme: AppTextTheme.lightTextTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkColors[AppColor.primary] ?? primaryColor,
      brightness: Brightness.dark,
    ),
    fontFamily: "inter",
    scaffoldBackgroundColor: darkColors[AppColor.bodyBackground] ?? black,
    inputDecorationTheme: AppInputDecorationTheme.darkInputDecorationTheme(),
    indicatorColor: primaryColor,
    textTheme: AppTextTheme.darkTextTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
  );
}
