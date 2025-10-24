import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import 'package:wealthnx/models/schedule/schedule_model.dart';
import 'package:wealthnx/view/schedule/add_schedule/add_schedule_screen.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class DetailScheduleScreen extends StatelessWidget {
  final RecurringItem recurringItem;
  final String? logoUrl;

  const DetailScheduleScreen({super.key, required this.recurringItem, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final parsedDate = recurringItem.date;
    return Scaffold(
      backgroundColor: Colors.black,
      // set a background so white text is visible
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customAppBar(title: "Schedule",onBackPressed: (){
              Get.find<ScheduleController>().fetchSchedules(recurringItem.date);
              Get.back();
            }),
            const SizedBox(height: 20),

            /// Avatar
            Container(
              width: Get.width < 400 ? 32 : 40,
              height: Get.width < 400 ? 32 : 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(width: 0.5, color: Colors.grey),
              ),
              child: ClipOval(
                child: (logoUrl == null || logoUrl!.isEmpty)
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                                        'assets/images/schedule_icon.png',
                                        errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/schedule_icon.png'),
                                      ),
                    )
                    : Image.network(
                  logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/schedule_icon.png'),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Title + Priority Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recurringItem.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                // SizedBox(width: 20,),
                // buildButton("High Priority", Color(0xFF5591D5), onPressed: (){}),
              ],
            ),

            const SizedBox(height: 10),

            /// Date + Time
            Row(
              children: [
                Text(
                  parsedDate != null
                      ? "${parsedDate.day.toString().padLeft(2, '0')}/"
                          "${parsedDate.month.toString().padLeft(2, '0')}/"
                          "${parsedDate.year}"
                      : "Invalid Date",
                  style: const TextStyle(color: Colors.white),
                ),

              ],
            ),

            const SizedBox(height: 20),

            /// Description
            const Text(
              "Description",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              '${ recurringItem.description}',
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            /// Previous Payments
            const Text(
              "Previous Payments:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
if(recurringItem.prevYearTrans.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.grey,width: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "No previous payment record",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            if(recurringItem.prevYearTrans.isNotEmpty)
            /// Example list of previous payments
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey, // optional avatar bg
                          child: Icon(Icons.payment, color: Colors.white),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Subscription ${index + 1}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Yearly",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        trailing: const Text(
                          "\$223",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    // optional, change divider color
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
