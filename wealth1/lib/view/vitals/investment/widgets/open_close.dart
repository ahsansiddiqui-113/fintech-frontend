import 'package:flutter/material.dart';

class OpenClose extends StatelessWidget {
  OpenClose(
      {super.key, this.title, required this.childWidget, this.titlefontSize});

  String? title;
  double? titlefontSize;
  Widget childWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$title',
            style: TextStyle(
              fontSize: titlefontSize ?? 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Spacer(),
          childWidget,

          // Icon(Icons.chevron_right, color: Colors.white, size: 20),
        ],
      ),
    );
    ;
  }
}
