import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/networth/net_worth_new_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

class NetworthLibilitesAllSscreen extends StatefulWidget {
  NetworthLibilitesAllSscreen({super.key});

  @override
  State<NetworthLibilitesAllSscreen> createState() =>
      _NetworthLibilitesAllSscreenState();
}

class _NetworthLibilitesAllSscreenState
    extends State<NetworthLibilitesAllSscreen> {
  // final NetWorthController _controller = Get.put(NetWorthController());
  final NetWorthController _controller = Get.put(NetWorthController());

  final graphController = Get.put(NetWorthNewController());

  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];

  final RxInt selectedTab = 0.obs;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl
        .addListener(() => _controller.filterLiabilities(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl
        .removeListener(() => _controller.filterLiabilities(_searchCtrl.text));
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Liabilities'),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (_controller.networth.value == null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Empty(title: 'Liabilities', width: 70),
          );
        } else {
          final libs = _controller.filteredLiabilities;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search liabilities (type, bank, account...)',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
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
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: (_searchCtrl.text.isNotEmpty)
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  _searchCtrl
                                      .clear(); // triggers listener → resets
                                  _controller.filterLiabilities('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _controller.filterLiabilities,
                    ),
                  ),
                  addHeight(16),

                  (libs.isEmpty)
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Empty(title: 'No Liabilities', width: 70),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: libs.length,
                          itemBuilder: (context, index) {
                            final l = libs[index];

                            // Mask account safely
                            final acc = (l.accountNumber ?? '').toString();
                            final masked = (acc.isNotEmpty)
                                ? '•••${acc.substring(0, acc.length.clamp(0, 3))}'
                                : '•••';

                            final subtitle =
                                '$masked ${l.bankName ?? ''}'.trim();

                            // Logo or fallback
                            final icon = (l.bankLogo != null &&
                                    (l.bankLogo as String).isNotEmpty)
                                ? AppEndpoints.profileBaseUrl + l.bankLogo
                                : ImagePaths.expensewallet;

                            return buildIncomeDetailItem(
                              context,
                              listtype: 'Libilities',
                              index: index,
                              title: (l.type ?? l.name ?? '').toString(),
                              amount: '\$${l.amount?.toStringAsFixed(2)}',
                              length: libs.length,
                              subtitle: subtitle,
                              persentage: '',
                              icon: icon,
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     appBar: customAppBar(title: 'Liabilities'),
  //     body: Obx(() {
  //       if (_controller.isLoading.value) {
  //         return const Center(
  //             child: CircularProgressIndicator(color: Colors.white));
  //       } else if (_controller.networth.value == null) {
  //         return Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Empty(
  //             title: 'Liabilities',
  //             width: 70,
  //           ),
  //         );
  //       } else {
  //         final networth = _controller.networth.value?.body;
  //
  //         return SingleChildScrollView(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Search bar
  //                 Container(
  //                   // height: 40,
  //                   decoration: BoxDecoration(
  //                     color: Color(0xFF000000),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: TextField(
  //                       // controller: controller.searchController,
  //                       style: TextStyle(color: Colors.white),
  //                       decoration: InputDecoration(
  //                         hintText: 'Search',
  //                         fillColor: Colors.amber,
  //                         hintStyle: TextStyle(
  //                           fontSize: 13,
  //                           color: Colors.grey,
  //                         ),
  //                         border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                             borderSide: BorderSide(width: 0.5)),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                           borderSide: const BorderSide(
  //                               color: Colors.grey, width: 0.5),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                           borderSide: const BorderSide(
  //                               color: Color.fromRGBO(46, 173, 165, 1)),
  //                         ),
  //                         prefixIcon: IconButton(
  //                           icon: Icon(Icons.search, color: Colors.grey),
  //                           onPressed: () {},
  //                         ),
  //                       ),
  //                       onChanged: (value) {
  //                         // controller.filterTransactions();
  //                       }),
  //                 ),
  //                 addHeight(16),
  //                 (networth?.liabilities?.length == 0)
  //                     ? Container(
  //                         padding: EdgeInsets.symmetric(vertical: 10),
  //                         child: Empty(
  //                           title: 'Libilities',
  //                           width: 70,
  //                         ),
  //                       )
  //                     : ListView.builder(
  //                         shrinkWrap: true,
  //                         physics: const NeverScrollableScrollPhysics(),
  //                         padding: EdgeInsets.zero,
  //                         itemCount: networth?.liabilities?.length,
  //                         itemBuilder: (context, index) {
  //                           final networthlib = networth?.liabilities?[index];
  //
  //                           return buildIncomeDetailItem(
  //                             index: index,
  //                             title: networthlib?.type.toString(),
  //                             amount: networthlib?.amount?.toStringAsFixed(2),
  //                             length: networth?.liabilities?.length,
  //                             subtitle:
  //                                 '...${networthlib?.accountNumber?.substring(0, 3)} ${networthlib?.bankName}',
  //                             persentage: '',
  //                             icon: AppEndpoints.profileBaseUrl +
  //                                     (networthlib?.bankLogo ??
  //                                         ImagePaths.expensewallet) ??
  //                                 ImagePaths.expensewallet,
  //                           );
  //                         },
  //                       ),
  //               ],
  //             ),
  //           ),
  //         );
  //       }
  //     }),
  //   );
  // }
}
