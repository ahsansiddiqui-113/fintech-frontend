import 'package:flutter/material.dart';
import 'package:wealthnx/utils/app_helper.dart';

class AssetLibType extends StatelessWidget {
  AssetLibType({super.key, this.amount, this.title, this.color});
  String? title;
  String? amount;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            // flex: 3,
            child: Text(
              '$title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          addWidth(marginSide(50)),
          // Spacer(),
          Text(
            '\$$amount',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
