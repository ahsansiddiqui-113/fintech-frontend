import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/toggle_btn/toggle_btn_controller.dart';
import 'package:wealthnx/models/wealth_genie/chat_message_model.dart';
import 'package:wealthnx/theme/app_text_theme.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_constant.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/view/dashboard/home/home.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/widgets/app_text.dart';
import 'package:wealthnx/widgets/connectivity_dialog.dart';

final CommonController controller = Get.put(CommonController());

getShrinkSizedBox() {
  return const SizedBox.shrink();
}

addHeight([dynamic value = 10]) {
  return SizedBox(
    height: Get.height * (value.toDouble() / Get.height),
  );
}

addWidth([dynamic value = 10]) {
  return SizedBox(
    width: Get.width * (value.toDouble() / Get.width),
  );
}

responTextHeight([dynamic value = 0]) {
  return Get.height * (value / Get.height);
}

marginSide([dynamic value = 16]) {
  return Get.width * (value / Get.width);
}

marginVertical([dynamic value = 16]) {
  return Get.height * (value / Get.height);
}

responTextWidth([dynamic value = 0]) {
  return Get.width * (value / Get.width);
}

showToast(String message, [String developerName = "Usama"]) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16);
}

Widget loadingWidget({Color? loaderColor, double? size}) => Center(
      child: SpinKitFadingCube(
        color: loaderColor ?? CustomAppTheme.primaryColor,
        size: size ?? 30.0,
      ),
    );

showAlert(
    {required DialogType dialogType,
    required String title,
    String? description,
    String? btnCancelText,
    String? btnOkText,
    Color? btnOkColor,
    bool reverseBtnOrder = false,
    Color? btnCancelColor,
    VoidCallback? onCancelPress,
    VoidCallback? onOkPress,
    Function(DismissType dismissType)? onDismissCallBack,
    bool autoDismiss = true,
    bool dismissOnTouchOutside = true,
    bool dismissOnBackKeyPress = true}) {
  AwesomeDialog(
    context: Get.context as BuildContext,
    dismissOnTouchOutside: dismissOnTouchOutside,
    dialogType: dialogType,
    width: 400,
    reverseBtnOrder: reverseBtnOrder,
    animType: AnimType.bottomSlide,
    title: title,
    btnOkColor: btnOkColor,
    btnCancelColor: btnCancelColor,
    onDismissCallback: onDismissCallBack,
    autoDismiss: autoDismiss,
    desc: description ?? "",
    btnCancelText: btnCancelText ?? "dismiss".tr,
    btnOkText: btnOkText,
    btnCancelOnPress: onCancelPress ?? () {},
    btnOkOnPress: onOkPress,
    dismissOnBackKeyPress: dismissOnBackKeyPress,
  ).show();
}

void showErrorDialog(context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('error'.tr),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('ok'.tr),
        ),
      ],
    ),
  );
}

enum UrlType { simple, phone, email, sms }

void launchMyURL(String url, [UrlType type = UrlType.simple]) async {
  if (url.isEmpty) {
    return;
  }

  if (type == UrlType.phone) {
    url = "tel:$url";
  } else if (type == UrlType.email) {
    url = "mailto:$url";
  } else if (type == UrlType.sms) {
    url = "sms:$url";
  }

  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    showToast("${"failedToLaunch".tr} $url");
  }
}

void customLog(String message, [String developerName = "Usama"]) {
  if (kDebugMode) {
    log(message);
  }
}

getShadow(BuildContext context,
    {Color? color, double? blurRadius, double? spreadRadius, Offset? offset}) {
  return [
    BoxShadow(
        color: color ?? context.gc(AppColor.cardShadowColor),
        blurRadius: blurRadius ?? 24.0,
        spreadRadius: spreadRadius ?? 0.0,
        offset: offset ?? const Offset(2, 2))
  ];
}

getImportantText() {
  return const AppText(
    txt: "  *",
    textAlign: TextAlign.center,
    style: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 14, color: CustomAppTheme.red),
  );
}

void setAppInstalled() {
  var box = GetSecureStorage(password: AppConstant.dbSecurityKey);

  box.write("installed", true);
}

