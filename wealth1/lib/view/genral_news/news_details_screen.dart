// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
//
// import '../../controller/comman_controller.dart';
// import '../../utils/app_helper.dart';
// import '../../widgets/custom_app_bar.dart';
//
// class NewsDetailsScreen extends StatelessWidget {
//   const NewsDetailsScreen({super.key, required this.cryptoNewsModel});
//
//   final CryptoNewsModel cryptoNewsModel;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: customAppBar(title: 'Fintech Insider'),
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Image(
//                 image: NetworkImage(cryptoNewsModel.image.toString()),
//                 // height: 400,
//               ),
//               Positioned(
//                   top: 50,
//                   left: 10,
//                   child: IconButton(
//                       onPressed: () => Get.back(),
//                       icon: Icon(Icons.arrow_back_ios)))
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
//             child: Column(
//               // spacing: 12,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   alignment: Alignment.centerRight,
//                   child: Get.put(CommonController()).textWidget(
//                     Get.context!,
//                     title: DateFormat('yyyy-MM-dd hh:mm:a').format(
//                         DateTime.parse(cryptoNewsModel.publishedDate ?? '')),
//                     // ?? '',
//                     fontSize: responTextWidth(12),
//                     fontWeight: FontWeight.w600,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: cryptoNewsModel.title ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 12),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: 'About',
//                   fontSize: responTextWidth(14),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 5),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: cryptoNewsModel.text ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 12),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: 'Source' ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: cryptoNewsModel.publisher ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 12),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: '' ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Get.put(CommonController()).textWidget(
//                   Get.context!,
//                   title: cryptoNewsModel.url ?? '',
//                   fontSize: responTextWidth(16),
//                   fontWeight: FontWeight.w600,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
