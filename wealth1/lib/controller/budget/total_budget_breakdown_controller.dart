// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../../../../utils/app_urls.dart'; // Assuming this contains AppEndpoints.baseUrl
// import '../../../../widgets/custom_app_bar.dart';
//
// // Stateless Widget
// class BudgetBreakdownPage extends StatelessWidget {
//   BudgetBreakdownPage({super.key});
//   final controller = Get.put(BudgetBreakdownController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(title: 'Total Spend'), // Changed from 'Total Expense' to 'Total Spend' to match API
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: Color.fromRGBO(78, 78, 78, 0.46).withOpacity(0.46),
//               width: 0.7,
//             ),
//           ),
//           child: Obx(() => _buildBody(controller)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody(BudgetBreakdownController controller) {
//     if (controller.isLoading.value) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.teal),
//             SizedBox(height: 16),
//             Text(
//               'Loading budgets...',
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (controller.errorMessage.value != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Error Loading Data',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               controller.errorMessage.value!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => controller.fetchBudgetData(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 foregroundColor: Colors.white,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (controller.categories.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.inbox,
//               color: Colors.white54,
//               size: 64,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'No Budgets Found',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Start tracking your budgets by adding some transactions.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // Sort categories by spend amount in descending order and take top 5 for legend
//     final topCategories = controller.categories.toList()
//       ..sort((a, b) => b.spend.compareTo(a.spend));
//     final displayCategories = topCategories.take(5).toList();
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 32),
//         // Chart and Legend Section
//         Row(
//           children: [
//             // Pie Chart
//             const SizedBox(width: 20),
//             SizedBox(
//               width: 158,
//               height: 158,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   PieChart(
//                     PieChartData(
//                       sectionsSpace: 4,
//                       centerSpaceRadius: 70,
//                       sections: controller.buildPieChartSections(),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.grey.withOpacity(0.7),
//                         width: 0.5,
//                       ),
//                     ),
//                     padding: EdgeInsets.all(Get.width * 0.07),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Total Spend',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 11,
//                           ),
//                         ),
//                         Obx(() => Text(
//                           '\$${controller.totalSpend.value.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11.11,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         )),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 32),
//             // Legend
//             Expanded(
//               flex: 2,
//               child: Column(
//                 children: List.generate(displayCategories.length, (index) {
//                   final category = displayCategories[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 4,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: controller
//                                 .buildPieChartSections()[index]
//                                 .color, // Use the same color as the pie chart
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             category.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 9,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '\$${category.spend.toStringAsFixed(0)}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 8,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             )
//           ],
//         ),
//         const SizedBox(height: 53),
//         // Transactions List (Budgets)
//         Expanded(
//           child: Obx(() => ListView.builder(
//             itemCount: controller.budgets.length,
//             itemBuilder: (context, index) {
//               final budget = controller.budgets[index];
//               final isLastItem = index == controller.budgets.length - 1;
//
//               return Column(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 12, top: 12),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 35,
//                           height: 35,
//                           decoration: BoxDecoration(
//                             color: budget.color.withOpacity(0.3),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             budget.icon,
//                             color: Colors.white.withOpacity(0.8),
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 budget.description,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 budget.date, // Only date, as API doesn't provide time
//                                 style: const TextStyle(
//                                   color: Colors.white54,
//                                   fontWeight: FontWeight.w300,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '\$${budget.amount.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (!isLastItem)
//                     Divider(
//                       color: Colors.white24,
//                       thickness: 0.5,
//                       height: 0,
//                     ),
//                 ],
//               );
//             },
//           )),
//         )
//       ],
//     );
//   }
// }
//
// // GetX Controller
// class BudgetBreakdownController extends GetxController {
//   // Observable variables
//   var categories = <BudgetCategory>[].obs;
//   var budgets = <BudgetTransaction>[].obs;
//   var isLoading = true.obs;
//   var errorMessage = RxnString();
//   var totalSpend = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchBudgetData();
//   }
//
//   Future<void> fetchBudgetData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString('auth_token') ?? '';
//     final userId = prefs.getString('userId') ?? '';
//
//     try {
//       isLoading.value = true;
//       errorMessage.value = null;
//
//       final headers = {
//         'Authorization': 'Bearer $authToken',
//         'Content-Type': 'application/json',
//       };
//
//       final request = http.Request('GET',
//           Uri.parse('${AppEndpoints.baseUrl}/users/$userId/budgets'));
//       request.headers.addAll(headers);
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(responseBody);
//
//         if (jsonData['status'] == true) {
//           _processApiData(jsonData['body']);
//         } else {
//           errorMessage.value = jsonData['message'] ?? 'Failed to fetch data';
//         }
//       } else {
//         errorMessage.value = 'Server error: ${response.statusCode}';
//       }
//     } catch (e) {
//       errorMessage.value = 'Network error: ${e.toString()}';
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void _processApiData(Map<String, dynamic> body) {
//     try {
//       totalSpend.value = (body['totalSpend'] ?? 0.0).toDouble();
//
//       final List<dynamic> categoryList = body['category'] ?? [];
//       categories.value = categoryList.map((catData) {
//         return BudgetCategory(
//           formatCategoryName(catData['categoryName'] ?? ''),
//           (catData['budgetSpend'] ?? 0.0).toDouble(),
//           getCategoryColor(catData['categoryName'] ?? ''),
//           catData['id'] ?? '',
//           catData['startDate'] ?? '',
//           catData['categoryName'] ?? '',
//         );
//       }).toList();
//
//       final List<dynamic> budgetList = body['budgets'] ?? [];
//       budgets.value = budgetList.map((budgetData) {
//         final dateStr = budgetData['date'] ?? DateTime.now().toIso8601String();
//         final date = DateTime.tryParse(dateStr) ?? DateTime.now();
//         return BudgetTransaction(
//           budgetData['description'] ?? 'Unknown',
//           formatDate(date),
//           (budgetData['amount'] ?? 0.0).toDouble(),
//           getIconForCategory(budgetData['category'] ?? ''),
//           getCategoryColor(budgetData['category'] ?? ''),
//         );
//       }).toList();
//     } catch (e) {
//       errorMessage.value = 'Error processing data: ${e.toString()}';
//     }
//   }
//
//   String formatCategoryName(String category) {
//     return category
//         .toLowerCase()
//         .split('_')
//         .map((word) =>
//     word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
//         .join(' ');
//   }
//
//   Color getCategoryColor(String category) {
//     final colors = [
//       const Color(0xFF4A90E2), // Blue
//       const Color(0xFF50D773), // Green
//       const Color(0xFFFFB84D), // Orange
//       const Color(0xFFE74C3C), // Red
//       const Color(0xFFAA8EC6), // Light Purple
//     ];
//
//     final hash = category.hashCode;
//     return colors[hash.abs() % colors.length];
//   }
//
//   IconData getIconForCategory(String category) {
//     switch (category.toUpperCase()) {
//       case 'TRAVEL':
//         return Icons.flight;
//       case 'TRANSPORTATION':
//         return Icons.directions_car;
//       case 'ENTERTAINMENT':
//         return Icons.movie;
//       case 'GENERAL_MERCHANDISE':
//         return Icons.shopping_cart;
//       case 'FOOD_AND_DRINK':
//         return Icons.restaurant;
//       case 'LOAN_PAYMENTS':
//         return Icons.payment;
//       case 'GENERAL_SERVICES':
//         return Icons.miscellaneous_services;
//       case 'PERSONAL_CARE':
//         return Icons.spa;
//       case 'INVESTMENT':
//         return Icons.trending_up;
//       case 'SALARY':
//       case 'INCOME':
//         return Icons.attach_money;
//       default:
//         return Icons.account_balance_wallet;
//     }
//   }
//
//   String formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${months[date.month - 1]} ${date.day}, ${date.year}';
//   }
//
//   List<PieChartSectionData> buildPieChartSections() {
//     if (totalSpend.value == 0 || categories.isEmpty) {
//       return [];
//     }
//
//     // Fixed 5 colors
//     final List<Color> fixedColors = [
//       Color(0xFF1A93D9),
//       Color(0xFF57ED6D),
//       Color(0xFFEFCA39),
//       Color(0xFFE37F51),
//       Color(0xFFD93977),
//     ];
//
//     // Sort categories by spend and take top 5
//     final topCategories = categories.toList()
//       ..sort((a, b) => b.spend.compareTo(a.spend));
//     final displayCategories = topCategories.take(5).toList();
//
//     return List.generate(displayCategories.length, (index) {
//       final category = displayCategories[index];
//       final percentage = category.spend / totalSpend.value * 100;
//
//       return PieChartSectionData(
//         color: fixedColors[index],
//         showTitle: false,
//         value: category.spend,
//         title: '${percentage.toStringAsFixed(0)}%',
//         radius: 10,
//         titleStyle: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//         ),
//       );
//     });
//   }
// }
//
// // Model Classes
// class BudgetCategory {
//   final String name;
//   final double spend; // Using budgetSpend as 'spend'
//   final Color color;
//   final String id;
//   final String startDate;
//   final String originalName;
//
//   BudgetCategory(
//       this.name,
//       this.spend,
//       this.color,
//       this.id,
//       this.startDate,
//       this.originalName,
//       );
// }
//
// class BudgetTransaction {
//   final String description; // Using description as title
//   final String date; // Formatted date
//   final double amount;
//   final IconData icon;
//   final Color color;
//
//   BudgetTransaction(
//       this.description,
//       this.date,
//       this.amount,
//       this.icon,
//       this.color,
//       );
// }