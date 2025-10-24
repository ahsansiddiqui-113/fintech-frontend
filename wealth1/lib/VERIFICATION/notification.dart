import 'package:flutter/material.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 20,
              backgroundColor: Color.fromRGBO(46, 173, 165, 1),
              child: const Icon(
                Icons.notifications,
                // size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              "Instant Notifications",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              "Turn on notifications to receive timely updates, track your goals, and never miss an important financial alert.",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                // height: 1.5,
              ),
            ),
            const Spacer(),

            // "Turn on Notifications" Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Turn On Notifications Pressed");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(
                            // selectedIndex: 0,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(46, 173, 165, 1), // Theme color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Turn On Notifications",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // "skip" Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Skip Pressed");
                  Navigator.pop(context); // Navigate back or close the flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black.withAlpha(77), // Grey with 0.77 opacity
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Skip",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
