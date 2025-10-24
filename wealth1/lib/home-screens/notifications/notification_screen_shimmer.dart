import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/utils/app_helper.dart';

class NotificationScreenShimmer extends StatelessWidget {
  const NotificationScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,      // visible on black bg
      highlightColor: Colors.grey[700]!, // sweep
      child: SingleChildScrollView(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, __) =>
          const Divider(color: Colors.white24, thickness: 0.5, height: 0),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pill(width: 80, height: 12, radius: 6),
                          const SizedBox(height: 6),
                          _pill(width: 140, height: 10, radius: 6),
                        ],
                      ),
                      const Spacer(),
                      _pill(width: 50, height: 12, radius: 6),
                    ],
                  ),
                ),
                Divider(color: Colors.white54,thickness: 0.5,)
              ],
            );
          },
        ),
      ),
    );
  }

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
  }