bool isAppInstalled() {
  var box = GetSecureStorage(password: AppConstant.dbSecurityKey);

  var msg = box.read("installed");

  return msg ?? false;
}

String convertTo2DigitString(dynamic data) {
  double? value = 0.0;
  if (data.runtimeType == String) {
    value = double.tryParse(data);
  }

  value ??= 0.0;

  String v = "";
  try {
    v = value.toStringAsFixed(2);
  } catch (e) {
    v = "0.00";
  }

  return v;
}

InputDecoration inputDecoration(BuildContext context, String hint,
    {Color? borderColor, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: const Color.fromARGB(255, 158, 158, 158),
        fontSize: 14,
        fontWeight: FontWeight.w300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
          color: borderColor ?? context.gc(AppColor.grey), width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
    ),
    filled: true,
    fillColor: context.gc(AppColor.black),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Get.width * (16 / Get.width),
      vertical: Get.height * (12 / Get.height),
    ),
    suffixIcon: suffixIcon,
  );
}

Widget orDivider(BuildContext context, {title}) {
  return Row(
    children: [
      Expanded(
          child: Divider(
        color: context.gc(AppColor.grey),
      )),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          "$title",
          style: TextStyle(fontSize: 14, color: context.gc(AppColor.grey)),
        ),
      ),
      Expanded(child: Divider(color: context.gc(AppColor.grey))),
    ],
  );
}

//Chart Shimmer Effect
Widget buildChartShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.black,
    highlightColor: Colors.grey[700]!,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          // border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
          // borderRadius: BorderRadius.circular(12),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 165,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    ),
  );
}

//Invest Chart Shimmer Effect
Widget buildInvestChartShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.black,
    highlightColor: Colors.grey[700]!,
    child: Container(
      height: 170,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

//List Shimmer effect
Widget buildlistShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[700]!,
    child: Column(
      children: [
        // Transaction items shimmer
        ...List.generate(
            3,
            (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        // Icon shimmer
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Text content shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        // Amount shimmer
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )),
      ],
    ),
  );
}

final numberFormat = NumberFormat("#,##0", "en_US"); // for comma formatting

// price formatter
String formatShortNumber(num value) {
  if (value.abs() >= 1e12) {
    return '${(value / 1e12).toStringAsFixed(value % 1e12 == 0 ? 0 : 2)}T';
  } else if (value.abs() >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(value % 1e9 == 0 ? 0 : 2)}B';
  } else if (value.abs() >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(value % 1e6 == 0 ? 0 : 2)}M';
  } else if (value.abs() >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(value % 1e3 == 0 ? 0 : 1)}k';
  } else {
    return value.toStringAsFixed(0);
  }
}

//Empty Graph
Widget isEmptyVitals({required String? title}) {
  final responseData = [
    {"monthName": "May", "total": 0},
    {"monthName": "Apr", "total": 0},
    {"monthName": "Mar", "total": 0},
    {"monthName": "Feb", "total": 0},
    {"monthName": "Jan", "total": 0},
    {"monthName": "Dec", "total": 0},
  ];

  final chartData = responseData.toList();
  final xLabels = chartData.map((e) => e['monthName'] as String).toList();
  final List<FlSpot> spots = List.generate(chartData.length, (index) {
    final total = (chartData[index]['total'] as num).toDouble();
    return FlSpot(index.toDouble(), total);
  });

  final totalSum = responseData.fold<double>(
    0,
    (sum, item) => sum + (item['total'] as num).toDouble(),
  );
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          child: ExpenseEmptyChart(spots: spots, xLabels: xLabels),
        ),
      ],
    ),
  );
}

//Empty Graph
Widget isEmptyInvest() {
  final responseData = [
    {"monthName": "May", "total": 0},
    {"monthName": "Apr", "total": 0},
    {"monthName": "Mar", "total": 0},
    {"monthName": "Feb", "total": 0},
    {"monthName": "Jan", "total": 0},
    {"monthName": "Dec", "total": 0},
  ];

  final chartData = responseData.reversed.toList();
  final xLabels = chartData.map((e) => e['monthName'] as String).toList();
  final List<FlSpot> spots = List.generate(chartData.length, (index) {
    final total = (chartData[index]['total'] as num).toDouble();
    return FlSpot(index.toDouble(), total);
  });

  final totalSum = responseData.fold<double>(
    0,
    (sum, item) => sum + (item['total'] as num).toDouble(),
  );
  return Container(
    height: 150,
    child: ExpenseEmptyChart(spots: spots, xLabels: xLabels),
  );
}

