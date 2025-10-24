import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/view/vitals/budget/add_budget.dart';
import 'package:wealthnx/view/vitals/budget/budget_shimmer_effect.dart';
import 'package:wealthnx/view/vitals/budget/budget_trans_view_all.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/models/budget/budget_model.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/empty.dart';

import '../../../controller/comman_controller.dart';
import '../../../widgets/custom_list_item.dart';
import 'budget_breakdown/budget_breakdown.dart';

class BudgetPage extends StatelessWidget {
  BudgetPage({super.key});

  final CommonController _commonController = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    final BudgetController _controller = Get.find<BudgetController>();

    final connectivityController = Get.find<CheckPlaidConnectionController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Budget', actions: [
        if (connectivityController.isConnected.value == false) ...[
          toggleBtnDemoReal(context)
        ],
      ]),
      body: Obx(() {
        if (_controller.isLoadingBudget.value) {
          //return const Center(child: CircularProgressIndicator());
          return BudgetShimmerEffect();
        } else if (_controller.budgetResponse.value == null) {
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionName(
                  title: 'Total Budget',
                  titleOnTap: '',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                Text(
                  '\$ 0.0',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '0.0%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Empty(
                    title: 'Budget',
                    width: 100,
                  ),
                ),
              ],
            ),
          );
        } else if (_controller.budgetResponse.value?.body?.budgets?.length ==
            null) {
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionName(
                  title: 'Total Budget',
                  titleOnTap: '',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                Text(
                  '\$ 0.0',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '0.0%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Empty(
                    title: 'Budget',
                    width: 100,
                  ),
                ),
              ],
            ),
          );
        } else {
          final budgets = _controller.budgetResponse.value?.body;
          final categoryLength =
              (budgets!.category!.length > 4) ? 5 : budgets.category?.length;
          double spent = _controller.getTotalBudgetAmount() -
              _controller.getTotalRemainingAmount();
          double spentPercent =
              (spent / _controller.getTotalBudgetAmount()) * 100;
          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.to(() => BudgetBreakdownPage(
                        totalBudget:
                            '\$${_controller.getTotalBudgetAmount().toInt().toInt()}',
                      )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Budget',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            // Text(
                            //   (_controller.getTotalBudgetAmount().toInt() == 0)
                            //       ? '\$0.00'
                            //       : '\$${_controller.getTotalBudgetAmount().toInt().toInt()}',
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            textWidget(context, title: () {
                              final budget = _controller
                                          .getTotalBudgetAmount()
                                          .toInt() ==
                                      0
                                  ? 0
                                  : _controller.getTotalBudgetAmount().toInt();

                              if (budget == 0) {
                                return '\$0.00';
                              } else if (budget > 0) {
                                return '\$${numberFormat.format(budget)}';
                              } else {
                                return '-\$${numberFormat.format(budget.abs())}';
                              }
                            }(), fontSize: 18, fontWeight: FontWeight.w500)
                          ],
                        ),
                        Spacer(),
                        // SizedBox(width: 24, height: 24, child: null),
                        SizedBox(
                          width: 100,
                          // flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  fit: StackFit.passthrough,
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.transparent,
                                      // backgroundImage:
                                      //     AssetImage('assets/images/exp_1.png'),
                                    ),
                                    Positioned(
                                      left: -10,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/budget3.png'),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/budget2.png'),
                                      ),
                                    ),
                                    Positioned(
                                      left: 25,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/images/budget1.png'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 24,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        // Icon(Icons.arrow_forward_ios, size: 24),
                      ],
                    ),
                  ),
                ),
                addHeight(21),
                Container(
                  width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 40, 40, 40)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remaining Budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          () {
                            final amount = double.tryParse(
                                  _controller.budgetResponse.value!.body!
                                      .totalRemaining
                                      .toString(),
                                ) ??
                                0;

                            return amount == 0
                                ? '\$0.00'
                                : NumberFormat.currency(
                                        symbol: '\$', decimalDigits: 0)
                                    .format(amount);
                          }(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (spentPercent >= 60)
                          Container(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                '*You Spent More then you budget this month',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                addHeight(21),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // color: const Color(0xFF1C1C1C),
                    // border: Border.all(
                    //   color: const Color.fromARGB(255, 40, 40, 40),
                    // ),
                  ),
                  child: Column(
                    children: [
                      SectionName(
                        title: 'Frequently Spent',
                        titleOnTap: '',
                        onTap: () {},
                      ),
                      // addHeight(16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 1,
                        //budgets.frequencyCategoryModel!.length,
                        itemBuilder: (context, index) {
                          final budget = budgets.frequencyCategoryModel?[index];
                          // if(budget!.budgetSpend*100/budget.budgetAmount)
                          return CustomListItem(
                            title: budget!.categoryName.toString(),
                            subtitle: budget.budgetRemaining.toString(),
                            iconData: getIconForCategory(
                                budget.categoryName.toString()),
                            // image:
                            //     'https://drive.google.com/file/d/1LEOofjO12m1GRr51I3-l6wCckGU0JPH4/view?usp=sharing',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // addHeight(21),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // color: const Color(0xFF1C1C1C),
                    border: Border.all(
                      color: const Color.fromARGB(255, 40, 40, 40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _commonController.textWidget(context,
                              title: 'Budget List',
                              fontSize: responTextWidth(16),
                              // color: Color(0xFFD6D6D6),
                              fontWeight: FontWeight.w600),
                          Spacer(),
                          _commonController.textWidget(context,
                              title: 'Budget',
                              fontSize: responTextWidth(12.7),
                              // color: Color(0xFFD6D6D6),
                              fontWeight: FontWeight.w400),
                          SizedBox(width: Get.width * 0.08),
                          _commonController.textWidget(context,
                              title: 'Remaining',
                              fontSize: responTextWidth(12.7),
                              // color: Color(0xFFD6D6D6),
                              fontWeight: FontWeight.w400),
                        ],
                      ),
                      if (budgets.category!.isEmpty)
                        Center(
                            child: Empty(
                          title: "Recent Budget",
                          height: 50,
                        )),

                      // const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: budgets.category!.length > 4
                            ? 4
                            : budgets.category!.length,
                        itemBuilder: (context, index) {
                          final budget = budgets.category?[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => AddBudget(
                                    title: 'Edit Budget',
                                    amount: budget.budgetAmount.toString(),
                                    id: budget.id.toString(),
                                    category: budget.categoryName.toString(),
                                    iconData: getIconForCategory(
                                        budget.categoryName.toString()),
                                    IconColors: getCategoryColor(
                                        budget.categoryName.toString()),
                                  ));
                            },
                            child: buildBudgetItemCustom(
                              index: index,
                              id: budget!.id.toString(),
                              category: budget.categoryName.toString(),
                              icon: getIconForCategory(
                                  budget.categoryName.toString()),
                              iconColor: getCategoryColor(
                                  budget.categoryName.toString()),
                              title: budget.categoryName.toString(),
                              // remainingColor: Colors.white,
                              budget: budget.budgetAmount!.toInt().toString(),
                              remaining:
                                  budget.budgetRemaining!.toStringAsFixed(0),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                addHeight(21),
                Image.asset(
                  'assets/images/budget_card.png',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // suggestionCard(
                //     text: 'Understand Budget to Manage Finances',
                //     subText:
                //         'Tracking your money with detail visualization from Build Mode Agent specifically work on personalized Finances.',
                //     onTap: () {}),
                addHeight(21),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 40, 40, 40)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SectionName(
                        title: 'Budget Transaction',
                        titleOnTap: 'View All',
                        onTap: () {
                          Get.to(() =>
                              BudgetTransViewAll(title: 'Budget Transaction'));
                        },
                      ),
                      addHeight(13),
                      _buildBudgetList(_controller),
                    ],
                  ),
                ),
                addHeight(40)
              ],
            ),
          );
        }
      }),
      // bottomNavigationBar: buildAddButton(
      //   title: 'Set Budget',
      //   onPressed: () {
      //     Get.to(() => AddBudget(
      //           title: 'Add Budget',
      //         ));
      //   },
      // ),
    );
  }

  Widget _buildBudgetList(BudgetController controller) {
    final groupedBudgets = controller.groupedBudgets;

    final categoryLength =
        (groupedBudgets.length > 2) ? 4 : groupedBudgets.length;

    if (groupedBudgets.isEmpty) {
      return Center(
          child: Empty(
        title: "Budget",
        height: 120,
      ));
    }

    // Sort the grouped budgets by date (same as before, but handle "Today")
    DateTime? parseDate(String dateStr) {
      if (dateStr.trim().toLowerCase() == 'today') {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day);
      }
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        // Try "02 August 2025"
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final parts = dateStr.split(' ');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = months.indexOf(parts[1]) + 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          if (month > 0) return DateTime(year, month, day);
        }
        return null;
      }
    }

    final Map<String, List<Budget>> sortedRecentBudgets =
        Map.fromEntries(controller.groupedBudgets.entries.toList()
          ..sort((a, b) {
            final da = parseDate(a.key);
            final db = parseDate(b.key);
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da); // latest first
          }));

