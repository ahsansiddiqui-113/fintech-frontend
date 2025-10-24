import 'package:flutter/material.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class StatsSection extends StatelessWidget {
  StatsSection({super.key, this.icon, this.title, this.amount});

  String? icon;
  String? title;
  String? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon.toString(),
            width: 16,
            height: 16,
            color: Color(0xFFC6C6C6),
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 15),
          Text(
            '$title',
            style: const TextStyle(
              color: Color(0xFFC6C6C6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Text(
            '${amount}',
            style: TextStyle(
              color: Color(0xFFC6C6C6),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
