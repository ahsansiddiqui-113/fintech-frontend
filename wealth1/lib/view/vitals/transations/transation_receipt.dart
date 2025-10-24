import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class TransationReceipt extends StatelessWidget {
  TransationReceipt(
      {super.key, this.id, this.name, this.amount, this.date, this.category});
  String? id;
  String? name;
  String? amount;
  String? date;
  String? category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Transactions Details'),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: marginSide() * 2, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              addHeight(50),
              Image.asset(
                width: 150,
                ImagePaths.tick,
              ),
              addHeight(36),
              Text(
                'Transaction Successfully',
                style: TextStyle(
                    color: Color(0xff959595),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${amount ?? "0"}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800),
              ),
              addHeight(60),
              Column(
                children: [
                  transDetail(heading: 'Recipient', title: '${name ?? "-"}'),
                  addHeight(16),
                  Divider(height: 0.25, color: Colors.grey, thickness: 0),
                  addHeight(16),
                  transDetail(
                      heading: 'Category',
                      title: '${category == 'Uncategorized' ? 'Other' : category ?? "-"}'),
                  addHeight(16),
                  Divider(height: 0.25, color: Colors.grey, thickness: 0),
                  addHeight(16),
                  transDetail(
                      heading: 'Transfer Date',
                      title: date != null
                          ? DateFormat('MM - dd - yyyy')
                          .format(DateTime.parse(date!).toLocal())
                          : '-'),
                  addHeight(16),
                  Divider(height: 0.25, color: Colors.grey, thickness: 0),
                  addHeight(16),
                  transDetail(
                      heading: 'Transfer Time',
                      title: date != null
                          ? DateFormat('hh:mm a')
                          .format(DateTime.parse(date!).toLocal())
                          : '-'),
                ],
              ),
              addHeight(40),
              buildAddButton(
                  title: 'Done',
                  onPressed: () {
                    Get.back();
                  }),
              addHeight(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget transDetail({heading, title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$heading: ',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Expanded(
          child: Text(
            '$title',
            maxLines: 3,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
