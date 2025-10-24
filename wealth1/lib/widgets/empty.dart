import 'package:flutter/material.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class Empty extends StatelessWidget {
  Empty({super.key, this.title, this.width, this.height, this.subtitle});
  String? title;
  String? subtitle;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            height: height,
            width: width,
            fit: BoxFit.contain,
            ImagePaths.empty,
          ),
          SizedBox(height: 16),
          Text(
            'No $title Availble',
            style: TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Text(
            subtitle ?? 'Start spending or saving to see details here',
            style: TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
