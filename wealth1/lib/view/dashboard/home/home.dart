import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/dashboard/dashboard_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/controller/investment/investment_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/controller/profile/profile_controller.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import 'package:wealthnx/controller/transations/transations_controller.dart';
import 'package:wealthnx/controller/wealth_genie/wealth_genie_controller.dart';
import 'package:wealthnx/home-screens/notifications/notification_screen.dart';
import 'package:wealthnx/services/logout_service.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/view/feedback/feedback_dialog_trigger.dart';
import 'package:wealthnx/view/schedule/add_schedule/add_schedule_screen.dart';
import 'package:wealthnx/view/schedule/detail_schedule_screen/detail_schedule_screen.dart';
import 'package:wealthnx/view/schedule/schedule_screen.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/coins_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_coin_today_list/crypto_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stocks/stock_coin_today_list/stock_coin_today_list.dart';
import 'package:wealthnx/view/vitals/investment/widgets/crypto_list_section.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/view/vitals/transations/transactions.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';
import 'package:wealthnx/view/dashboard/drawer/drawer.dart';
import 'package:wealthnx/view/genral_news/genral_news_viewall_screen.dart';
import 'package:wealthnx/widgets/chart_painter.dart';
import 'package:wealthnx/widgets/custom_list_item.dart';
import 'package:wealthnx/widgets/empty.dart';