Widget buildAddButton(
    {String? title, VoidCallback? onPressed, EdgeInsetsGeometry? margin , EdgeInsetsGeometry? padding ,}) {
  return Container(
    margin: margin ??
        EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewPadding.bottom + 10,
            top: 10),
    padding:padding?? EdgeInsets.symmetric(horizontal: 12),
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        '$title',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget buildEmptyInvestGraph(BuildContext context) {
  final responseData = [
    {"monthName": "May", "total": 0},
    {"monthName": "Apr", "total": 0},
    {"monthName": "Mar", "total": 0},
    {"monthName": "Feb", "total": 0},
    {"monthName": "Jan", "total": 0},
    {"monthName": "Dec", "total": 0},
  ];

// Reverse for chronological order (old to new)
  final chartData = responseData.toList();

// X-axis labels
  final xLabels = chartData.map((e) => e['monthName'] as String).toList();

// Create spots for the line chart
  final List<FlSpot> spots = List.generate(chartData.length, (index) {
    final total = (chartData[index]['total'] as num).toDouble();
    return FlSpot(index.toDouble(), total);
  });

  final totalSum = responseData.fold<double>(
    0,
    (sum, item) => sum + (item['total'] as num).toDouble(),
  );
  print("sssss ${(totalSum == 0.0)}");
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: (totalSum == 0.0) ? 150 : 200,
          child: (totalSum == 0.0)
              // ? ExpenseEmptyChart(
              //     spots: spots,
              //     xLabels: xLabels,
              //   )
              ? InvestEmptyChart(spots: spots, xLabels: xLabels)
              : ExpenseChart(
                  spots: spots,
                  xLabels: xLabels,
                  timePeriod: 'YTD',
                ),
        ),
      ],
    ),
  );
}

Widget buildLoadingShimmerItem() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[700]!,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Get.width / 3,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: Get.width / 4,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 14,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//------------- Trans Shimmer

Widget buildTransShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[700]!,
    child: Column(
      children: [
        ...List.generate(
            3,
            (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )),
      ],
    ),
  );
}

//////--------

String formatNumberWithSuffix(String value) {
  if (value.isEmpty) return '0';

  try {
    // Remove any commas or currency symbols that might be in the string
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    num numericValue = num.parse(cleanValue);

    // Handle negative values
    bool isNegative = numericValue < 0;
    numericValue = numericValue.abs();

    if (numericValue >= 1000000000000) {
      // Trillions
      double formattedValue = numericValue / 1000000000000;
      return '${isNegative ? '-' : ''}${formattedValue.toStringAsFixed(formattedValue.truncateToDouble() == formattedValue ? 0 : 1)}T';
    } else if (numericValue >= 1000000000) {
      // Billions
      double formattedValue = numericValue / 1000000000;
      return '${isNegative ? '-' : ''}${formattedValue.toStringAsFixed(formattedValue.truncateToDouble() == formattedValue ? 0 : 1)}B';
    } else if (numericValue >= 1000000) {
      // Millions
      double formattedValue = numericValue / 1000000;
      return '${isNegative ? '-' : ''}${formattedValue.toStringAsFixed(formattedValue.truncateToDouble() == formattedValue ? 0 : 1)}M';
    } else if (numericValue >= 1000) {
      // Thousands (optional)
      double formattedValue = numericValue / 1000;
      return '${isNegative ? '-' : ''}${formattedValue.toStringAsFixed(formattedValue.truncateToDouble() == formattedValue ? 0 : 1)}K';
    } else {
      // Less than 1000
      return '${isNegative ? '-' : ''}${numericValue.toStringAsFixed(numericValue.truncateToDouble() == numericValue ? 0 : 1)}';
    }
  } catch (e) {
    // Return original value if parsing fails
    return value;
  }
}

