import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/networth/net_worth_new_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/custom_list_item.dart';
import 'package:wealthnx/widgets/empty.dart';

class ViewAllNetWorth extends StatefulWidget {
  ViewAllNetWorth({super.key});

  @override
  State<ViewAllNetWorth> createState() => _ViewAllNetWorthState();
}

class _ViewAllNetWorthState extends State<ViewAllNetWorth> {
  final NetWorthController _controller = Get.put(NetWorthController());

  final graphController = Get.put(NetWorthNewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Assets'),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (_controller.networth.value == null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SectionName(
                  title: 'Assets',
                  titleOnTap: '',
                ),
                Empty(
                  title: ' Assets',
                  width: 70,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        } else {
          final networth = _controller.networth.value?.body;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    // height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(46, 173, 165, 1)),
                        ),
                      ),
                      onChanged: (value) => _controller.filterAssets(value),
                    ),
                  ),
                  addHeight(16),
                  Obx(() {
                    final assets = _controller.filteredAssets;
                    if (assets.isEmpty) {
                      return Empty(title: 'No Assets', width: 70);
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final a = assets[index];
                        return buildIncomeDetailItem(
                          context,
                          listtype: 'Assets',
                          index: index,
                          title: a.name?.toString(),
                          amount: '\$${a.amount?.toStringAsFixed(2)}',
                          length: assets.length,
                          subtitle:
                              '...${a.accountNumber?.substring(0, 3)} ${a.bankName ?? ''}',
                          persentage: '',
                          icon: AppEndpoints.profileBaseUrl +
                              (a.bankLogo ?? ImagePaths.expensewallet),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