import '../../../controller/budget/budget_controller.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Initialize all controllers in one place

  final controller = Get.find<ScheduleController>();

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  final HomeController _homeController = Get.find<HomeController>();

  final CommonController _commonController = Get.put(CommonController());

  final TransactionsController _tarnsController =
      Get.find<TransactionsController>();

  bool _hasInitializedTransactions = false;

  final InvestmentController _investmentController =
      Get.find<InvestmentController>();

  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  final ProfileController profileController = Get.find<ProfileController>();

  // final NetWorthController networthController = Get.put(NetWorthController());
  final NetWorthController networthController = Get.find<NetWorthController>();

  // Initialize news controllers here if needed
  final NewsController newsController = Get.put(NewsController());

  final PressReleaseNewsController pressReleaseController =
      Get.put(PressReleaseNewsController());

  final CashFlowController _controllerCashflow = Get.find<CashFlowController>();
  final BudgetController _controllerBudget = Get.find<BudgetController>();

  final IncomeController _controllerIncome = Get.put(IncomeController());
  final ExpensesController _controllerExpence = Get.find<ExpensesController>();

  final WealthGenieController _genieController =
      Get.find<WealthGenieController>();

  @override
  void initState() {
    super.initState();
    profileController.fetchProfileData();
    _homeController.fetchExpenseCategories();
    newsController.fetchPaginatedNews(isFirstLoad: true);
    pressReleaseController.fetchPaginatedNews(isFirstLoad: true);
    controller.fetchTodaySchedules();
    FeedbackDialogTrigger.triggerAfterLogin();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.isLoading.value = false;
      Get.find<CheckPlaidConnectionController>().checkConnection();
      newsController.fetchPaginatedNews(isFirstLoad: true);
      pressReleaseController.fetchPaginatedNews(isFirstLoad: true);
    });
    if (!_hasInitializedTransactions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasInitializedTransactions) {
          print('🚀 Initializing transactions after first build');
          _hasInitializedTransactions = true;

          _tarnsController.fetchTransations();
        }
      });
    }


    return Scaffold(
      backgroundColor: context.gc(AppColor.transparent),
      drawer: CustomDrawer(),
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: context.gc(AppColor.black)),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.gc(AppColor.black), width: 0.5),
            ),
          ),
          child: Obx(
            () {
              int currentIndex = _dashboardController.selectedIndex.value;
            return  BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: _dashboardController.onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: context.gc(AppColor.bottomNav),
                selectedItemColor: context.gc(AppColor.white),
                unselectedItemColor: context.gc(AppColor.grey),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: TextStyle(
                    fontSize: _commonController.responsiveWidth *
                        (10 / _commonController.responsiveWidth),
                    fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(
                    fontSize: _commonController.responsiveWidth *
                        (10 / _commonController.responsiveWidth),
                    fontWeight: FontWeight.w400),
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      width: _commonController.responsiveWidth *
                          (28 / _commonController.responsiveWidth),
                      height: _commonController.responsiveHeight *
                          (28 / _commonController.responsiveHeight),
                      fit: BoxFit.contain,
                      currentIndex == 0
                          ? ImagePaths.homeicon
                          : ImagePaths.unfillhome,
                      color: currentIndex == 0
                          ? context.gc(AppColor.white)
                          : context.gc(AppColor.grey),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      width: _commonController.responsiveWidth *
                          (28 / _commonController.responsiveWidth),
                      height: _commonController.responsiveHeight *
                          (28 / _commonController.responsiveHeight),
                      fit: BoxFit.contain,
                      ImagePaths.wealth,
                      color: currentIndex == 1
                          ? context.gc(AppColor.white)
                          : context.gc(AppColor.grey),
                    ),
                    label: 'Wealth Genie',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      width: _commonController.responsiveWidth *
                          (28 / _commonController.responsiveWidth),
                      height: _commonController.responsiveHeight *
                          (28 / _commonController.responsiveHeight),
                      fit: BoxFit.contain,
                      ImagePaths.vitalsicon,
                      color: currentIndex == 2
                          ? context.gc(AppColor.white)
                          : context.gc(AppColor.grey),
                    ),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      width: currentIndex == 3
                          ? _commonController.responsiveWidth *
                          (20 / _commonController.responsiveWidth)
                          : _commonController.responsiveWidth *
                          (28 / _commonController.responsiveWidth),
                      height: _commonController.responsiveHeight *
                          (28 / _commonController.responsiveHeight),
                      fit: BoxFit.contain,
                      currentIndex == 3
                          ? ImagePaths.fillinvest
                          : ImagePaths.investmenticon,
                      // color: Colors.white,
                    ),
                    label: 'Investments',
                  ),
                ],
              );
            }
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (val) {
          if (val) {
            return;
          }
          _commonController.showExitDialog(context);
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: responTextHeight(50)),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(ImagePaths.grad),
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: marginSide()),
              child: Column(
                children: [
                  buildHeader(context),
                  addHeight(21),
                  buildNameSection(context),
                  addHeight(12),
                  buildAskGenieSection(),
                  addHeight(12),
                  // buildSuggestionSection(context),
                  // addHeight(30),
                  buildPortfolioSection(context),
                  addHeight(30),
                  buildFinSnapSection(context),
                  addHeight(30),
                  buildTodayListSection(),
                  addHeight(10),
                  buildScheduleSection(context),
                  addHeight(30),
                  joinDiscordCard(
                    text: 'Join Our Community',
                    subText:
                    'Join our Discord Community to get access to new features before anyone & help us improve WealthNX',
                    onTap: () async {
                      const discordUrl = 'https://discord.com/channels/1374763460159602759/1374763460159602762';
                      if (await canLaunchUrl(Uri.parse(discordUrl))) {
                        await launchUrl(Uri.parse(discordUrl), mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $discordUrl';
                      }
                    },
                  ),

                  addHeight(30),
                  buildFintechInsiderSection(context),
                  addHeight(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Image.asset(
                ImagePaths.menu,
                fit: BoxFit.contain,
                height: responTextHeight(14),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            Get.to(() => NotificationScreen());
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 6.0),
            child: Image.asset(
              ImagePaths.noti,
              fit: BoxFit.contain,
              height: responTextHeight(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAskGenieSection() {
    return GestureDetector(
      onTap: () async {
        _dashboardController.selectedIndex.value = 1;

        // Get.back();
        _genieController.clearHistory();
        // _genieController.generateSessionId();
        _genieController.sessionMsgId.value =
            _genieController.generateSessionId();

        _genieController.focusNodeDashboard.text = "focusNodeDashboard";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'newSessionId', _genieController.sessionMsgId.value);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: context.gc(AppColor.primary), width: 0.5)),
        child: Row(
          children: [
            Image.asset(
              ImagePaths.wealthgenpng,
              height: 21,
              fit: BoxFit.contain,
            ),
            addWidth(),
            Text(
              'Ask Wealth Genie....',
              style: TextStyle(color: context.gc(AppColor.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNameSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Obx(() => textWidget(
                context,
                title: 'Hi ${profileController.fullNameProfile}',
                fontSize: responTextWidth(14),
                fontWeight: FontWeight.w400,
              )),
          addHeight(4),
          GestureDetector(
            onTap: () {
              Get.offAll(() => Dashboard());
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Before image
                Image.asset(
                  'assets/images/left_star.png',
                  width: 16,
                  height: 24,
                ),
                SizedBox(width: 6),
                textWidget(
                  context,
                  title: 'Generate Prompt',
                  fontSize: responTextWidth(16),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 6),
                // After image
                Image.asset(
                  'assets/images/right_star.png',
                  width: 16,
                  height: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuggestionSection(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF252525), width: 0.8),
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: Text('Build a dashboard for planned budgeting',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
          addWidth(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF252525), width: 0.8),
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: Text('Perform financial ratio of Top Crypto',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget buildPortfolioSection(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionName(
            title: 'AI Agents',
            titleOnTap: '',
            onTap: () {
              // Get.to(() => MyPortfolioScreen());
            },
          ),
          addHeight(14),
          if (_homeController.isLoadingPortfolio.value) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  coinTypeShimmer(context),
                  addWidth(12),
                  coinTypeShimmer(context),
                ],
              ),
            ),
          ] else if (_homeController.myPortfolio.isEmpty) ...[
            SizedBox(
              height: responTextHeight(110),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    homePortfolio(
                        icon: ImagePaths.wg7,
                        agentType: "Accountant ",
                        agentDescrp:
                            networthController.networth.value?.body == null
                                ? "Accounts Overview"
                                : 'Accounts Overview',
                        totalworth: (networthController.networth.value?.body ==
                                null
                            ? '\$0.0'
                            : (networthController.networth.value?.body
                                            ?.totalNetWorth ??
                                        0.0) >=
                                    0
                                ? '\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.toInt()}'
                                : '-\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${networthController.networth.value?.body?.percentageChange.toString() == '0.0' ? '0.00' : networthController.networth.value?.body?.percentageChange?.toString()}",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: ImagePaths.notaccountant),
                    homePortfolio(
                        icon: ImagePaths.wg3,
                        agentType: "Stock Agent ",
                        agentDescrp: _investmentController
                                    .investmentOverview.value?.body ==
                                null
                            ? "Stock Market Overview"
                            : 'Stock Portfolio Overview',
                        totalworth: (_investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : (_investmentController.investmentOverview.value
                                            ?.body?[0].stocksTotal ??
                                        0.0) >=
                                    0
                                ? '\$${_investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt()}'
                                : '-\$${_investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksTotal?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${_investmentController.investmentOverview.value?.body?[0].stocksChange24HPercent?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksChange24HPercent?.toInt()}%",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: ImagePaths.notstocks),
                    homePortfolio(
                        icon: ImagePaths.wg6,
                        agentType: "Crypto Agent",
                        agentDescrp: _investmentController
                                    .investmentOverview.value?.body ==
                                null
                            ? "Crypto Market Overview"
                            : "Crypto Portfolio Overview",
                        totalworth: (_investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : (_investmentController.investmentOverview.value
                                            ?.body?[0].cryptoTotal ??
                                        0.0) >=
                                    0
                                ? '\$${_investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt()}'
                                : '-\$${_investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoTotal?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${_investmentController.investmentOverview.value?.body?[0].cryptoChange24HPercent?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoChange24HPercent?.toInt()}%",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: ImagePaths.notcryptos),
                    homePortfolio(
                      icon: ImagePaths.wg8,
                      agentType: "Build Mode ",
                      agentDescrp:
                          networthController.networth.value?.body == null
                              ? "Text to Visuals"
                              : 'Text to Visuals',
                      totalworth: (networthController.networth.value?.body ==
                              null
                          ? '\$0.0'
                          : (networthController.networth.value?.body
                                          ?.totalNetWorth ??
                                      0.0) >=
                                  0
                              ? '\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.toInt()}'
                              : '-\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.abs().toInt()}'),
                      percentage: _investmentController
                                  .investmentOverview.value ==
                              null
                          ? '\$0.0'
                          : "${networthController.networth.value?.body?.percentageChange.toString() == '0.0' ? '0.00' : networthController.networth.value?.body?.percentageChange?.toString()}",
                      val: 45.0,
                      chg: 70.0,
                    ),
                  ],
                ),
              ),
            )
          ] else ...[
            SizedBox(
              height: responTextHeight(110),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    homePortfolio(
                        icon: ImagePaths.wg7,
                        agentType: "Accountant ",
                        agentDescrp:
                            networthController.networth.value?.body == null
                                ? "Accounts Overview"
                                : 'Accounts Overview',
                        totalworth: (networthController.networth.value?.body ==
                                null
                            ? '\$0.0'
                            : (networthController.networth.value?.body
                                            ?.totalNetWorth ??
                                        0.0) >=
                                    0
                                ? '\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.toInt()}'
                                : '-\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${networthController.networth.value?.body?.percentageChange.toString() == '0.0' ? '0.00' : networthController.networth.value?.body?.percentageChange?.toString()}",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: "assets/images/accountant_icon.png"),
                    homePortfolio(
                        icon: ImagePaths.wg3,
                        agentType: "Stock Agent ",
                        agentDescrp: _investmentController
                                    .investmentOverview.value?.body ==
                                null
                            ? "Stock Market Overview"
                            : 'Stock Portfolio Overview',
                        totalworth: (_investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : (_investmentController.investmentOverview.value
                                            ?.body?[0].stocksTotal ??
                                        0.0) >=
                                    0
                                ? '\$${_investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt()}'
                                : '-\$${_investmentController.investmentOverview.value?.body?[0].stocksTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksTotal?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${_investmentController.investmentOverview.value?.body?[0].stocksChange24HPercent?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].stocksChange24HPercent?.toInt()}%",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: "assets/images/stock_icon.png"),
                    homePortfolio(
                        icon: ImagePaths.wg6,
                        agentType: "Crypto Agent",
                        agentDescrp: _investmentController
                                    .investmentOverview.value?.body ==
                                null
                            ? "Crypto Market Overview"
                            : "Crypto Portfolio Overview",
                        totalworth: (_investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : (_investmentController.investmentOverview.value
                                            ?.body?[0].cryptoTotal ??
                                        0.0) >=
                                    0
                                ? '\$${_investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt()}'
                                : '-\$${_investmentController.investmentOverview.value?.body?[0].cryptoTotal?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoTotal?.abs().toInt()}'),
                        percentage: _investmentController
                                    .investmentOverview.value ==
                                null
                            ? '\$0.0'
                            : "${_investmentController.investmentOverview.value?.body?[0].cryptoChange24HPercent?.toInt() == 0.0 ? '0.00' : _investmentController.investmentOverview.value?.body?[0].cryptoChange24HPercent?.toInt()}%",
                        val: 45.0,
                        chg: 70.0,
                        iconPaths: "assets/images/crypto_icon.png"),
                    homePortfolio(
                      icon: ImagePaths.wg8,
                      agentType: "Build Mode ",
                      agentDescrp:
                          networthController.networth.value?.body == null
                              ? "Text to Visuals"
                              : 'Text to Visuals',
                      totalworth: (networthController.networth.value?.body ==
                              null
                          ? '\$0.0'
                          : (networthController.networth.value?.body
                                          ?.totalNetWorth ??
                                      0.0) >=
                                  0
                              ? '\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.toInt()}'
                              : '-\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.abs().toInt()}'),
                      percentage: _investmentController
                                  .investmentOverview.value ==
                              null
                          ? '\$0.0'
                          : "${networthController.networth.value?.body?.percentageChange.toString() == '0.0' ? '0.00' : networthController.networth.value?.body?.percentageChange?.toString()}",
                      val: 45.0,
                      chg: 70.0,
                    ),
                  ],
                ),
              ),
            )
          ],
        ],
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _ensureToday(ScheduleController c) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cur = c.currentDate.value;
    final curDay = DateTime(cur.year, cur.month, cur.day);
    if (!_isSameDay(curDay, today) && !c.isLoadingExpense.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.fetchSchedules(today);
      });
    }
  }

  Widget homePortfolio({
    icon,
    agentType,
    agentDescrp,
    totalworth,
    percentage,
    val,
    chg,
    String? iconPaths,
  }) {
    return GestureDetector(
      onTap: () async {
        _dashboardController.selectedIndex.value = 1;

        // Get.back();
        _genieController.clearHistory();
        // _genieController.generateSessionId();
        _genieController.sessionMsgId.value =
            _genieController.generateSessionId();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'newSessionId', _genieController.sessionMsgId.value);

        _genieController.messageController.text = agentDescrp;
        _genieController.handleMessageSubmit();
      },
      child: Container(
        height: marginVertical(110),
        width: responTextWidth(208),
        margin: EdgeInsets.only(right: responTextWidth(12)),
        padding: EdgeInsets.all(responTextWidth(8)),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImagePaths.aiagent),
              fit: BoxFit.fill,
              alignment: Alignment.center),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  icon,
                  color: Colors.white,
                  fit: BoxFit.contain,
                  width: 18,
                  height: 18,
                ),
                addWidth(8),
                textWidget(context,
                    title: agentType,
                    fontSize: responTextWidth(14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    fontWeight: FontWeight.w500),
              ],
            ),
            addHeight(8),
            textWidget(context,
                title: agentDescrp,
                fontSize: responTextWidth(12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                fontWeight: FontWeight.w300),
            Spacer(),
            if (agentType == 'Build Mode ') ...[
              Image.asset(
                ImagePaths.buildMode,
                // color: Colors.white,
                fit: BoxFit.contain,
              ),
            ] else if (_homeController.myPortfolio.isEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: iconPaths != null
                          ? Image.asset(iconPaths,
                              height: 28, alignment: Alignment.centerLeft)
                          : SizedBox(),
                      // child: Stack(
                      //   alignment: Alignment.center,
                      //   fit: StackFit.passthrough,
                      //   clipBehavior: Clip.none,
                      //   children: [
                      //     CircleAvatar(
                      //       radius: 14,
                      //       backgroundColor: Colors.transparent,
                      //       // backgroundImage:
                      //       //     AssetImage('assets/images/exp_1.png'),
                      //     ),
                      //     Positioned(
                      //       left: 0,
                      //       child: CircleAvatar(
                      //         radius: 14,
                      //         backgroundColor: Colors.transparent,
                      //         backgroundImage:
                      //             AssetImage('assets/images/AccountantIcon1.png'),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       left: 12,
                      //       child: CircleAvatar(
                      //         radius: 14,
                      //         backgroundColor: Colors.transparent,
                      //         backgroundImage:
                      //             AssetImage('assets/images/AccountantIcon2.png'),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       left: 24,
                      //       child: CircleAvatar(
                      //         radius: 14,
                      //         backgroundColor: Colors.transparent,
                      //         backgroundImage:
                      //             AssetImage('assets/images/AccountantIcon3.png'),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       left: 34,
                      //       child: CircleAvatar(
                      //         radius: 14,
                      //         backgroundColor: Colors.transparent,
                      //         backgroundImage:
                      //         AssetImage('assets/images/AccountantIcon4.png'),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: responTextHeight(20),
                        child: CustomPaint(
                          size: Size(val ?? 0.0, chg ?? 0.0),
                          painter: ChartPainter(
                            borderColor: CustomAppTheme.green,
                            gradientColors: [
                              context.gc(AppColor.primary).withOpacity(0.5),
                              context.gc(AppColor.primary).withOpacity(0.1),
                            ],
                            isDown: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textWidget(context,
                      title: totalworth,
                      fontSize: responTextWidth(15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontWeight: FontWeight.w400),
                  addWidth(20),
                  Expanded(
                    child: SizedBox(
                      height: responTextHeight(20),
                      child: CustomPaint(
                        size: Size(val ?? 0.0, chg ?? 0.0),
                        painter: ChartPainter(
                          borderColor: CustomAppTheme.green,
                          gradientColors: [
                            context.gc(AppColor.primary).withOpacity(0.5),
                            context.gc(AppColor.primary).withOpacity(0.1),
                          ],
                          isDown: true,
                        ),
                      ),
                    ),
                  ),
                  addWidth(20),
                  textWidget(context,
                      title: percentage,
                      fontSize: responTextWidth(13),
                      color: context.gc(AppColor.greenColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontWeight: FontWeight.w500),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingIcons(List<String>? iconPaths) {
    if (iconPaths == null || iconPaths.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(iconPaths.length, (index) {
        return Positioned(
          left: index * 12.0, // spacing between avatars
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(iconPaths[index]),
          ),
        );
      }),
    );
  }

  Widget buildFinSnapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textWidget(
                  context,
                  title: 'Financial Snapshot',
                  fontSize: responTextWidth(16),
                  fontWeight: FontWeight.w600,
                ),

                connectivityController.isLoading.value && connectivityController.isConnected.value == false
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(
                          width: 60,
                          height: 11,
                          color: Colors.white,
                        ),
                      )
                    : connectivityController.isConnected.value == false
                        ? GestureDetector(
                            onTap: () {
                              Get.to(() => ConnectAccounts());
                            },
                            child: textWidget(
                              context,
                              title: '+ Connect Account',
                              fontSize: responTextWidth(14),
                              color: Color(0xFF2BD1C1),
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        : SizedBox
                            .shrink(),
              ],
            )),
        addHeight(12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            if (connectivityController.isLoading.value) {
              return Row(
                children:
                    List.generate(5, (index) => buildFinSnapCardShimmer()),
              );
            }
            return Row(
              children: [
                Obx(() => buildFinSnapCard(
                    onTap: () {
                      // if (connectivityController.isConnected.value == false) {
                      //   Get.dialog(ConnectivityDialog());
                      // } else if (connectivityController.isConnected.value ==
                      //     true) {
                      Get.toNamed("/networth");
                      // }
                    },
                    icon: ImagePaths.dollar,
                    title: "Net Worth",
                    totalAmount: (networthController.networth.value == null
                        ? '\$0.0'
                        : (networthController
                                        .networth.value?.body?.totalNetWorth ??
                                    0.0) >=
                                0
                            ? '\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.toInt()}'
                            : '-\$${networthController.networth.value?.body?.totalNetWorth?.toInt() == 0.0 ? '0.00' : networthController.networth.value?.body?.totalNetWorth?.abs().toInt()}'))),
                Obx(() => buildFinSnapCard(
                    onTap: () {
                      Get.toNamed("/cashflow");
                    },
                    icon: ImagePaths.banknote,
                    title: "Cash Flow",
                    totalAmount: (_controllerCashflow.cashflow.value == null
                        ? '\$0.0'
                        : (_controllerCashflow
                                        .cashflow.value?.body?.netCashFlow ??
                                    0.0) >=
                                0
                            ? '\$${_controllerCashflow.cashflow.value?.body?.netCashFlow?.toInt() == 0.0 ? '0.00' : _controllerCashflow.cashflow.value?.body?.netCashFlow?.toInt()}'
                            : '-\$${_controllerCashflow.cashflow.value?.body?.netCashFlow?.toInt() == 0.0 ? '0.00' : _controllerCashflow.cashflow.value?.body?.netCashFlow?.abs().toInt()}'))),
                Obx(() => buildFinSnapCard(
                    onTap: () {
                      Get.toNamed("/expense");
                    },
                    icon: ImagePaths.calculator,
                    title: "Expense",
                    totalAmount: (_controllerExpence.expense.value == null
                        ? '\$0.0'
                        : (_controllerExpence
                                        .expense.value?.body?.totalExpense ??
                                    0.0) >=
                                0
                            ? '\$${_controllerExpence.expense.value?.body?.totalExpense?.toInt() == 0.0 ? '0.00' : _controllerExpence.expense.value?.body?.totalExpense?.toInt()}'
                            : '-\$${_controllerExpence.expense.value?.body?.totalExpense?.toInt() == 0.0 ? '0.00' : _controllerExpence.expense.value?.body?.totalExpense?.abs().toInt()}'))),
                Obx(() => buildFinSnapCard(
                    onTap: () {
                      Get.toNamed("/income");
                    },
                    icon: ImagePaths.profit,
                    title: "Income",
                    totalAmount: (_controllerIncome.income.value == null
                        ? '\$0.0'
                        : (_controllerIncome.income.value?.body
                                        ?.totalIncomeAmount ??
                                    0.0) >=
                                0
                            ? '\$${_controllerIncome.income.value?.body?.totalIncomeAmount?.toInt() == 0.0 ? '0.00' : _controllerIncome.income.value?.body?.totalIncomeAmount?.toInt()}'
                            : '-\$${_controllerIncome.income.value?.body?.totalIncomeAmount?.toInt() == 0.0 ? '0.00' : _controllerIncome.income.value?.body?.totalIncomeAmount?.abs().toInt()}'))),
                Obx(() => buildFinSnapCard(
                    onTap: () {
                      Get.put(BudgetController()).fetchBudgets();
                      Get.toNamed("/budget");
                    },
                    icon: ImagePaths.assetM,
                    title: "Budget",
                    totalAmount: (_controllerBudget.budgetResponse.value == null
                        ? '\$0.0'
                        : (_controllerBudget.budgetResponse.value?.body
                                        ?.totalBudget ??
                                    0.0) >=
                                0
                            ? '\$${_controllerBudget.budgetResponse.value?.body?.totalBudget?.toInt() == 0.0 ? '0.00' : _controllerBudget.budgetResponse.value?.body?.totalBudget?.toInt()}'
                            : '-\$${_controllerBudget.budgetResponse.value?.body?.totalBudget?.toInt() == 0.0 ? '0.00' : _controllerBudget.budgetResponse.value?.body?.totalBudget?.abs().toInt()}'))),
              ],
            );
          }),
        ),

        // addHeight(),
      ],
    );
  }

  Widget buildFinSnapCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(right: 30),
      child: Row(
        children: [
          Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  width: 60,
                  height: 11,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildFinSnapCard({icon, title, totalAmount, onTap}) {
    return Container(
      margin: EdgeInsets.only(right: 30),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
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
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
            addHeight(8),
            textWidget(
              context,
              title: title,
              fontSize: responTextWidth(12),
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            // textWidget(
            //   context,
            //   title: totalAmount,
            //   fontSize: responTextWidth(12),
            //   color: context.gc(AppColor.grey),
            //   fontWeight: FontWeight.w400,
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildTodayListSection() {
    return Container(
      // padding: EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: const Color.fromARGB(255, 40, 40, 40),
      //   ),
      // ),
      child: Column(
        children: [
          SectionName(
            title: 'Top Movers',
            titleOnTap: '',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          SectionName(
            title: 'Crypto',
            titleOnTap: 'View All',
            fontSize: responTextWidth(12),
            onTapColor: Color(0xFFD6D6D6),
            onTap: () => Get.to(() => CryptoCoinTodayList()),
          ),
          const SizedBox(height: 16),
          CryptoListSection(filterTag: 'overview'),
          SectionName(
            title: 'Stocks',
            titleOnTap: 'View All',
            fontSize: responTextWidth(12),
            onTapColor: Color(0xFFD6D6D6),
            onTap: () => Get.to(() => CoinsScreen()),
          ),
          const SizedBox(height: 16),
          StockCoinTodayList(filterTag: 'overview'),
        ],
      ),
    );
  }

  // UPDATED TRANSACTION SECTION WITH BETTER DEBUG INFO
  Widget buildTransactionHistorySection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionName(
          title: 'Transaction History',
          titleOnTap: 'View All',
          onTap: () {
            Get.to(() => TransactionsPage());
          },
        ),
        addHeight(14),
        Obx(() {
          if (_tarnsController.isLoadingTran.value) {
            return _tarnsController.buildShimmerEffect();
          } else if (_tarnsController.errorMessage.value.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   _tarnsController.errorMessage.value,
                //   style: TextStyle(color: Colors.red, fontSize: 14),
                //   textAlign: TextAlign.center,
                // ),
                // SizedBox(height: 10),
                Empty(
                  height: 80,
                  title: "Transactions Found",
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _tarnsController.fetchTransations(force: true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(46, 173, 165, 1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color.fromRGBO(46, 173, 165, 1),
                        width: 0.25,
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (_tarnsController.filteredTransactions.isEmpty) {
            print('Showing empty state');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Empty(
                  title: 'No Transactions Found',
                  width: 140,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _tarnsController.fetchTransations(force: true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(46, 173, 165, 1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color.fromRGBO(46, 173, 165, 1),
                        width: 0.25,
                      ),
                    ),
                    child: Text(
                      'Reload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            final groupedTransactions =
                _tarnsController.groupedTransactions.length > 3
                    ? _tarnsController.groupedTransactions
                    : _tarnsController.groupedTransactions;
            final itemCount =
                groupedTransactions.length; // Already limited to 3 in getter
            print('Rendering ListView with $itemCount groups');

            if (itemCount == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No grouped transactions available',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _tarnsController.fetchTransations(force: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(46, 173, 165, 1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color.fromRGBO(46, 173, 165, 1),
                          width: 0.25,
                        ),
                      ),
                      child: Text(
                        'Reload',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: _tarnsController.filteredTransactions.length > 3
                  ? 3
                  : _tarnsController.filteredTransactions.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, groupIndex) {
                final txn = _tarnsController.filteredTransactions[groupIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => TransationReceipt(
                              id: txn.id,
                              name: txn.title,
                              amount: txn.amount.toString(),
                              date: txn.date.toString(),
                              category: txn.category,
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 76,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.25),
                                ),
                                child: Image.asset(ImagePaths.trans),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      txn.title ?? 'Untitled',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${_tarnsController.formatTime('${txn.date}')} · ${_tarnsController.formatDate('${txn.date}')}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '\$${txn.amount ?? 0}',
                                style: TextStyle(
                                  color: (txn.amount ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    /* }).toList(),*/
                  ],
                );
              },
            );
          }
        }),
      ],
    );
  }

  Widget buildScheduleSection(BuildContext context) {
    final schedule = Get.find<ScheduleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionName(
          title: 'Schedule',
          titleOnTap: 'View All',
          onTap: () async {
            if (!schedule.isLoadingExpense.value) {
              final changed = await Get.to(() => const ScheduleScreen());
              if (changed == true) {
                controller.fetchTodaySchedules();
                controller.currentDate.value = DateTime.now();
                controller.fetchSchedules(controller.currentDate.value);
              }
            }
          },
        ),
        addHeight(14),
        Obx(() {
          if (schedule.isLoadingExpense.value) {
            // shimmer while loading
            return SizedBox(
              height: responTextHeight(100),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(
                        width: responTextWidth(300),
                        height: responTextHeight(80),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          final todays = schedule.upcomingSchedules;
          if (todays.isEmpty) {
            if (connectivityController.isConnected.value != null &&
                    connectivityController.isConnected.value == false ||
                connectivityController.isConnected.value == true) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => const AddScheduleScreen());
                },
                child: Container(
                  width: double.infinity,
                  height: marginVertical(70),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 73, 67, 0.3),
                        CustomAppTheme.darkBlack,
                      ],
                      stops: [0, 0.3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: context.gc(AppColor.grey), width: 0.25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            ImagePaths.schedule,
                            color: Colors.white,
                            fit: BoxFit.contain,
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Add schedule",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 15),
                    ],
                  ),
                ),
              );
            }
          }

          return SizedBox(
            height: responTextHeight(100),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              primary: false,
              itemCount: todays.length,
              separatorBuilder: (_, __) => addWidth(5),
              itemBuilder: (context, index) {
                final item = todays[index];
                return SizedBox(
                  width: responTextWidth(312),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () async {
                        // Go to detail; if changed, refresh same day
                        final changed = await Get.to(() => DetailScheduleScreen(
                              recurringItem: item,
                              logoUrl: item.logoUrl,
                            ));
                        if (changed == true) {
                          schedule.fetchSchedules(schedule.currentDate.value);
                        }
                      },
                      child: CustomBillCard(
                        avatarUrl: item.logoUrl,
                        title: item.name,
                        description: item.recurrenceInterval,
                        // or item.description
                        // IMPORTANT: pass a plain number/string here; CustomBillCard adds $ by itself
                        price: item.amount.toInt().toString(),
                        dividerColor: CustomAppTheme.primaryColor,
                        avatarIcon:item.category ==  'OTHER'? null
                            : getIconForCategory(item.category),
                        IconColors:item.category ==  'OTHER'? null
                            : getCategoryColor(item.category),
                        date: item.date,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget buildFintechInsiderSection(BuildContext context) {
    final controller = Get.put(NewsController());

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionName(
        title: 'News',
        titleOnTap: 'View All',
        onTap: () {
          controller.fetchPaginatedNews(isFirstLoad: true);

          Get.to(() => ViewAllNewsPage());
        },
      ),
      addHeight(14),
      Obx(() {
        if (controller.isLoading.value && controller.newsList.isEmpty) {
          final cardWidth = marginSide(300);
          final cardHeight = marginVertical(210);

          return SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4, // show a few shimmer cards
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _trendingCardShimmer(
                  width: cardWidth,
                  height: cardHeight,
                  radius: 16,
                ),
              ),
            ),
          );
        } else if (controller.newsList.isEmpty) {
          return Center(
            child: Empty(
              title: 'News',
              height: responTextHeight(70),
            ),
          );
        }

        // ... keep your existing SizedBox with real NewsCard list
        return SizedBox(
          height: marginVertical(270),
          child: Builder(builder: (context) {
            final trending = controller.trending6;
            if (trending.isEmpty) {
              return Center(
                child: Empty(
                  title: 'News',
                  height: responTextHeight(70),
                ),
              );
            }

            final itemCount = trending.length >= 2 ? 2 : trending.length;
            final cardWidth = Get.width * 0.75;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final news = trending[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: cardWidth,
                    child: NewsCard(
                      imageUrl: news.image,
                      title: news.title ?? '',
                      source: news.site ?? '',
                      date: news.publishedDate ?? '',
                      publishDate: news.publishedDate,
                      tag: "Just Now",
                      isHorizontal: false,
                      showRelativeDate: false,
                      relativeText: '',
                      url: news.url,
                    ),
                  ),
                );
              },
            );
          }),
        );
      }),

      // Obx(() {
      //   if (controller.isLoading.value && controller.newsList.isEmpty) {
      //     return ListView.builder(
      //         itemCount: 2,
      //         shrinkWrap: true,
      //         padding: EdgeInsets.all(0),
      //         itemBuilder: (context, index) {
      //           return Padding(
      //             padding: const EdgeInsets.symmetric(vertical: 8.0),
      //             child: buildInvestChartShimmerEffect(),
      //           );
      //         });
      //   } else if (controller.newsList.isEmpty) {
      //     return Center(
      //       child: Empty(
      //         title: 'News',
      //         height: responTextHeight(70),
      //       ),
      //     );
      //   }
      //
      //   return SizedBox(
      //     height: Get.height * 0.35,
      //     child: Builder(builder: (context) {
      //       final trending = controller.trending6;
      //       if (trending.isEmpty) {
      //         return const Center(
      //           child: Text('No trending news',
      //               style: TextStyle(color: Colors.white54)),
      //         );
      //       }
      //
      //       final itemCount = trending.length >= 2 ? 2 : trending.length;
      //       final cardWidth = Get.width * 0.75;
      //
      //       return ListView.builder(
      //         padding: const EdgeInsets.symmetric(horizontal: 12),
      //         scrollDirection: Axis.horizontal,
      //         itemCount: itemCount,
      //         itemBuilder: (context, index) {
      //           final news = trending[index];
      //           return SizedBox(
      //             width: cardWidth,
      //             child: NewsCard(
      //               imageUrl: news.image ,
      //               title: news.title ?? '',
      //               source: news.site ?? '',
      //               date: news.publishedDate ?? '',
      //               publishDate: news.publishedDate,
      //               tag: "Just Now",
      //               isHorizontal: false,
      //               showRelativeDate: false,
      //               relativeText: '',
      //               url: news.url,
      //             ),
      //           );
      //         },
      //       );
      //     }),
      //   );
      //
      // }),
    ]);
  }
}

Widget _trendingCardShimmer({
  required double width,
  required double height,
  required double radius,
}) {
  final base = Colors.grey[850]!;
  final highlight = Colors.grey[700]!;

  return Shimmer.fromColors(
    baseColor: base,
    highlightColor: highlight,
    child: SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image area
              Expanded(child: Container(color: base)),
              // text/meta area
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerLine(width * 0.85, 14, base),
                    const SizedBox(height: 6),
                    _shimmerLine(width * 0.55, 12, base),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _shimmerCircle(18, base),
                        const SizedBox(width: 8),
                        _shimmerLine(70, 10, base),
                        const SizedBox(width: 8),
                        _shimmerLine(48, 10, base),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _shimmerLine(double w, double h, Color base) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(width: w, height: h, color: base),
    );

Widget _shimmerCircle(double size, Color base) => ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Container(width: size, height: size, color: base),
    );