/////////////
String extractVisibleText(String input) {
  return input.replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '').trim();
}

String formatDate(String isoDateString) {
  try {
    DateTime dateTime = DateTime.parse(isoDateString).toLocal();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  } catch (e) {
    return 'Invalid date';
  }
}

String formatDateAndTime(String isoDateString) {
  try {
    DateTime dateTime = DateTime.parse(isoDateString).toLocal();
    return DateFormat("MM-dd-yyyy   hh:mm a").format(dateTime);
  } catch (e) {
    return 'Invalid date';
  }
}

Widget buildIncomeDetailItem(BuildContext context,
    {String? listtype,
    String? title,
    String? amount,
    String? subtitle,
    String? persentage,
    String? logo,
    String? icon,
    int? length,
    int? index}) {
  print('Logo : $logo');
  print('Icon : $icon');
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              padding: (logo.toString() == 'null' || logo.toString().isEmpty)
                  ? EdgeInsets.all(2)
                  : EdgeInsets.all(0),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 0.5, color: context.gc(AppColor.white)),
                color: (logo.toString() == 'null' || logo.toString().isEmpty)
                    ? Colors.transparent
                    : const Color.fromARGB(0, 228, 194, 194),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (logo.toString() == 'null' || logo.toString().isEmpty)
                    ? Image.asset(
                        listtype == 'Assets'
                            ? ImagePaths.dfasstes
                            : listtype == 'Libilities'
                                ? ImagePaths.dfliabilities
                                : listtype == 'Income'
                                    ? ImagePaths.dfincome
                                    : listtype == 'Expense'
                                        ? ImagePaths.dfexpense
                                        : listtype == 'Budget'
                                            ? ImagePaths.dfbudget
                                            : ImagePaths.dfaccount,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(ImagePaths.dfaccount),
                      )
                    : Image.network(
                        logo.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(ImagePaths.dfaccount),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ),
            addWidth(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
            // Spacer(),
            addWidth(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (persentage != null)
                  Text(
                    persentage,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
      if (index! < length! - 1)
        Divider(
          color: Colors.grey,
          height: 2,
          thickness: 0.25,
        ),
    ],
  );
}

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food_and_drink':
    case 'food':
      return Icons.fastfood;
    case 'lifestyle':
      return Icons.wine_bar;
    case 'transportation':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'grocery':
    case 'groceries':
      return Icons.shopping_cart;
    case 'entertainment':
      return Icons.music_note;
    case 'housing':
      return Icons.home;
    case 'utilities':
      return Icons.bolt;
    case 'health':
      return Icons.medical_services;
    case 'education':
      return Icons.school;
    case 'salary':
    case 'savings':
      return Icons.savings;
    case 'investments':
      return Icons.trending_up;
    default:
      return Icons.category;
  }
}

Widget textWidget(BuildContext context,
    {title, fontWeight, fontSize, color, textAlign, maxLines, overflow}) {
  return AppText(
    txt: title,
    textAlign: textAlign,
    style: context.interMedTextStyle().copyWith(
          color: color ?? context.gc(AppColor.white),
          fontSize: Get.width * (fontSize / Get.width),
          fontWeight: fontWeight,
          overflow: overflow,
        ),
    maxLines: maxLines,
  );
}

Color getCategoryColor(String category) {
  final colors = <Color>[
    const Color(0xFFD4C595),
    const Color(0xFFBAD3A0),
    const Color(0xFFCBA187),
    const Color(0xFF8B9CCF),
    const Color(0xFFD3A0A0),
  ];
  final hash = category.hashCode;
  return colors[hash.abs() % colors.length];
}