// ✅ NEW: keep groups but cap to 4 total items across them
    const int kMaxItems = 4;
    int remaining = kMaxItems;
    final Map<String, List<Budget>> limitedGroupedBudgets = {};
    for (final entry in sortedRecentBudgets.entries) {
      if (remaining <= 0) break;
      final take =
          entry.value.length > remaining ? remaining : entry.value.length;
      if (take > 0) {
        limitedGroupedBudgets[entry.key] = entry.value.take(take).toList();
        remaining -= take;
      }
    }

// Then build with your existing UI (no spacing changes):
    return ListView.builder(
      itemCount: limitedGroupedBudgets.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, groupIndex) {
        final dateLabel = limitedGroupedBudgets.keys.elementAt(groupIndex);
        final dateBudgets = limitedGroupedBudgets[dateLabel]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...dateBudgets.map((budget) => GestureDetector(
                  onTap: () {
                    Get.to(() => TransationReceipt(
                          id: budget.id,
                          name: budget.description,
                          amount: budget.amount.toString(),
                          date: budget.date.toString(),
                          category: budget.category,
                        ));
                  },
                  child: Column(
                    children: [
                      // 🔻 your unchanged row UI:
                      Container(
                        height: 70,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white, width: 0.25),
                              ),
                              child: (budget.logo == null ||
                                      budget.logo!.isEmpty)
                                  ? Icon(getCategoryIcon(budget.category ?? ''),
                                      size: 16, color: Colors.black)
                                  : ClipOval(
                                      child: Image.network(
                                        budget.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                                'assets/images/defult_logo.png'),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(budget.description ?? 'No description',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${formatDateAndTime(budget.date.toString())}',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                            addWidth(10),
                            Text('\$${budget.amount?.toInt() ?? 0}',
                                style: TextStyle(
                                  color: (budget.amount ?? 0) > 0
                                      ? Colors.white
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                )),
                          ],
                        ),
                      ),

                      // same divider rule, just swap the map name:
                      (groupIndex == limitedGroupedBudgets.length - 1 &&
                              budget == dateBudgets.last)
                          ? const SizedBox.shrink()
                          : const Divider(thickness: 0.5, height: 2),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
//   Widget _buildBudgetList(BudgetController controller) {
//     final groupedBudgets = controller.groupedBudgets;
//
//     final categoryLength =
//         (groupedBudgets.length > 2) ? 4 : groupedBudgets.length;
//
//     if (groupedBudgets.isEmpty) {
//       return Center(
//           child: Empty(
//         title: "Budget",
//         height: 120,
//       ));
//     }
//
//     // Helper function to parse date strings
//     DateTime? parseDate(String dateStr) {
//       try {
//         // Try ISO format first (yyyy-mm-dd)
//         return DateTime.parse(dateStr);
//       } catch (e) {
//         try {
//           // Try parsing format like "02 August 2025"
//           List<String> months = [
//             'January',
//             'February',
//             'March',
//             'April',
//             'May',
//             'June',
//             'July',
//             'August',
//             'September',
//             'October',
//             'November',
//             'December'
//           ];
//
//           List<String> parts = dateStr.split(' ');
//           if (parts.length == 3) {
//             int day = int.parse(parts[0]);
//             int month = months.indexOf(parts[1]) + 1;
//             int year = int.parse(parts[2]);
//
//             if (month > 0) {
//               return DateTime(year, month, day);
//             }
//           }
//         } catch (e2) {
//           print('Failed to parse date: $dateStr');
//         }
//       }
//       return null;
//     }
//
// // Sort the grouped budgets by date and take only top 3 most recent
//     Map<String, List<Budget>> sortedRecentBudgets =
//         Map.fromEntries(groupedBudgets.entries.toList()
//           ..sort((a, b) {
//             // Parse the date strings and compare them
//             DateTime? dateA = parseDate(a.key);
//             DateTime? dateB = parseDate(b.key);
//
//             if (dateA == null && dateB == null) return 0;
//             if (dateA == null) return 1;
//             if (dateB == null) return -1;
//
//             return dateB.compareTo(dateA); // Descending order (latest first)
//           }));
//
// // Take only the first 3 entries (most recent dates)
//     Map<String, List<Budget>> top3RecentBudgets =
//         Map.fromEntries(sortedRecentBudgets.entries.take(3));
//     return ListView.builder(
//       itemCount: top3RecentBudgets.length ,
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       physics: NeverScrollableScrollPhysics(),
//       itemBuilder: (context, groupIndex) {
//         String dateLabel = top3RecentBudgets.keys.elementAt(groupIndex);
//         List<Budget> dateBudgets = top3RecentBudgets[dateLabel]!;
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Budgets under this date
//             ...dateBudgets.map((budget) => GestureDetector(
//                   onTap: () {
//                     Get.to(() => TransationReceipt(
//                           id: budget.id,
//                           name: budget.description,
//                           amount: budget.amount.toString(),
//                           date: budget.date.toString(),
//                           category: budget.category,
//                         ));
//                   },
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 70,
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 32,
//                               height: 32,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(30),
//                                 border: Border.all(
//                                     color: Colors.white, width: 0.25),
//                               ),
//                               child: budget.logo == ""
//                                   ? Icon(
//                                       getCategoryIcon(budget.category ?? ''),
//                                       size: 16,
//                                       color: Colors.black,
//                                     )
//                                   : ClipOval(
//                                       child: Image.network(
//                                         budget.logo.toString(),
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error,
//                                                 stackTrace) =>
//                                             Image.asset(
//                                                 'assets/images/defult_logo.png'),
//                                         loadingBuilder:
//                                             (context, child, loadingProgress) {
//                                           if (loadingProgress == null)
//                                             return child;
//                                           return Center(
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               value: loadingProgress
//                                                           .expectedTotalBytes !=
//                                                       null
//                                                   ? loadingProgress
//                                                           .cumulativeBytesLoaded /
//                                                       loadingProgress
//                                                           .expectedTotalBytes!
//                                                   : null,
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                             ),
//
//                             SizedBox(width: 12),
//
//                             // Description + category
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     budget.description ?? 'No description',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     '${budget.category == 'Uncategorized' ? 'Others' : budget.category} · ${controller.formatTime(budget.date.toString() ?? '')}',
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w300),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             // Amount
//                             Text(
//                               '\$${budget.amount?.toInt() ?? 0}',
//                               style: TextStyle(
//                                 color: (budget.amount ?? 0) > 0
//                                     ? Colors.white
//                                     : Colors.red,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Only show divider if not the last item in the last group
//                       (groupIndex == top3RecentBudgets.length - 1 &&
//                               budget == dateBudgets.last)
//                           ? Container()
//                           : const Divider(thickness: 0.5, height: 2)
//                     ],
//                   ),
//                 )),
//           ],
//         );
//       },
//     );
//   }
}
