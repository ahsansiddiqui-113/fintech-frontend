import 'package:get/get.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/connect_account/connect_account_controller.dart';
import 'package:wealthnx/controller/dashboard/dashboard_controller.dart';
import 'package:wealthnx/controller/drawer/drawer_controller.dart';
import 'package:wealthnx/controller/expenses/add_expence_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/genral_news/genral_news_controller.dart';
import 'package:wealthnx/controller/genral_news/press_release_news_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/controller/income/add_income_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/today_crypto_list/market_coin_list_controller.dart';
import 'package:wealthnx/controller/investment/investment_controller.dart';
import 'package:wealthnx/controller/investment/overview/merge_stock_controller.dart';
import 'package:wealthnx/controller/investment/overview/overview_controller.dart';
import 'package:wealthnx/controller/investment/today_list_stock/detail_list_stock_controller.dart';
import 'package:wealthnx/controller/login/login_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/controller/onboading/onboading_controller.dart';
import 'package:wealthnx/controller/profile/profile_controller.dart';
import 'package:wealthnx/controller/schedule/schedule_controller.dart';
import 'package:wealthnx/controller/signup/signup_controller.dart';
import 'package:wealthnx/controller/splach/splach_controller.dart';
import 'package:wealthnx/controller/transations/transations_controller.dart';
import 'package:wealthnx/controller/vitals/vitals_controller.dart';
import 'package:wealthnx/controller/wealth_genie/wealth_genie_controller.dart';
import 'package:wealthnx/providers/user_provider.dart';

class ControllersBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core App Controllers (persistent, use fenix: true)
    _registerCoreControllers();

    // 2. Auth Flow Controllers (disposable)
    _registerAuthControllers();

    // 3. Main Feature Controllers
    _registerMainFeatureControllers();

    // 3.5 Vitals-related Controllers
    _registerVitalsControllers();

    // 4. Investment-related Controllers
    _registerInvestmentControllers();

    // 5. Financial Operation Controllers (route-specific)
    _registerFinancialControllers();

    // 6. News Controllers
    _registerNewsControllers();

    // 7. Provider
    Get.lazyPut<UserProvider>(() => UserProvider(), fenix: true);

    // 8. Check Plaid Connectivity
    Get.lazyPut<CheckPlaidConnectionController>(
        () => CheckPlaidConnectionController(),
        fenix: true);

    //9 Schedule Controller
    Get.lazyPut<ScheduleController>(() => ScheduleController(), fenix: true);

    // 10 NetWorth Controller
    Get.lazyPut<NetWorthController>(() => NetWorthController(), fenix: true);

    Get.lazyPut<ExpensesController>(() => ExpensesController(), fenix: true);
  }

  void _registerCoreControllers() {
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    // Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CustomDrawerController>(() => CustomDrawerController(),
        fenix: true);
  }

  void _registerAuthControllers() {
    Get.lazyPut<OnboadingController>(() => OnboadingController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);
  }

  void _registerMainFeatureControllers() {
    Get.lazyPut<WealthGenieController>(() => WealthGenieController(),
        fenix: true);
    Get.lazyPut<TransactionsController>(() => TransactionsController(),
        fenix: true);
    // Get.lazyPut<NetWorthController>(() => NetWorthController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }

  void _registerInvestmentControllers() {
    Get.lazyPut<InvestmentController>(() => InvestmentController(),
        fenix: true);
    Get.lazyPut<CoinsListController>(() => CoinsListController(), fenix: true);
    Get.lazyPut<DetailListStockController>(() => DetailListStockController(),
        fenix: true);
    Get.lazyPut<MarketCoinController>(() => MarketCoinController(),
        fenix: true);
    Get.lazyPut<CryptoDetailInfoController>(() => CryptoDetailInfoController(),
        fenix: true);
    Get.lazyPut<OverviewController>(() => OverviewController(), fenix: true);
    // Get.lazyPut<MergeStockController>(() => MergeStockController());
  }

  void _registerVitalsControllers() {
    Get.lazyPut<NetWorthController>(() => NetWorthController(), fenix: true);
    Get.lazyPut<VitalsController>(() => VitalsController(), fenix: true);
    Get.lazyPut<BudgetController>(() => BudgetController(), fenix: true);
    Get.lazyPut<IncomeController>(() => IncomeController(), fenix: true);
    Get.lazyPut<ExpensesController>(() => ExpensesController(), fenix: true);
    Get.lazyPut<CashFlowController>(() => CashFlowController(), fenix: true);
  }

  void _registerFinancialControllers() {
    Get.lazyPut<AddExpensesController>(() => AddExpensesController());
    Get.lazyPut<IncomeAddedController>(() => IncomeAddedController());
    Get.lazyPut<ConnectAccountsController>(() => ConnectAccountsController());
  }

  void _registerNewsControllers() {
    Get.lazyPut<NewsController>(() => NewsController(), fenix: true);
    Get.lazyPut<PressReleaseNewsController>(() => PressReleaseNewsController(),
        fenix: true);
  }
}
