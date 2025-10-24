import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_text_theme.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';

class AppText extends StatelessWidget {
  const AppText(
      {super.key,
      this.txt,
      this.style,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.onTap});

  final String? txt;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        txt ?? '',
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        style: style ??
            context.interMedTextStyle().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: CustomAppTheme.white),
      ),
    );
  }
}
