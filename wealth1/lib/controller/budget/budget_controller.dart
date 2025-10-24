import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/budget/budget_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

class BudgetController extends GetxController {
  final Rx<BudgetResponse?> budgetResponse = Rx<BudgetResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingBudget = false.obs;
  final RxMap<String, bool> expandedSections = <String, bool>{}.obs;

  var transactions = Rxn<BudgetResponse>();
  var filteredTransactions = <Budget>[].obs;
  var errorMessage = ''.obs;
  var hasFetched = false.obs;
  final TextEditingController searchController = TextEditingController();

  final RxBool hasFetchedBudget = false.obs;
  final RxList<BudgetCategory> categories = <BudgetCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
    _initializeExpandedSections();
  }

  // Future<void> fetchBudgets({bool force = false}) async {
  //   if (hasFetchedBudget.value && !force) return;
  //
  //   try {
  //     isLoadingBudget(true);
  //
  //     final response = await BaseClient().get(
  //       '${AppEndpoints.budgets}',
  //     );
  //
  //     if (response != null) {
  //       budgetResponse.value = BudgetResponse.fromJson(response);
  //       // Initialize expanded sections based on received categories
  //
  //       transactions.value = budgetResponse.value;
  //       filteredTransactions.clear();
  //       filteredTransactions.addAll(budgetResponse.value?.body?.budgets ?? []);
  //       transactions.refresh();
  //       filteredTransactions.refresh();
  //       hasFetched.value = true;
  //       errorMessage.value = '';
  //
  //      // await _initializeExpandedSections();
  //     }
  //   } catch (e) {
  //     print('Failed to load budget data');
  //   } finally {
  //     isLoadingBudget(false);
  //   }
  // }
  Future<void> fetchBudgets({bool force = false}) async {
    if (force) {
      hasFetchedBudget.value = false; // <-- reset your guard
    }
    if (hasFetchedBudget.value && !force) return;

    try {
      isLoadingBudget(true);

      final response = await BaseClient().get(AppEndpoints.budgets);

      if (response != null) {
        budgetResponse.value = BudgetResponse.fromJson(response);

        // Fill filteredTransactions / transactions (you already do this)
        transactions.value = budgetResponse.value;
        filteredTransactions
          ..clear()
          ..addAll(budgetResponse.value?.body?.budgets ?? const []);
        transactions.refresh();
        filteredTransactions.refresh();
        hasFetched.value = true;
        errorMessage.value = '';

        final apiCats =
            budgetResponse.value?.body?.category ?? const <Category>[];
        categories.assignAll(apiCats.map((c) => BudgetCategory(
              // If your API doesn’t return an id, synthesize a stable one
              id: c.id.toString(),
              categoryName: c.categoryName ?? '',
              budgetAmount: (c.budgetAmount ?? 0).toInt(),
              budgetRemaining: (c.budgetRemaining ?? 0).toDouble(),
            )));

        // mark fetched
        hasFetchedBudget.value = true;

        // (optional) initialize expand map
        // await _initializeExpandedSections();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load budget data';
    } finally {
      isLoadingBudget(false);
    }
  }

  void filterTransactions() {
    final searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      filteredTransactions.assignAll(transactions.value?.body?.budgets ?? []);
    } else {
      filteredTransactions.assignAll(
        (transactions.value?.body?.budgets ?? []).where((txn) =>
            txn.description?.toLowerCase().contains(searchTerm) ?? false),
      );
    }
    filteredTransactions.refresh();
  }

