import 'package:flutter/material.dart';

class FilterChart extends StatefulWidget {
  FilterChart({super.key, this.selectedTab});
  String? selectedTab;

  @override
  State<FilterChart> createState() => _FilterChartState();
}

class _FilterChartState extends State<FilterChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTab('YTD'),
          Spacer(),
          _buildTab('1 Y'),
          Spacer(),
          _buildTab('6 M'),
          Spacer(),
          _buildTab('1 M'),
          Spacer(),
          _buildTab('1 W'),
          Spacer(),
          _buildTab('1 H'),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = widget.selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.selectedTab = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            // border: Border(
            //   bottom: BorderSide(
            //       color: isSelected ? Colors.white : Colors.transparent),
            // ),
            color: isSelected ? Color(0xFF313131) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: isSelected ? Color(0xFF313131) : Colors.transparent,
                width: 0.25)),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
