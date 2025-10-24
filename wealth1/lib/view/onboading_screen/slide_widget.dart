import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/app_text_theme.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/app_text.dart';

class SlideWidget extends StatelessWidget {
  SlideWidget({super.key, this.title, this.subtitle});

  String? title;
  String? subtitle;

  final CommonController _commonController = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          txt: "$title",
          style: context.interMedTextStyle().copyWith(
                color: context.gc(AppColor.white),
                fontSize: _commonController.responsiveWidth *
                    (22 / _commonController.responsiveWidth),
                fontWeight: FontWeight.w700,
              ),
        ),
        addHeight(5),
        // const SizedBox(height: 5),
        Container(
          padding: EdgeInsets.only(right: Get.width * (30 / Get.width)),
          child: AppText(
            txt: '$subtitle',
            style: context.interMedTextStyle().copyWith(
                  fontSize: _commonController.responsiveWidth *
                      (32 / _commonController.responsiveWidth),
                  fontWeight: FontWeight.w700,
                  color: context.gc(AppColor.white),
                ),
          ),
        ),
        addHeight(5),
      ],
    );
  }
}
