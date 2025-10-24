import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/utils/app_helper.dart';

class CashFlowShimmer extends StatelessWidget {
  const CashFlowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.black,
        highlightColor: Colors.grey[700]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(height: 60, width: 150,
                  color: Colors.transparent,
                  borderColor: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 10,
                          color: Colors.white,
                        ),
                        addHeight(6),
                        Container(
                          width: 70,
                          height: 20,
                          color: Colors.white,
                        ),
                        addHeight(6),
                      ],
                    ),
                  )
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(height: 70, width: marginSide(150),
                      borderColor: false,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 10,
                              color: Colors.white,
                            ),
                            addHeight(6),
                            Container(
                              width: 100,
                              height: 15,
                              color: Colors.white,
                            ),
                            addHeight(6),
                            Container(
                              width: 50,
                              height: 5,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                  ),
                  box(height: 70, width: marginSide(150),
                      color: Colors.transparent,
                      borderColor: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 10,
                              color: Colors.white,
                            ),
                            addHeight(6),
                            Container(
                              width: 100,
                              height: 15,
                              color: Colors.white,
                            ),
                            addHeight(6),
                            Container(
                              width: 50,
                              height: 5,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
              const SizedBox(height: 24),
              box(height: 260, width: double.infinity),
              const SizedBox(height: 24),
              box(
                height: 200,
                width: double.infinity,
                color: Colors.transparent,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 70,
                            height: 20,
                            color: Colors.white,
                          ),
                          Container(
                            width: 70,
                            height:20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      addHeight(20),
                      Column(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // LEFT side: two lines stacked
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 60,
                                      height: 10,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),

                                // RIGHT side: one line
                                Container(
                                  width: 40,
                                  height: 10,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              addHeight(20),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: Get.width * 0.2,
                          height: 12,
                          color: Colors.white,
                        ),
                        Container(
                          width: Get.width * 0.2,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Column(
                      children: List.generate(4, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Circle icon
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  addWidth(20),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: Get.width * 0.1,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              addHeight(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget box({
    required double height,
    double? width,
    double radius = 12,
    Widget? child,
    Color color = Colors.white,
    bool borderColor = true,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color:borderColor ? Colors.grey[800]!: Colors.transparent),
      ),
      child: child,
    );
  }
}
