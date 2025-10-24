import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/budget/add_budget.dart';

Widget buildBudgetItemCustom({
  required IconData icon,
  required Color iconColor,
  required String title,
  String? id,
  String? category,
  required String budget,
  required String remaining,
  required int index,
}) {
  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  return Container(
    padding: index == 3
        ? const EdgeInsets.only(top: 11)
        : const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: Border(
          top: index != 0
              ? Divider.createBorderSide(Get.context, width: 0.5)
              : BorderSide.none),
    ),
    child: Row(
      children: [
        // Icon with colored background
        ClipOval(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor,
              // color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon ?? getCategoryIcon(category ?? ''),
              size: 16,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Title
        Expanded(
          flex: 4,
          child: Text(
            capitalizeFirst(title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Spacer(),
        // Budget amount
        Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            color: Colors.transparent,
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
              child: SizedBox(
                // width: 60,
                child: Text(
                  '\$${budget}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),

        SizedBox(width: Get.width * 0.08),

        // Remaining amount
        SizedBox(
          width: 60,
          child: Text(
            (() {
              final value = double.tryParse(remaining) ?? 0;
              return value < 0
                  ? '- \$${value.abs().toStringAsFixed(0)}'
                  : '\$${value.toStringAsFixed(0)}';
            })(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

Widget buildDivider() {
  return Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
      ),
    ),
  );
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    super.key,
    this.title,
    this.subtitle,
    this.date,
    this.category,
    this.image,
    this.budgetAmount,
    this.remmingAmount,
    this.iconData,
  });

  final String? title;
  final String? subtitle;
  final String? date;
  final String? budgetAmount;
  final String? remmingAmount;
  final String? category;
  final String? image;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   width: 32,
        //   height: 32,
        //   decoration: BoxDecoration(
        //     color: Colors.white.withOpacity(0.9),
        //     shape: BoxShape.circle,
        //   ),
        //   child: ClipOval(
        //     child: Image.network(
        //       image.toString(),
        //       fit: BoxFit.cover,
        //       errorBuilder: (context, error, stackTrace) =>
        //           Image.asset('assets/images/defult_logo.png'),
        //       loadingBuilder: (context, child, loadingProgress) {
        //         if (loadingProgress == null) return child;
        //         return Center(
        //           child: CircularProgressIndicator(
        //             color: Colors.white,
        //             value: loadingProgress.expectedTotalBytes != null
        //                 ? loadingProgress.cumulativeBytesLoaded /
        //                     loadingProgress.expectedTotalBytes!
        //                 : null,
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
        leading:    ClipOval(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getCategoryColor(title ?? ''),
              // color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              iconData ?? getCategoryIcon(category ?? ''),
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          _formatNumber(subtitle),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  String _formatNumber(String? s) {
    final v = double.tryParse(s ?? '');
    return v == null ? '' : v.toStringAsFixed(0);
  }
}

// class CustomListItem extends StatelessWidget {
//   const CustomListItem(
//       {super.key,
//       this.title,
//       this.subtitle,
//       this.date,
//       this.category,
//       this.image,
//       this.budgetAmount,
//       this.remmingAmount});
//
//   final String? title;
//   final String? subtitle;
//   final String? date;
//   final String? budgetAmount;
//   final String? remmingAmount;
//   final String? category;
//   final String? image;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         spacing: 20,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             spacing: 19,
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   shape: BoxShape.circle,
//                 ),
//                 child: ClipOval(
//                   child: Image.network(
//                     image.toString(),
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Image.asset('assets/images/defult_logo.png'),
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           value: loadingProgress.expectedTotalBytes != null
//                               ? loadingProgress.cumulativeBytesLoaded /
//                                   loadingProgress.expectedTotalBytes!
//                               : null,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Text(
//                 title.toString(),
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           Spacer(),
//           SizedBox(width: Get.width * 0.08),
//           Text(
//             double.parse(subtitle.toString()).toStringAsFixed(0),
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ai suggestion card
Widget suggestionCard(
    {required String text,
    required VoidCallback onTap,
    required String subText}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.greenAccent.withOpacity(0.1),
      border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subText,
                //?? 'Did you face difficulties while manage expense learn how Wealth Genie can help you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 19),
        SvgPicture.asset(
          'assets/icons/chat.svg',
          height: 31,
          width: 31,
          color: Colors.white,
        )
      ],
    ),
  );
}

Widget joinDiscordCard({
  required String text,
  required VoidCallback onTap,
  required String subText,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF19C4A8),
            Colors.black.withOpacity(0.59),
          ],
        ),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 19),
          SvgPicture.asset(
            'assets/images/discord.svg',
            height: 31,
            width: 31,
          ),
        ],
      ),
    ),
  );
}