// Add to BudgetController
  String formatBudgetDate(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    if (now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day) {
      return 'Today';
    } else {
      return DateFormat('dd MMMM yyyy').format(localDate);
    }
  }

  Map<String, List<Budget>> get groupedBudgets {
    final Map<String, List<Budget>> grouped = {};
    // final budgetsList = budgetResponse.value?.body?.budgets ?? [];

    for (var budget in filteredTransactions) {
      if (budget.date != null) {
        try {
          final dateTime = DateTime.parse(budget.date.toString());
          String label = formatBudgetDate(dateTime);
          grouped.putIfAbsent(label, () => []).add(budget);
        } catch (e) {
          print("Error parsing date: ${budget.date}");
        }
      }
    }

    return grouped;
  }

  String formatTime(String dateStr) {
    final dateTime = DateTime.parse(dateStr).toLocal();
    return DateFormat.jm().format(dateTime);
  }

  Future<void> _initializeExpandedSections() async {
    final categories = budgetResponse.value?.body?.category;
    if (categories != null) {
      for (var cat in categories) {
        if (cat.categoryName != null) {
          expandedSections[cat.categoryName!] = false;
        }
      }
    }
  }

  double getTotalBudgetAmount() {
    if (budgetResponse.value?.body?.totalBudget == null) return 0;
    return budgetResponse.value!.body!.totalBudget!.toDouble();
  }

  double getTotalRemainingAmount() {
    if (budgetResponse.value?.body?.totalRemaining == null) return 0;
    return budgetResponse.value!.body!.totalRemaining!.toDouble();
  }

  double getPercentageUsed() {
    if (budgetResponse.value?.body?.percentageRemaining == null) return 0;
    try {
      // Remove any percentage sign if present and parse
      final percentageString = budgetResponse.value!.body!.percentageRemaining!
          .replaceAll('%', '')
          .trim();
      final percentage = double.parse(percentageString);
      return (100 - percentage) / 100;
    } catch (e) {
      return 0;
    }
  }

  List<Budget>? getBudgetsByCategory(String category) {
    if (budgetResponse.value?.body?.budgets == null) return null;
    return budgetResponse.value!.body!.budgets!
        .where((budget) => budget.category == category)
        .toList();
  }

  List<Category>? getCategories() {
    return budgetResponse.value?.body?.category;
  }

  void toggleSection(String section) {
    expandedSections[section] = !(expandedSections[section] ?? false);
    expandedSections.refresh();
  }

  // int getCategoryRemainingAmount(String categoryName) {
  //   final category = budgetResponse.value?.body?.category?.firstWhere(
  //     (cat) => cat.categoryName == categoryName,
  //     orElse: () => Category(
  //       categoryName: categoryName,
  //       budgetAmount: 0,
  //       budgetSpend: 0,
  //       budgetRemaining: 0,
  //     ),
  //   );
  //   return category?.budgetRemaining?.toInt() ?? 0;
  // }
  int getCategoryRemainingAmount(String categoryName) {
    final cat = categories.firstWhereOrNull(
      (c) => c.categoryName == categoryName,
    );
    return (cat?.budgetRemaining ?? 0).toInt();
  }

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Column(
        children: List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Safe parse to local DateTime (fallback = epoch)
  DateTime _safeDate(dynamic raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// 1) Flat, date-sorted list of transactions for a category
  List<Budget> getCategoryTransactions(String categoryName,
      {bool ignoreSearch = true}) {
    final source = ignoreSearch
        ? (budgetResponse.value?.body?.budgets ?? const <Budget>[])
        : filteredTransactions;

    final lower = categoryName.toLowerCase();
    final list =
        source.where((b) => (b.category ?? '').toLowerCase() == lower).toList();
    list.sort((a, b) => _safeDate(b.date).compareTo(_safeDate(a.date)));
    return list;
  }

  /// 2) Grouped-by-date map for a category (e.g., {"Today": [...], "14 September 2025": [...]})
  Map<String, List<Budget>> getCategoryTransactionsGrouped(String categoryName,
      {bool ignoreSearch = true}) {
    final Map<String, List<Budget>> grouped = {};
    for (final b
        in getCategoryTransactions(categoryName, ignoreSearch: ignoreSearch)) {
      final dt = _safeDate(b.date);
      final label = formatBudgetDate(dt);
      (grouped[label] ??= <Budget>[]).add(b);
    }
    return grouped;
  }

  String formatDateMdY(dynamic date) {
    final s = date?.toString() ?? '';
    final dt = DateTime.tryParse(s)?.toLocal();
    if (dt == null) return s;
    return DateFormat('MMM d, yyyy').format(dt);
  }

// UI helpers moved here so the page can call controller.* without UI changes
  String formatCategoryName(String category) {
    return category
        .toLowerCase()
        .split('_')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }

  Color getCategoryColor(String category) {
    final colors = <Color>[
      const Color(0xFFD4C595),
      const Color(0xFFCBA187),
      const Color(0xFFD3A0A0),
      const Color(0xFFBAD3A0),
      const Color(0xFF8B9CCF),
      const Color(0xFFD3A0A0),
    ];
    final hash = category.hashCode;
    return colors[hash.abs() % colors.length];
  }

  IconData getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TRAVEL':
        return Icons.flight;
      case 'TRANSPORTATION':
      case 'TRANSPORT':
        return Icons.directions_car;
      case 'ENTERTAINMENT':
        return Icons.movie;
      case 'GENERAL_MERCHANDISE':
        return Icons.shopping_cart;
      case 'FOOD_AND_DRINK':
      case 'FOOD':
        return Icons.restaurant;
      case 'HOUSING':
        return Icons.house;
      case 'LOAN_PAYMENTS':
        return Icons.payment;
      case 'GENERAL_SERVICES':
        return Icons.miscellaneous_services;
      case 'PERSONAL_CARE':
        return Icons.spa;
      case 'INVESTMENT':
      case 'INVESTMENT ':
        return Icons.trending_up;
      case 'SALARY':
      case 'INCOME':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color getPieCategoryColor(amount, RxList<BudgetCategory> allAmounts) {
    final colors = <Color>[
      const Color(0xFF1A93D9),
      const Color(0xFF57ED6D),
      const Color(0xFFEFCA39),
      const Color(0xFFE37F51),
      const Color(0xFFD93977),
    ];

    // Convert all amounts to numbers
    final values = allAmounts
        .map((e) => double.tryParse(e.budgetAmount.toString()) ?? 0)
        .toList();

    // Sort descending (largest first)
    final sorted = [...values]..sort((a, b) => b.compareTo(a));

    // Find the rank of the current amount
    final currentValue = double.tryParse(amount.toString()) ?? 0;
    final rank = sorted.indexOf(currentValue);

    // Pick color by rank
    if (rank >= 0 && rank < colors.length) {
      return colors[rank];
    }

    // Default if out of range
    return Colors.grey;
  }

//Pie sections computed from BudgetController data
  List<PieChartSectionData> buildPieChartSections() {
    final cats = budgetResponse.value?.body?.category ?? const [];
    if (cats.isEmpty) return [];

    // Fixed 5 colors (to match your current UI)
    final fixedColors = <Color>[
      const Color(0xFF1A93D9),
      const Color(0xFF57ED6D),
      const Color(0xFFEFCA39),
      const Color(0xFFE37F51),
      const Color(0xFFD93977),
    ];

    // Sort by budgetAmount desc and take top 5
    final sorted = [...cats]..sort((a, b) {
        final aa = (a.budgetAmount ?? 0).toDouble();
        final bb = (b.budgetAmount ?? 0).toDouble();
        return bb.compareTo(aa);
      });
    final display = sorted.take(5).toList();

    return List.generate(display.length, (i) {
      final c = display[i];
      final amount = (c.budgetAmount ?? 0).toDouble();
      return PieChartSectionData(
        color: fixedColors[i],
        showTitle: false,
        value: amount == 0 ? 1 : amount,
        title: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
            .format(amount),
        radius: 10,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      );
    });
  }

  void updateBudgetLocally({
    required String id,
    String? newCategoryName,
    int? newBudgetAmount,
    double? newBudgetRemaining, // pass if you recalc remaining
  }) {
    final i = categories.indexWhere((e) => e.id == id);
    if (i == -1) return;
    categories[i] = categories[i].copyWith(
      categoryName: newCategoryName,
      budgetAmount: newBudgetAmount,
      budgetRemaining: newBudgetRemaining,
    );
    categories.refresh();
  }
}

class BudgetCategory {
  final String id;
  final String categoryName; // original name from API (key)
  final int budgetAmount; // whole number for charting/legend
  final double budgetRemaining;

  BudgetCategory({
    required this.id,
    required this.categoryName,
    required this.budgetAmount,
    required this.budgetRemaining,
  });

  BudgetCategory copyWith({
    String? id,
    String? categoryName,
    int? budgetAmount,
    double? budgetRemaining,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetRemaining: budgetRemaining ?? this.budgetRemaining,
    );
  }
}
