import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import 'package:wealthnx/models/schedule/schedule_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/schedule/add_schedule/add_schedule_screen.dart';
import 'package:wealthnx/view/schedule/detail_schedule_screen/detail_schedule_screen.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Color> getDotColors(int count) {
    if (count == 1) return [CustomAppTheme.gradientGreenColor];
    if (count == 2) {
      return [
        CustomAppTheme.gradientGreenColor,
        CustomAppTheme.gradientBlueColor
      ];
    }
    if (count == 3) {
      return [
        CustomAppTheme.gradientGreenColor,
        CustomAppTheme.gradientBlueColor,
        CustomAppTheme.redColor1
      ];
    }
    return [];
  }
  @override
  void initState() {
    super.initState();
    final controller = Get.find<ScheduleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.currentDate.value = DateTime.now();
      // final lastDay = DateTime(controller.currentDate.value.year, controller.currentDate.value.month + 1, 0);
      // final anchorIndex = ( controller.currentDate.value.day.clamp(1, lastDay.day)) - 1;
      // controller.selectedIndex.value = anchorIndex;
      controller.rebuildFor(controller.currentDate.value);
      controller.fetchSchedules(controller.currentDate.value);
    });
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// Sticky AppBar
            SliverPersistentHeader(
              pinned: true,
              delegate: MyHeaderDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: customAppBar(
                  title: "Schedule",
                  showAddIcon: true,
                  onAddPressed: () async {
                    // Get.to(() => const AddScheduleScreen());
                    final changed =
                        await Get.to(() => const AddScheduleScreen());
                    if (changed == true) {
                      controller.fetchSchedules(controller.currentDate.value);
                    }
                  },
                ),
              ),
            ),

            /// Horizontal date selector
            SliverToBoxAdapter(
              child: Column(
                children: [
                  /// Month + Year with arrows
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Left Arrow
                        GestureDetector(
                          onTap: controller.isSwitchingMonth.value
                              ? null
                              : () => controller.changeMonth(-1),
                          child: Obx(() => Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.gc(AppColor.grey),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_left_outlined,
                                  size: 28,
                                  color: controller.isSwitchingMonth.value
                                      ? Colors.white38
                                      : Colors.white,
                                ),
                              )),
                        ),

                        /// Month & Year
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  MonthYearPickerDialog(controller: controller),
                            );
                          },
                          child: Obx(() {
                            final isLoading = controller.isSwitchingMonth.value;
                            final date = controller.currentDate.value;
                            return isLoading
                                ? Column(
                                    children: const [
                                      // Approx sizes matching your texts
                                      ShimmerBlock(width: 110, height: 22),
                                      SizedBox(height: 4),
                                      ShimmerBlock(width: 60, height: 16),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        DateFormat.MMMM().format(date),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.y().format(date),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  );
                          }),
                        ),

                        /// Right Arrow
                        GestureDetector(
                          onTap: controller.isSwitchingMonth.value
                              ? null
                              : () => controller.changeMonth(1),
                          child: Obx(() => Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.gc(AppColor.grey),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_right_outlined,
                                  size: 28,
                                  color: controller.isSwitchingMonth.value
                                      ? Colors.white38
                                      : Colors.white,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),

                  /// Your existing days widget
                  Obx(() {
                    return !controller.showMore.value
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SizedBox(
                              height: Get.height * 0.12,
                              child: Obx(() {
                                final selected = controller.selectedIndex.value;
                                final days = controller.monthDays; // RxList

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    const edge = 12.0;
                                    const gap = 8.0;
                                    const visible = 5;
                                    final available = constraints.maxWidth -
                                        (edge * 2) -
                                        (gap * (visible - 2));
                                    final itemWidth = available / visible;
                                    const tileHeight = 70.0;
                                    const between = 8.0;
                                    final itemExtent = itemWidth + gap;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      controller.updateViewport(
                                        viewportWidth: constraints.maxWidth,
                                        itemExtent: itemExtent,
                                        edge: edge,
                                        gap: gap,
                                        itemCount: days.length,
                                      );
                                    });
                                    return ListView.builder(
                                      controller: controller.scrollController,
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: edge),
                                      // itemExtent: itemWidth + gap,
                                      itemCount: days.length,
                                      itemBuilder: (context, index) {
                                        final item = days[index];
                                        final isSelected = selected == index;
                                        if (item["fullDate"] == null) {
                                          return const SizedBox.shrink();
                                        }
                                         return Align(
                                          alignment: Alignment.centerLeft,
                                          child: SizedBox(
                                            width: itemWidth,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  controller.selectDay(index),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Top pill with fixed height
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeInOut,
                                                    constraints:
                                                        const BoxConstraints(
                                                      minHeight: tileHeight,
                                                      maxHeight: tileHeight,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 10,
                                                      horizontal: 15,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: isSelected &&  item["date"] != ''
                                                          ? const LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Color(
                                                                    0xFF318578),
                                                                Color(
                                                                    0xFF0C1F1C),
                                                              ],
                                                              stops: [
                                                                0.05,
                                                                1.0
                                                              ], // more black
                                                            )
                                                          : null,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: isSelected
                                                          ? const Border(
                                                              top: BorderSide(
                                                                  color: Color(
                                                                      0xFF1D9A9163)),
                                                            )
                                                          : null,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          item["day"] ?? '',
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.white
                                                                    .withOpacity(
                                                                        0.55),
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          item["date"] ?? '',
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.white
                                                                    .withOpacity(
                                                                        0.55),
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 1.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: between),

                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }),
                            ),
                          )
                        : CalendarWidget(controller: controller,);
                  }),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              controller.changeCalender();
                            },
                            child: Text(
                              controller.showMore.value
                                  ? "show less"
                                  : "show more",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF848484)),
                            )),
                        Icon(
                            controller.showMore.value
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Color(0xFF848484))
                      ],
                    );
                  }),
                  addHeight(12)
                ],
              ),
            ),

            /// Subscription + title
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SubscriptionSummary(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      "Today Schedule",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Obx(() {
                final controller = Get.find<ScheduleController>();
                final expenses =
                    controller.expenseRecurring.value?.body.recurringList ?? [];
                if (controller.isLoadingExpense.value) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6, // number of shimmer items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Shimmer.fromColors(
                          baseColor: Colors.black,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 80, // height of each expense shimmer card
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                if (expenses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: const Text(
                        "No Task yet. Start Schedule to see details here",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                // Group expenses by category
                Map<String, List<RecurringItem>> groupedExpenses = {};
                for (var expense in expenses) {
                  if (!groupedExpenses.containsKey(expense.category)) {
                    groupedExpenses[expense.category] = [];
                  }
                  groupedExpenses[expense.category]!.add(expense);
                }

                return Column(
                  children: groupedExpenses.entries.map((entry) {
                    final category = entry.key;
                    final categoryList = entry.value;
                    final totalAmount = categoryList.fold<double>(
                        0, (sum, item) => sum + item.amount);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header with total amount
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "\$${totalAmount.toInt()}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // List of expenses under this category
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryList.length,
                            itemBuilder: (context, index) {
                              final expense = categoryList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                child: GestureDetector(
                                  onTap: () async {
                                    final changed =
                                        await Get.to(() => DetailScheduleScreen(
                                              recurringItem: expense,
                                              logoUrl: expense.logoUrl,
                                            ));
                                    if (changed == true) {
                                      controller.fetchSchedules(
                                          controller.currentDate.value);
                                    }
                                  },
                                  child: CustomBillCard(
                                    avatarUrl: expense.logoUrl,
                                    title: expense.name,
                                    description: expense.recurrenceInterval,
                                    price:
                                        "${expense.amount.toInt().toString()}",
                                    dividerColor: CustomAppTheme.primaryColor,
                                    avatarIcon:categoryList[index].category ==  'OTHER'? null
                                      : getIconForCategory(categoryList[index].category),
                                    IconColors:categoryList[index].category ==  'OTHER'? null
                                        : getCategoryColor(categoryList[index].category),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final ScheduleController controller;
  const CalendarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final monthDays = controller.monthDays;
      final selectedIndex = controller.selectedIndex.value;

      if (monthDays.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          addHeight(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                .map(
                  (e) => Expanded(
                child: Center(
                  child: Text(
                    e,
                    style: const TextStyle(
                      color: Color(0xFFE6E6E6),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          // Full calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(5),
            itemCount: monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              // final item = monthDays[index];
              // final date = item["fullDate"] as DateTime;
              final item = monthDays[index];
              final date = item['fullDate'] as DateTime?;

              if (date == null) {
                return const SizedBox.shrink(); // empty cell
              }

              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  controller.selectDay(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:isSelected? const LinearGradient(
                        begin: Alignment
                            .topCenter,
                        end: Alignment
                            .bottomCenter,
                        colors: [
                          Color(
                              0xFF318578),
                          Color(
                              0xFF0C1F1C),
                        ],
                        stops: [
                          0.05,
                          1.0
                        ], // more black
                      ): null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          isToday ? FontWeight.bold : FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

// Custom SliverPersistentHeaderDelegate
class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  MyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant MyHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

class CustomCategoryButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const CustomCategoryButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(46, 173, 165, 1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isActive ? const Color.fromRGBO(46, 173, 165, 1) : Colors.grey,
            width: 0.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String value;
  final String label;

  const InfoBox({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: CustomAppTheme.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style:  TextStyle(
                fontSize: responTextWidth(10),
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionSummary extends StatelessWidget {
  const SubscriptionSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    final border = Border.all(color: CustomAppTheme.grey, width: 0.5);
    final radius = BorderRadius.circular(12);

    return Obx(() {
      final loading = controller.isLoadingExpense.value;
      final data = controller.expenseRecurring.value?.body;

      // Real values (when loaded)
      final monthlyAmount = data?.monthlyAmount.toInt().toString() ?? "0";
      final todayAmount = data?.dailyAmount.toInt().toString() ?? "0";
      final totalSubs = data?.totalSubscription.toString() ?? "0";

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: loading
            ? _subscriptionSummaryShimmer()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: InfoBox(
                          value: "\$$monthlyAmount", label: "Monthly Amount")),
                  _summaryDividerAsset(),
                  Expanded(
                      child: InfoBox(
                          value: "\$$todayAmount", label: "Today Amount")),
                  _summaryDividerAsset(),
                  Expanded(
                      child: InfoBox(
                          value: totalSubs, label: "Total Subscriptions")),
                ],
              ),
      );
    });
  }
}

class CustomBillCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String? avatarUrl;
  final IconData? avatarIcon;
  final Color? dividerColor;
  final DateTime? date;
  final  Color? IconColors;

  const CustomBillCard(
      {super.key,
      required this.title,
      required this.description,
      required this.price,
      this.avatarUrl,
      this.avatarIcon,
      this.dividerColor,
      this.date,
      this.IconColors
      });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Main Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Vertical divider
              Container(
                width: 3,
                height: 60,
                decoration: BoxDecoration(
                  color: dividerColor ,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),

              /// Avatar
              Container(
                width: screenWidth < 400 ? 32 : 40,
                height: screenWidth < 400 ? 32 : 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(width: 0.5, color: Colors.grey)
                ),
                child: ClipOval(
                  child: (avatarUrl == null || avatarUrl!.isEmpty)
                      ? avatarIcon != null && IconColors != null?
                  ClipOval(
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                          color: IconColors, shape: BoxShape.circle),
                      child: Icon(
                          avatarIcon ?? getCategoryIcon(title ?? ''),
                          size: 18,
                          color: Colors.white),
                    ),
                  ) : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                            'assets/images/schedule_icon.png',width: 18,height: 18,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/schedule_icon.png',),
                          ),
                      )
                       :Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/schedule_icon.png'),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(width: 10),

              /// Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              addWidth(20),
              /// Price at the end
              Column(
                children: [
                  Text(
                   price == '0' ? '' : '\$${price}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // if (date != null)
                  //   Text(
                  //     DateFormat('dd/MM/yyyy').format(date!), // e.g. 15/09/2025
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: Colors.grey.shade600,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class MonthYearPickerDialog extends StatefulWidget {
  final ScheduleController controller;

  const MonthYearPickerDialog({super.key, required this.controller});

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  late final int currentYear;
  late final int currentMonth;

  late int selectedYear;
  late int selectedMonth; // 1..12

  List<int> _visibleMonthsForYear(int year) {
    if (year < currentYear) {
      return List<int>.generate(12, (i) => i + 1); // All months
    }
    return List<int>.generate(currentMonth, (i) => i + 1);
  }

  List<int> get _years =>
      List<int>.generate(currentYear - 2000 + 1, (i) => 2000 + i);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;

    final anchor = widget.controller.currentDate.value;
    selectedYear = anchor.year > currentYear ? currentYear : anchor.year;
    selectedMonth = anchor.month;

    final visibleMonths = _visibleMonthsForYear(selectedYear);
    if (!visibleMonths.contains(selectedMonth)) {
      selectedMonth =
          visibleMonths.isNotEmpty ? visibleMonths.last : currentMonth;
    }

    monthController = FixedExtentScrollController(
      initialItem: _visibleMonthsForYear(selectedYear).indexOf(selectedMonth),
    );
    yearController = FixedExtentScrollController(
      initialItem: selectedYear - 2000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthsForYear = _visibleMonthsForYear(selectedYear);

    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 12, left: 16, right: 8),
      // ADDED: close icon on the right
      title: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 22),
              onPressed: () => Get.back(), // or Navigator.pop(context)
              tooltip: 'Close',
            ),
          ),
          const Text(
            'Select Month & Year',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
          ),
          addHeight(10),
        ],
      ),
      content: SizedBox(
        height: marginVertical(240),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text('Month',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Year',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: Get.height * 0.21,
              child: Row(
                children: [
                  // MONTH WHEEL
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: monthController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        if (monthsForYear.isEmpty) return;
                        setState(() => selectedMonth = monthsForYear[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount:
                            monthsForYear.isEmpty ? 1 : monthsForYear.length,
                        builder: (context, index) {
                          if (monthsForYear.isEmpty) {
                            return const Center(
                              child: Text('—',
                                  style: TextStyle(color: Colors.white38)),
                            );
                          }
                          final m = monthsForYear[index];
                          final isSel = m == selectedMonth;
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: isSel ? Colors.white : Colors.white54,
                              fontSize: isSel ? 18 : 15,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            child: Center(
                              child: Text(
                                DateFormat.MMMM().format(DateTime(2000, m)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // YEAR WHEEL
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: yearController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedYear = _years[index];
                          final newMonths = _visibleMonthsForYear(selectedYear);

                          if (!newMonths.contains(selectedMonth)) {
                            selectedMonth = newMonths.isNotEmpty
                                ? newMonths.last
                                : currentMonth;
                          }

                          // Snap month wheel to valid index
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final idx = _visibleMonthsForYear(selectedYear)
                                .indexOf(selectedMonth);
                            if (idx >= 0) monthController.jumpToItem(idx);
                          });
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _years.length,
                        builder: (context, index) {
                          final y = _years[index];
                          final isSel = y == selectedYear;
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: isSel ? Colors.white : Colors.white54,
                              fontSize: isSel ? 18 : 15,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            child: Center(child: Text('$y')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              widget.controller.goToMonthYear(selectedYear, selectedMonth);
              final firstDay = DateTime(selectedYear, selectedMonth, 1);
              widget.controller.fetchSchedules(firstDay);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Ok',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}

Widget _subscriptionSummaryShimmer() {
  final base = Colors.black;
  final highlight = Colors.grey[700]!;

  return Shimmer.fromColors(
    baseColor: base,
    highlightColor: highlight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _summaryItemSkeleton()),
        _summaryDividerGhost(),
        Expanded(child: _summaryItemSkeleton()),
        _summaryDividerGhost(),
        Expanded(child: _summaryItemSkeleton()),
      ],
    ),
  );
}

Widget _summaryItemSkeleton() {
  final bar = Colors.grey[800]!;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // value bar
      Container(
        width: 90,
        height: 14,
        decoration:
            BoxDecoration(color: bar, borderRadius: BorderRadius.circular(6)),
      ),
      const SizedBox(height: 6),
      // label bar
      Container(
        width: 120,
        height: 10,
        decoration:
            BoxDecoration(color: bar, borderRadius: BorderRadius.circular(6)),
      ),
    ],
  );
}

Widget _summaryDividerGhost() {
  // ghost divider to match your asset divider spacing during shimmer
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SizedBox(
      width: 1,
      height: 40,
      child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey[800])),
    ),
  );
}

Widget _summaryDividerAsset() {
  // your existing divider image
  return Image.asset('assets/images/divider_line.png');
}

class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? radius;

  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: radius ?? BorderRadius.circular(6),
        ),
      ),
    );
  }
}
