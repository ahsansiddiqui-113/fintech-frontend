import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/controller/transations/transations_controller.dart';
import 'package:wealthnx/controller/vitals/vitals_controller.dart';
import 'package:wealthnx/utils/app_urls.dart';

import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/budget/add_budget.dart';
import 'package:wealthnx/view/vitals/budget/budget_breakdown/budget_breakdown.dart';
import 'package:wealthnx/view/vitals/budget/budget_page.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/chats/expence_chart.dart';
import 'package:wealthnx/view/vitals/transations/transactions.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';
import 'package:wealthnx/widgets/custom_list_item.dart';
import 'package:wealthnx/widgets/empty.dart';

class VitalsScreen extends StatefulWidget {
  VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final CheckPlaidConnectionController _checkPlaidConnectionController =
      Get.find<CheckPlaidConnectionController>();
  final VitalsController _vitalscontroller = Get.find<VitalsController>();
  final NetWorthController networthcontroller = Get.find<NetWorthController>();
  final BudgetController _controllerBudget = Get.find<BudgetController>();
  final IncomeController _controllerIncome = Get.put(IncomeController());
  final ExpensesController _controllerExpence = Get.find<ExpensesController>();
  final CashFlowController _controllerCashflow = Get.find<CashFlowController>();
  final TransactionsController _tarnsController =
      Get.find<TransactionsController>();
  final List<String> tabTitles = ['1 M', '3 M', '6 M', '1 Y', 'YTD'];
  final RxInt selectedTab = 0.obs;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Run once after the widget mounts
    Future.microtask(() {
      Get.find<CheckPlaidConnectionController>().checkConnection();
      _controllerIncome.fetchExpenseCategories(); // once
      if (!_controllerBudget.hasFetchedBudget.value) {
        _controllerBudget.fetchBudgets();
      }
      if (!_controllerIncome.hasFetchedIncome.value) {
        _controllerIncome.fetchIncome();
      }
      if (!_controllerExpence.hasFetchedExpence.value) {
        _controllerExpence.fetchExpense();
      }
      if (!_tarnsController.hasFetchedTrans.value) {
        _tarnsController.fetchTransations();
      }
      _vitalscontroller.fetchBankTotals();
    });
  }

  double _carouselHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w <= 360) return 0.9;
    if (w <= 380) return 0.93;
    if (w <= 400) return 0.98;
    if (w <= 420) return 1.06;
    if (w <= 450) return 1.1;
    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    _controllerIncome.fetchExpenseCategories();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
        title: 'Stats',
        automaticallyImplyLeading: true,
        actions: [
          if (_checkPlaidConnectionController.isConnected.value == false) ...[
            toggleBtnDemoReal(context)
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
        child: Column(
          children: [
            addHeight(16),
            buildCategoriesRow(),
            addHeight(21),
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: _carouselHeight(context),
                enlargeCenterPage: true,
                enlargeFactor: 0.29,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                    selectedTab.value = 0;
                    if (index == 0) {
                      networthcontroller.totalSpend.value = networthcontroller
                              .networth.value?.body?.totalNetWorth ??
                          0.00;
                    }
                    if (index == 1) {
                      _controllerIncome.totalIncomeAmount.value =
                          _controllerIncome
                                  .income.value?.body?.totalIncomeAmount ??
                              0.00;
                    }
                    if (index == 2) {
                      _controllerExpence.totalExpenceAmount.value =
                          _controllerExpence
                                  .expense.value?.body?.totalExpense ??
                              0.00;
                    }
                    if (index == 3) {
                      _controllerCashflow.totalCashFlowAmount.value =
                          _controllerCashflow.cashflow.value?.body?.cashflow ??
                              0.00;
                    }
                  });
                },
                viewportFraction: 1,
              ),
              items: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: index == 0
                      ? buildNetWorthSection()
                      : index == 1
                          ? buildIcomeSection()
                          : index == 2
                              ? buildExpenceSection()
                              : buildCashflowSection(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    borderRadius: BorderRadius.circular(15),

                    color: _currentIndex == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
            addHeight(21),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionName(
                    title: 'Account Summary',
                    titleOnTap: '',
                    onTap: () {},
                  ),
                  addHeight(12),
                  Obx(() {
                    return _controllerIncome.isLoadingIncome.value ||
                            _controllerIncome
                                    .income.value?.body?.totalIncomeAmount
                                    ?.toInt() ==
                                null
                        ? _buildNetWorthItemShimmer(
                            'Cash',
                            '${0.0}%',
                            ' Increased',
                            '',
                            Icons.account_balance_wallet,
                            Icons.arrow_right_alt)
                        : _buildNetWorthItem(
                            title: 'Cash',
                            perbelowtext:
                                '${_controllerCashflow.cashflow.value?.body?.incomeChangePercent?.toInt() ?? 0}%',
                            belowtext: ' Increase',
                            value:
                                '\$${_controllerIncome.income.value?.body?.totalIncomeAmount?.toInt() == null ? 0.0 : _controllerIncome.income.value?.body?.totalIncomeAmount?.toInt()}',
                            image: 'assets/icons/increesed_icon.svg',
                          );
                  }),
                  Divider(),
                  Obx(() {
                    return _controllerExpence.isLoadingExpence.value ||
                            _controllerExpence.expense.value?.body?.totalExpense
                                    ?.toInt() ==
                                null
                        ? _buildNetWorthItemShimmer(
                            'Credit Cards',
                            '${0.0}%',
                            ' Decrease',
                            '',
                            Icons.credit_card,
                            Icons.arrow_right_alt)
                        : _buildNetWorthItem(
                            title: 'Credit Cards',
                            perbelowtext:
                                '${_controllerCashflow.cashflow.value?.body?.expenseChangePercent?.toInt()?? 0}%',
                            belowtext: ' Decrease',
                            value:
                                '\$${_controllerExpence.expense.value?.body?.totalExpense?.toInt() == null ? 0.0 : _controllerExpence.expense.value?.body?.totalExpense?.toInt()}',
                            image: 'assets/icons/decreesed_icon.svg');
                  }),
                ],
              ),
            ),
            addHeight(21),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // color: const Color(0xFF1C1C1C),
                border: Border.all(
                  color: const Color.fromARGB(255, 40, 40, 40),
                ),
              ),
              child: Obx(() {
                final categories =
                    _controllerBudget.budgetResponse.value?.body?.category;
                if (categories == null) {
                  return Shimmer.fromColors(
                    baseColor: Colors.black,
                    highlightColor: Colors.grey[700]!,
                    child: Container(
                      height: marginVertical(235),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        children: [
                          /// Top row with 3 shimmer lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 80),
                              Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 50,
                                height: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// List of 4 items
                          Expanded(
                            child: Column(
                              children: List.generate(4, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      /// Left: circle
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      /// Center: text line
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: 10,
                                          color: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      /// Right: value text
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: 40,
                                          height: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      /// Right: value text
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: 40,
                                          height: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (categories.isEmpty) {
                  return Center(
                      child: Empty(title: "Recent Budget", height: 50));
                }

                final visibleCount =
                    categories.length > 4 ? 4 : categories.length;

                return Column(
                  children: [
                    SectionName(
                      title: 'Budget List',
                      titleOnTap: 'View All',
                      onTap: () {
                        Get.to(() => BudgetBreakdownPage(
                              totalBudget: _controllerBudget
                                  .budgetResponse.value?.body?.totalBudget
                                  .toString(),
                            ));
                      },
                    ),
                    addHeight(20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textWidget(context,
                            title: '',
                            fontSize: responTextWidth(16),
                            // color: Color(0xFFD6D6D6),
                            fontWeight: FontWeight.w600),
                        Spacer(),
                        textWidget(context,
                            title: 'Budget',
                            fontSize: responTextWidth(12.7),
                            // color: Color(0xFFD6D6D6),
                            fontWeight: FontWeight.w400),
                        SizedBox(width: Get.width * 0.08),
                        textWidget(context,
                            title: 'Remaining',
                            fontSize: responTextWidth(12.7),
                            // color: Color(0xFFD6D6D6),
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: visibleCount,
                      itemBuilder: (context, index) {
                        final budget = categories[index];
                        if (budget == null)
                          return const SizedBox.shrink(); // guard

                        final String categoryName = budget.categoryName ?? '';
                        final num amount = budget.budgetAmount ?? 0;
                        final num remaining = budget.budgetRemaining ?? 0;

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => AddBudget(
                                  title: 'Edit Budget',
                                  amount: amount.toStringAsFixed(0),
                                  id: (budget.id ?? '').toString(),
                                  category: categoryName,
                                  iconData: getIconForCategory(categoryName),
                                  IconColors: getCategoryColor(categoryName),
                                ));
                          },
                          child: buildBudgetItemCustom(
                            index: index,
                            id: (budget.id ?? '').toString(),
                            category: categoryName,
                            icon: getIconForCategory(categoryName),
                            iconColor: getCategoryColor(categoryName),
                            title: categoryName,
                            budget: amount.toStringAsFixed(0),
                            remaining: remaining.toStringAsFixed(0),
                          ),
                        );
                      },
                    )
                  ],
                );
              }),
            ),
            addHeight(21),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 40, 40, 40),
                ),
              ),
              child: Column(
                children: [
                  SectionName(
                    title: 'Bank Accounts',
                    titleOnTap: '+ Connect Account',
                    onTapColor: context.gc(AppColor.primary),
                    onTap: () {
                      Get.to(() => ConnectAccounts());
                    },
                  ),
                  addHeight(3),
                  Obx(() {
                    if (_vitalscontroller.isLoading.value) {
                      return Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.grey[700]!,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Circle Avatar shimmer
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Middle long text shimmer (expands to fill space)
                              Expanded(
                                child: Container(
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Right small text shimmer (for amount)
                              Container(
                                width: 40,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ((_vitalscontroller.bankTotals.length) > 3)
                          ? 3
                          : _vitalscontroller.bankTotals.length,
                      itemBuilder: (context, index) {
                        final bankList = _vitalscontroller.bankTotals[index];

                        print('Bank Name: ${bankList.name}');
                        return buildIncomeDetailItem(context,
                            index: index,
                            title: bankList.name,
                            amount: (bankList.total == null)
                                ? '\$0.00'
                                : (bankList.total < 0
                                    ? '-\$${numberFormat.format(bankList.total.abs())}'
                                    : '\$${numberFormat.format(bankList.total)}'),
                            length: _vitalscontroller.bankTotals.length,
                            subtitle:
                                '...${bankList.accountNumber.substring(0, 4)}',
                            persentage: '',
                            logo: bankList.logo,
                            icon: (bankList.logo?.toString() == 'null' ||
                                    bankList.logo.toString().isEmpty)
                                ? ImagePaths.expensewallet
                                : AppEndpoints.profileBaseUrl +
                                    bankList.logo.toString());
                      },
                    );
                  }),
                ],
              ),
            ),
            addHeight(21),
            Image.asset(
              'assets/images/Vitals.png',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            addHeight(21),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // color: const Color(0xFF1C1C1C),
                border: Border.all(
                  color: const Color.fromARGB(255, 40, 40, 40),
                ),
              ),
              child: Obx(
                () => Column(
                  children: [
                    SectionName(
                      title: 'Transactions',
                      titleOnTap:
                          (_tarnsController.filteredTransactions.length) == 0
                              ? ''
                              : 'View All',
                      onTap: () {
                        Get.to(() => TransactionsPage());
                      },
                    ),
                    addHeight(16),
                    Obx(() {
                      if (_tarnsController.isLoadingTran.value) {
                        return _tarnsController.buildShimmerEffect();
                      }
                      if (_tarnsController.filteredTransactions.isEmpty) {
                        return Center(
                            child:
                                Empty(title: "Transactions List", height: 50));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            ((_tarnsController.filteredTransactions.length ??
                                        0) >
                                    4)
                                ? 4
                                : _tarnsController.filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transasset =
                              _tarnsController.filteredTransactions[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => TransationReceipt(
                                    id: transasset.id,
                                    name: transasset.title,
                                    amount: transasset.amount.toString(),
                                    date: transasset.date.toString(),
                                    category: transasset.category,
                                  ));
                            },
                            child: buildIncomeDetailItem(
                              context,
                              index: index,
                              title: '${transasset.title}',
                              amount: (transasset.amount == null)
                                  ? '\$0.00'
                                  : (transasset.amount!.toInt() < 0
                                      ? '-\$${numberFormat.format(transasset.amount!.toInt().abs())}'
                                      : '\$${numberFormat.format(transasset.amount!.toInt())}'),
                              length: ((_tarnsController
                                          .filteredTransactions.length) >
                                      4)
                                  ? 4
                                  : _tarnsController
                                      .filteredTransactions.length,
                              subtitle:
                                  formatDateAndTime(transasset.date.toString()),
                              persentage: '',
                              icon: transasset.logoUrl ??
                                  ImagePaths.expensewallet,
                              logo: transasset.logoUrl,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            addHeight(21)
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 24,
        children: _vitalscontroller.categories
            .map((category) => GestureDetector(
                  onTap: () =>
                      _vitalscontroller.handleCategoryTap(category['title']),
                  child: buildCategoryItem(category),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCategoryItem(Map<String, dynamic> category) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: responTextWidth(50),
          height: responTextHeight(50),
          padding: EdgeInsets.all(responTextHeight(9)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: context.gc(AppColor.greyDialog),
              )),
          child: Center(
            child: Image.asset(
              category['icon'],
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category['title'],
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildNetWorthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget(context,
                title: "Net Worth".tr,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            addWidth(10),
            SizedBox(
                height: 14,
                width: 14,
                child: Tooltip(
                  message:
                      "Net worth is a measure of financial health, calculated by subtracting total liabilities from total assets.",
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Color(0xFF252525), // background color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                      color: context.gc(AppColor.white),
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 14,
                  ),
                )),
          ],
        ),
        Obx(() {
          return networthcontroller.isLoading.value
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: responTextWidth(120),
                    height: responTextHeight(25),
                    color: context.gc(AppColor.white),
                  ),
                )
              : Row(
                  children: [
                    Obx(() {
                      final networth = networthcontroller.totalSpend.value;

                      // String text;
                      // if (!networthcontroller.isVisible.value) {
                      //   String formatted = networth == 0
                      //       ? '0.00'
                      //       : networth > 0
                      //       ? numberFormat.format(networth)
                      //       : numberFormat.format(networth.abs());
                      //
                      //   text = formatted.replaceAll(RegExp(r'[0-9]'), '* ');
                      //   text = text.replaceAll(RegExp(r'[,]'), '');
                      // } else if (networth == 0) {
                      //   text = '\$0.00';
                      // } else if (networth > 0) {
                      //   text = '\$${numberFormat.format(networth)}';
                      // } else {
                      //   text = '-\$${numberFormat.format(networth.abs())}';
                      // }
                      String text;
                      if (!networthcontroller.isVisible.value) {
                        text = "* * * * *";
                      } else if (networth == 0) {
                        text = '\$0.00';
                      } else if (networth > 0) {
                        text = '\$${numberFormat.format(networth)}';
                      } else {
                        text = '-\$${numberFormat.format(networth.abs())}';
                      }

                      return textWidget(
                        context,
                        title: text,
                        fontSize: 22.75,
                        fontWeight: FontWeight.w500,
                      );
                    }),
                    addWidth(10),
                    GestureDetector(
                      onTap: () {
                        networthcontroller.setVisibility();
                      },
                      child: Obx(() => Image.asset(
                            networthcontroller.isVisible.value
                                ? "assets/images/visible.png"
                                : "assets/images/invisible.png", // toggle if needed
                            width: 20,
                            height: 20,
                          )),
                    ),
                  ],
                );
        }),
        addHeight(21),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSpendGraph(
                    futureController:
                        networthcontroller.fetchNetworthChartSummary(),
                    tags: 'networth'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabTitles.length, (index) {
                      final isSelected = selectedTab.value == index;

                      return GestureDetector(
                        onTap: () {
                          selectedTab.value = index;
                          networthcontroller.dwmyDropdown.value =
                              tabTitles[index];
                          // networthcontroller.updateDropdown(tabTitles[index]);
                          networthcontroller.totalSpend.value =
                              networthcontroller
                                      .networth.value?.body?.totalNetWorth ??
                                  0;
                          networthcontroller.fetchNetworthChartSummary();
                          setState(() {});
                        },
                        child: Container(
                          // margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF313131)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF313131)
                                  : Colors.transparent,
                              width: 0.25,
                            ),
                          ),
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w400
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget buildIcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget(context,
                title: "Income".tr, fontSize: 14, fontWeight: FontWeight.w500),
            addWidth(10),
            SizedBox(
                height: 14,
                width: 14,
                child: Tooltip(
                  message:
                      "Income is any compensation, typically money, received by an individual in exchange for goods, services, or investments.",
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Color(0xFF252525), // background color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                      color: context.gc(AppColor.white),
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 14,
                  ),
                )),
          ],
        ),
        Obx(() {
          return _controllerIncome.isLoadingIncome.value
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: responTextWidth(120),
                    height: responTextHeight(25),
                    color: context.gc(AppColor.white),
                  ),
                )
              : Row(
                  children: [
                    Obx(() {
                      final income =
                          _controllerIncome.totalIncomeAmount.value ?? 0;

                      // String text;
                      // if (!_controllerIncome.isVisible.value) {
                      //   // format for consistency
                      //   String formatted = income == 0
                      //       ? '0.00'
                      //       : income > 0
                      //       ? numberFormat.format(income)
                      //       : numberFormat.format(income.abs());
                      //
                      //   // replace digits with * (with space after each *)
                      //   text = formatted.replaceAll(RegExp(r'[0-9]'), '* ');
                      //
                      //   // remove commas
                      //   text = text.replaceAll(RegExp(r'[,]'), '');
                      // } else if (income == 0) {
                      //   text = '\$0.00';
                      // } else if (income > 0) {
                      //   text = '\$${numberFormat.format(income)}';
                      // } else {
                      //   text = '-\$${numberFormat.format(income.abs())}';
                      // }
                      String text;
                      if (!_controllerIncome.isVisible.value) {
                        text = "* * * * *";
                      } else if (income == 0) {
                        text = '\$0.00';
                      } else if (income > 0) {
                        text = '\$${numberFormat.format(income)}';
                      } else {
                        text = '-\$${numberFormat.format(income.abs())}';
                      }

                      return textWidget(
                        context,
                        title: text,
                        fontSize: 22.75,
                        fontWeight: FontWeight.w500,
                      );
                    }),
                    addWidth(10),
                    GestureDetector(
                      onTap: () {
                        _controllerIncome.setVisibility();
                      },
                      child: Obx(() => Image.asset(
                            _controllerIncome.isVisible.value
                                ? "assets/images/visible.png"
                                : "assets/images/invisible.png", // toggle if needed
                            width: 20,
                            height: 20,
                          )),
                    ),
                  ],
                );
        }),
        addHeight(21),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSpendGraph(
                    futureController: _controllerIncome.fetchIncomeSummary(),
                    tags: 'income'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabTitles.length, (index) {
                      final isSelected = selectedTab.value == index;

                      return GestureDetector(
                        onTap: () {
                          selectedTab.value = index;
                          _controllerIncome.dwmyDropdown.value =
                              tabTitles[index];
                          _controllerIncome.totalIncomeAmount.value =
                              _controllerIncome
                                      .income.value?.body?.totalIncomeAmount ??
                                  0;
                          _controllerIncome.fetchIncomeSummary();
                          setState(() {});
                        },
                        child: Container(
                          // margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF313131)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF313131)
                                  : Colors.transparent,
                              width: 0.25,
                            ),
                          ),
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w400
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget buildExpenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget(context,
                title: "Expense".tr, fontSize: 14, fontWeight: FontWeight.w500),
            addWidth(10),
            SizedBox(
                height: 14,
                width: 14,
                child: Tooltip(
                  message:
                      "An expense is the money an individual or business spends on goods or services",
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Color(0xFF252525), // background color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                      color: context.gc(AppColor.white),
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 14,
                  ),
                )),
          ],
        ),
        Obx(() {
          return _controllerExpence.isLoadingExpence.value
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: responTextWidth(120),
                    height: responTextHeight(25),
                    color: context.gc(AppColor.white),
                  ),
                )
              : Row(
                  children: [
                    Obx(() {
                      final expence =
                          _controllerExpence.totalExpenceAmount.value ?? 0;

                      // String text;
                      // if (!_controllerExpence.isVisible.value) {
                      //   // format consistently
                      //   String formatted = expence == 0
                      //       ? '0.00'
                      //       : expence > 0
                      //       ? numberFormat.format(expence)
                      //       : numberFormat.format(expence.abs());
                      //
                      //   // replace digits with stars
                      //   text = formatted.replaceAll(RegExp(r'[0-9]'), '* ');
                      //
                      //   // remove commas
                      //   text = text.replaceAll(RegExp(r'[,]'), '');
                      // } else if (expence == 0) {
                      //   text = '\$0.00';
                      // } else if (expence > 0) {
                      //   text = '\$${numberFormat.format(expence)}';
                      // } else {
                      //   text = '-\$${numberFormat.format(expence.abs())}';
                      // }
                      String text;
                      if (!_controllerExpence.isVisible.value) {
                        text = "* * * * *";
                      } else if (expence == 0) {
                        text = '\$0.00';
                      } else if (expence > 0) {
                        text = '\$${numberFormat.format(expence)}';
                      } else {
                        text = '-\$${numberFormat.format(expence.abs())}';
                      }

                      return textWidget(
                        context,
                        title: text,
                        fontSize: 22.75,
                        fontWeight: FontWeight.w500,
                      );
                    }),
                    addWidth(10),
                    GestureDetector(
                      onTap: () {
                        _controllerExpence.setVisibility();
                      },
                      child: Obx(() => Image.asset(
                            _controllerExpence.isVisible.value
                                ? "assets/images/visible.png"
                                : "assets/images/invisible.png", // toggle if needed
                            width: 20,
                            height: 20,
                          )),
                    ),
                  ],
                );
        }),
        addHeight(21),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSpendGraph(
                    futureController: _controllerExpence.fetchExpenceSummary(),
                    tags: 'expence'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabTitles.length, (index) {
                      final isSelected = selectedTab.value == index;

                      return GestureDetector(
                        onTap: () {
                          selectedTab.value = index;
                          _controllerExpence.dwmyDropdown.value =
                              tabTitles[index];
                          // _controllerExpence.updateDropdown(tabTitles[index]);
                          _controllerExpence.totalExpenceAmount.value =
                              _controllerExpence
                                      .expense.value?.body?.totalExpense ??
                                  0;
                          _controllerExpence.fetchExpenceSummary();
                          setState(() {});
                        },
                        child: Container(
                          // margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF313131)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF313131)
                                  : Colors.transparent,
                              width: 0.25,
                            ),
                          ),
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w400
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget buildCashflowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget(context,
                title: "Cash Flow".tr,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            addWidth(10),
            SizedBox(
                height: 14,
                width: 14,
                child: Tooltip(
                  message:
                      "Amount of money moving into and out of their personal accounts typically a month.",
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Color(0xFF252525), // background color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                      color: context.gc(AppColor.white),
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 14,
                  ),
                )),
          ],
        ),
        Obx(() {
          return _controllerCashflow.isLoading.value
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: responTextWidth(120),
                    height: responTextHeight(25),
                    color: context.gc(AppColor.white),
                  ),
                )
              : Row(
                  children: [
                    Obx(() {
                      final cashflow =
                          _controllerCashflow.totalCashFlowAmount.value ?? 0;

                      // String text;
                      // if (!_controllerCashflow.isVisible.value) {
                      //   // Format consistently
                      //   String formatted = cashflow == 0
                      //       ? '0.00'
                      //       : cashflow > 0
                      //       ? numberFormat.format(cashflow)
                      //       : numberFormat.format(cashflow.abs());
                      //
                      //   // Replace digits with stars
                      //   text = formatted.replaceAll(RegExp(r'[0-9]'), '* ');
                      //
                      //   // Remove commas
                      //   text = text.replaceAll(RegExp(r'[,]'), '');
                      // } else if (cashflow == 0) {
                      //   text = '\$0.00';
                      // } else if (cashflow > 0) {
                      //   text = '\$${numberFormat.format(cashflow)}';
                      // } else {
                      //   text = '-\$${numberFormat.format(cashflow.abs())}';
                      // }
                      String text;
                      if (!_controllerCashflow.isVisible.value) {
                        text = "* * * * *";
                      } else if (cashflow == 0) {
                        text = '\$0.00';
                      } else if (cashflow > 0) {
                        text = '\$${numberFormat.format(cashflow)}';
                      } else {
                        text = '-\$${numberFormat.format(cashflow.abs())}';
                      }

                      return textWidget(
                        context,
                        title: text,
                        fontSize: 22.75,
                        fontWeight: FontWeight.w500,
                      );
                    }),
                    addWidth(10),
                    GestureDetector(
                      onTap: () {
                        _controllerCashflow.setVisibility();
                      },
                      child: Obx(() => Image.asset(
                            _controllerCashflow.isVisible.value
                                ? "assets/images/visible.png"
                                : "assets/images/invisible.png", // toggle icon
                            width: 20,
                            height: 20,
                          )),
                    ),
                  ],
                );
        }),
        addHeight(21),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 40, 40, 40)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSpendGraph(
                    futureController:
                        _controllerCashflow.fetchCashflowSummary(),
                    tags: 'cashflow'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabTitles.length, (index) {
                      final isSelected = selectedTab.value == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab.value = index;
                            _controllerIncome.updateDropdown(tabTitles[index]);
                            _controllerIncome.totalIncomeAmount.value =
                                _controllerIncome.income.value?.body
                                        ?.totalIncomeAmount ??
                                    0;
                            _controllerIncome.fetchIncomeSummary();
                          });
                          // selectedTab.value = index;
                          // _controllerCashflow.dwmyDropdown.value =
                          //     tabTitles[index];
                          // // _controllerExpence.updateDropdown(tabTitles[index]);
                          // _controllerCashflow.fetchCashflowSummary();
                          // setState(() {});
                        },
                        child: Container(
                          // margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF313131)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF313131)
                                  : Colors.transparent,
                              width: 0.25,
                            ),
                          ),
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w400
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget _buildNetWorthItem(
      {required String title,
      required String perbelowtext,
      required String belowtext,
      required String value,
      String? image}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      perbelowtext,
                      style: TextStyle(
                          color: Color(0xFF979C9E),
                          // color: title == 'Cash'
                          //     ? context.gc(AppColor.greenColor)
                          //     : context.gc(AppColor.redColor),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      belowtext,
                      style: const TextStyle(
                          color: Color(0xFF979C9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                spacing: 8,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                  SvgPicture.asset(
                    image.toString(),
                    height: 12,
                    width: 12,
                    // color: Colors.white,
                    // size: 16,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildNetWorthItemShimmer(String title, String perbelowtext,
      String belowtext, String value, IconData icon, IconData image) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$perbelowtext',
                      style: TextStyle(
                          color: Color(0xFF979C9E),
                          // color: title == 'Cash'
                          //     ? context.gc(AppColor.greenColor)
                          //     : context.gc(AppColor.redColor),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$belowtext',
                      style: const TextStyle(
                          color: Color(0xFF979C9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: 100,
                    height: 10,
                    color: context.gc(AppColor.white),
                  ),
                ),
                Icon(
                  image,
                  color: Colors.black,
                  size: 16,
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  // final RxString selectedTab = '1 M'.obs;
  Widget _buildSpendGraph({futureController, tags}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildChartShimmerEffect();
        } else if (snapshot.hasError) {
          return isEmptyVitals(title: 'Total Spend');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return isEmptyVitals(title: 'Total Spend');
        }

        final responseData = snapshot.data!;
        final chartData = responseData.toList();
        final xLabels = chartData.map((e) => e['monthName'] as String).toList();

        final List<FlSpot> spots = List.generate(chartData.length, (index) {
          final total = (chartData[index]['total'] as num).toDouble();
          return FlSpot(index.toDouble(), total);
        });

        final totalSum = responseData.fold<double>(
          0,
          (sum, item) => sum + (item['total'] as num).abs().toDouble(),
        );
        // final isSelected = selectedTab.value == '1 M';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: (totalSum == 0.0) ? 200 : 200,
              child: (totalSum == 0.0)
                  ? ExpenseEmptyChart(spots: spots, xLabels: xLabels)
                  : ExpenseChart(
                      spots: spots,
                      xLabels: xLabels,
                      timePeriod: tags == 'networth'
                          ? networthcontroller.dwmyDropdown.value
                          : tags == 'income'
                              ? _controllerIncome.dwmyDropdown.value
                              : tags == 'cashflow'
                                  ? _controllerCashflow.dwmyDropdown.value
                                  : _controllerExpence.dwmyDropdown.value,
                      val: tags == 'networth'
                          ? networthcontroller.totalSpend
                          : tags == 'income'
                              ? _controllerIncome.totalIncomeAmount
                              : tags == 'cashflow'
                                  ? _controllerCashflow.totalCashFlowAmount
                                  : _controllerExpence.totalExpenceAmount,
                    ),
            ),
          ],
        );
      },
    );
  }
}
