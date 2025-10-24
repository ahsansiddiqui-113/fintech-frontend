import 'package:flutter/material.dart';

class SectionOption extends StatelessWidget {
  SectionOption({super.key, required this.heading, this.title, this.fontSize});

  String? heading;
  String? title;
  double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$heading",
          style: TextStyle(
            color: Colors.grey,
            fontSize: fontSize ?? 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          '$title',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize ?? 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
