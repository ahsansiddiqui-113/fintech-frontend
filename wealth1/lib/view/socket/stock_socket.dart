import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/web_socket/price_socket_controller.dart';
import 'package:wealthnx/widgets/app_text.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class StockSocket extends StatelessWidget {
  StockSocket({super.key});

  final PriceSocketController priceSocketController =
      Get.put(PriceSocketController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Socket Data'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Obx(() {
          if (priceSocketController.connectingWithSocket.value) {
            return CircularProgressIndicator();
          } else if (priceSocketController.preservedData.isEmpty) {
            return Center(child: Text('dataNotAva'.tr));
          } else {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                  // color: context.gc(AppColor.white),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final data =
                              priceSocketController.preservedData[index];

                          if (data.symbol == 'BTFH') {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  txt: "${data.companyResponse?.sym}".tr,
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppText(
                                      txt:
                                          "${data.companyResponse?.ltp == '0.0' ? data.companyResponse?.prvCls : data.companyResponse?.ltp}"
                                              .tr,
                                      textAlign: TextAlign.center,
                                    ),
                                    AppText(
                                      txt: data.companyResponse?.cur == null
                                          ? ' EGP'
                                          : " ${data.companyResponse?.cur}".tr,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Container(
                              child: Text('dataNotAva'.tr),
                            );
                          }
                        }),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
