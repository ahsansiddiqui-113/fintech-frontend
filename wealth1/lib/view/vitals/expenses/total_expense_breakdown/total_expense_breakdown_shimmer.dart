import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/utils/app_helper.dart';

class TotalExpenseShimmer extends StatelessWidget {
  const TotalExpenseShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,      // visible on black bg
      highlightColor: Colors.grey[700]!, // sweep
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Chart + Legend section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Donut placeholder (pie)
                SizedBox(
                  width: marginSide(150),
                  height: marginVertical(150),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _circle(158),
                    ],
                  ),
                ),
addWidth(20),
                // const SizedBox(width: 32),

                // Legend (top 5)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // color bar
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                           const SizedBox(width: 12),
                          _pill(width: marginSide(90), height: 10, radius: 6),
                          // const Spacer(),
                          // _pill(width: 50, height: 10, radius: 6),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 53),

            // Transactions list skeleton (no Expanded; fits inside Column safely)
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 15,
              separatorBuilder: (_, __) =>
              const Divider(color: Colors.white24, thickness: 0.5, height: 0),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // avatar circle
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // left: title + date/time (two lines) — no Expanded
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pill(width: 140, height: 12, radius: 6),
                          const SizedBox(height: 6),
                          _pill(width: 100, height: 10, radius: 6),
                        ],
                      ),

                      const Spacer(),

                      // right: amount (single line)
                      _pill(width: 70, height: 12, radius: 6),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static Widget _pill({required double width, required double height, double radius = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget _donutHole(double radius) {
    // simulate chart centerSpaceRadius (shows background through)
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: Colors.black, // your screen bg
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget _innerRing() {
    // thin ring around the donut hole to mimic your border
    return Container(
      width: 158,
      height: 158,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
    );
  }
}
