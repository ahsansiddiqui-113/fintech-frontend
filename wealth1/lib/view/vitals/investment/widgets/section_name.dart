import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';

class SectionName extends StatelessWidget {
  SectionName(
      {super.key,
      required this.title,
      this.onTap,
      this.titleOnTap,
      this.onTapColor,
      this.fontSize,
      });

  String? title;
  String? titleOnTap;
  GestureTapCallback? onTap;
  Color? onTapColor;
  dynamic fontSize;
  final CommonController _commonController = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _commonController.textWidget(context,
            title: '$title',
            fontSize: fontSize ?? responTextWidth(16),
            color:Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600),

        GestureDetector(
          onTap: onTap,
          child: _commonController.textWidget(context,
              title: '$titleOnTap',
              fontSize: fontSize ?? responTextWidth(14),
              color: onTapColor ?? Color(0xFFD6D6D6),
              fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}
