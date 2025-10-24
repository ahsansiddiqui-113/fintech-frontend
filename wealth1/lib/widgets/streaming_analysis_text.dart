import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class AnalyzingStreamCard extends StatefulWidget {
  const AnalyzingStreamCard({super.key});

  @override
  State<AnalyzingStreamCard> createState() => _AnalyzingStreamCardState();
}

class _AnalyzingStreamCardState extends State<AnalyzingStreamCard> {
  final List<String> allSteps = [
    "Checking real time information",
    "Relevance Check",
    "Review real time data",
    "Finding Sources & Citations",
    "Hallucination Check",
  ];

  final StreamController<List<String>> _stepStreamController =
      StreamController<List<String>>();
  List<String> currentSteps = [];
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startStreamingSteps();
  }

  void _startStreamingSteps() {
    timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (currentIndex < allSteps.length) {
        currentSteps.add(allSteps[currentIndex]);
        _stepStreamController.sink.add(List.from(currentSteps));
        currentIndex++;
      } else {
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _stepStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: StreamBuilder<List<String>>(
        stream: _stepStreamController.stream,
        builder: (context, snapshot) {
          final steps = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    ImagePaths.wealthgenpng,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  addWidth(12),
                  Text(
                    "Finding best Answer...",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < currentIndex; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // 🔹 Icon depending on status
                      if (i < currentIndex - 1)
                        // ✅ Completed
                        Image.asset(
                          ImagePaths.loadcomplete,
                          height: 16,
                          fit: BoxFit.contain,
                        )
                      else
                        // ⏳ In progress
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: const Color(0xFF19C4A8),
                            strokeWidth: 2,
                          ),
                        ),

                      addWidth(12),

                      // 🔹 Text for only started steps
                      textWidget(
                        context,
                        title: allSteps[i],
                        fontSize: responTextWidth(12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        fontWeight: i < currentIndex - 1
                            ? FontWeight.w400 // Completed
                            : FontWeight.w600, // Current
                        color: i < currentIndex - 1
                            ? context.gc(AppColor.grey) // Completed: grey
                            : Colors.white, // Current: white
                      ),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

//-----------------------
//-----------------------
//-----------------------

class AnalyzingCard extends StatelessWidget {
  const AnalyzingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              ImagePaths.wealthgenpng,
              height: 32,
              fit: BoxFit.contain,
            ),
            addWidth(12),
            Text(
              "Finding best Answer...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildAnalysis(context, "Checking real time information"),
        buildAnalysis(context, "Relevance Check"),
        buildAnalysis(context, "Review real time data"),
        buildAnalysis(context, "Finding Sources & Citations"),
        buildAnalysis(context, "Hallucination Check"),
      ],
    );
  }

  Widget buildAnalysis(BuildContext context, text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Image.asset(
            ImagePaths.loadcomplete,
            height: 16,
            fit: BoxFit.contain,
          ),
          addWidth(12),
          textWidget(
            context,
            title: text,
            fontSize: responTextWidth(12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            fontWeight: FontWeight.w300, // Current
            color: context.gc(AppColor.grey), // Current: white
          ),
        ],
      ),
    );
  }
}