IconData getIconForCategory(String category) {
  switch (category.toUpperCase()) {
    case 'TRAVEL':
      return Icons.flight;
    case 'TRANSPORTATION':
      return Icons.directions_bus;
    case 'TRANSPORT':
      return Icons.directions_car;
    case 'ENTERTAINMENT':
      return Icons.movie;
    case 'GENERAL_MERCHANDISE':
      return Icons.shopping_cart;
    case 'FOOD_AND_DRINK':
      return Icons.fastfood;
    case 'FOOD':
      return Icons.restaurant;
    case 'HOUSING':
      return Icons.house;
    case 'LOAN_PAYMENTS':
      return Icons.payment;
    case 'GENERAL_SERVICES':
      return Icons.miscellaneous_services;
    case 'PERSONAL_CARE':
      return Icons.spa;
    case 'INVESTMENTS_CONTRIBUTION':
      return Icons.trending_up;
    case 'INVESTMENTS_DIVIDEND':
      return Icons.trending_up;
    case 'INVESTMENTS_INTEREST':
      return Icons.trending_up;
    case 'INVESTMENTS_SELL':
      return Icons.trending_up;
    case 'INVESTMENT ':
      return Icons.trending_up;
    case 'Utility ':
      return Icons.home_filled;
    case 'Other':
      return Icons.content_paste_go_outlined;
    case 'SALARY':
    case 'INCOME':
      return Icons.attach_money;

    default:
      return Icons.account_balance_wallet;
  }
}

Widget coinTypeShimmer(BuildContext context) {
  return Container(
    width: responTextWidth(190),
    margin: EdgeInsets.only(right: responTextWidth(12)),
    padding: EdgeInsets.all(responTextWidth(8)),
    decoration: BoxDecoration(
      border: Border.all(color: context.gc(AppColor.greyDialog)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: responTextWidth(36),
                height: responTextHeight(36),
                decoration: BoxDecoration(
                  color: context.gc(AppColor.grey),
                  shape: BoxShape.circle,
                ),
              ),
              addWidth(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: responTextWidth(60),
                    height: responTextHeight(16),
                    color: context.gc(AppColor.grey),
                  ),
                  addHeight(4),
                  Container(
                    width: responTextWidth(40),
                    height: responTextHeight(12),
                    color: context.gc(AppColor.grey),
                  ),
                ],
              ),
            ],
          ),
          addHeight(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: responTextWidth(40),
                        height: responTextHeight(14),
                        color: context.gc(AppColor.grey),
                      ),
                      Icon(
                        Icons.arrow_drop_up,
                        color: context.gc(AppColor.transparent),
                        size: responTextWidth(25),
                      ),
                    ],
                  ),
                  addHeight(4),
                  Container(
                    width: responTextWidth(40),
                    height: responTextHeight(16),
                    color: context.gc(AppColor.grey),
                  ),
                ],
              ),
              Container(
                width: responTextWidth(50),
                height: responTextHeight(20),
                color: context.gc(AppColor.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

List<ResourceLink>? parseResources(String content) {
  final regex = RegExp(r'\[(.*?)\]\((.*?)\)');
  final matches = regex.allMatches(content);

  if (matches.isEmpty) return null;

  return matches
      .map((m) => ResourceLink(
            title: m.group(1) ?? "",
            url: m.group(2) ?? "",
          ))
      .toList();
}

Widget toggleBtnDemoReal(BuildContext context) {
  final controller = Get.put(ToggleBtnController());

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  return Obx(() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: context.gc(AppColor.primary), width: 0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Demo Button
          GestureDetector(
            onTap: () => controller.toggle(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: controller.isDemo.value
                    ? context.gc(AppColor.primary)
                    : context.gc(AppColor.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
              child: textWidget(
                context,
                title: "Demo",
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          addWidth(5),

          // Connect Account Button
          GestureDetector(
            onTap: () {
              if (connectivityController.isConnected.value == false) {
                Get.dialog(ConnectivityDialog(
                  onPressed: () {
                    Get.back();
                    controller.toggle(true);
                  },
                ), barrierDismissible: false);
                controller.toggle(false);
              } else {
                controller.toggle(true);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: controller.isDemo.value
                    ? context.gc(AppColor.transparent)
                    : context.gc(AppColor.primary),
                borderRadius: BorderRadius.circular(30),
              ),
              child: textWidget(
                context,
                title: "Connect Account",
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  });
}

//extract the height
int extractHeightFromUrl(String url) {
  Uri uri = Uri.parse(url);
  String? heightParam = uri.queryParameters['height'];
  if (heightParam != null) {
    return int.tryParse(heightParam) ?? 0;
  }
  return 0;
}
