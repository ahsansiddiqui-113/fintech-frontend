import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/webview_news/news_details_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget newsCustomWidget({
  required String title,
  required String url,
  required String publishedDate,
  required String image,
  required CryptoNewsModel cryptoNewsModel,
}) {
  String truncateToWords(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return words.take(maxWords).join(' ') + '...';
  }

  final truncatedTitle = truncateToWords(title, 19);

  return GestureDetector(
    onTap: () {
      if (url == '') {
        print("not open");
      }
      Get.to(() => WebViewPage(
            url: url ?? '',
            title: title ?? 'News Details',
          ));
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 16),
      height: responTextWidth(180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Get.context!.gc(AppColor.black).withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(responTextWidth(12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Get.context!.gc(AppColor.transparent),
                    Get.context!.gc(AppColor.black).withOpacity(0.8),
                  ],
                ),
              ),
              child: textWidget(
                Get.context!,
                title: truncatedTitle,
                fontSize: responTextWidth(16),
                color: Color(0xffF4F4F4),
                fontWeight: FontWeight.w400,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            top: responTextHeight(10),
            right: responTextWidth(10),
            child: textWidget(
              Get.context!,
              title: publishedDate != null
                  ? timeago.format(DateTime.parse(publishedDate))
                  : '',
              //DateFormat('MMM dd, yyyy h:mm a')
              // .format(DateTime.parse(news.publishedDate!))
              // : '',
              fontSize: responTextWidth(12),
              fontWeight: FontWeight.w600,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
  // return ListTile(
  //   title: Text(news.title ?? 'No Title'),
  //   subtitle: Text(news.site ?? ''),
  // );
}
