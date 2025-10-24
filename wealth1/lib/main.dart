import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:wealthnx/controller/controller_binding.dart';
import 'package:wealthnx/firebase_options.dart';
import 'package:wealthnx/view/schedule/schedule_screen.dart';
import 'package:wealthnx/view/vitals/transations/transactions.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/budget/budget_page.dart';
import 'package:wealthnx/view/vitals/cash_flow/cash_flow.dart';
import 'package:wealthnx/view/vitals/income/income.dart';
import 'package:wealthnx/view/vitals/expenses/expenses.dart';
import 'package:wealthnx/view/vitals/networth/networth.dart';
import 'package:wealthnx/locale/app_translation.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';
import 'package:wealthnx/login-pages/signup_page.dart';
import 'package:wealthnx/view/splach/splash_screen.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_constant.dart';
import 'package:wealthnx/utils/app_screens.dart';
import 'package:wealthnx/view/dashboard/dashboard.dart';
import 'package:wealthnx/view/onboading_screen/onboading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetSecureStorage.init(password: AppConstant.dbSecurityKey);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MyApp(),
      //  DevicePreview(
      //    enabled: !kReleaseMode,
      //    builder: (context) => MyApp(), // Wrap your app
      //  ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstant.appName,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      // useInheritedMediaQuery: true,
      // builder: DevicePreview.appBuilder,
      locale: Get.deviceLocale,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          // Customize other text styles
        ),
      ),
      darkTheme: CustomAppTheme.darkTheme,
      fallbackLocale: const Locale('en'),
      initialBinding: ControllersBinding(),
      initialRoute: AppScreens.splach,
      getPages: [
        // GetPage(name: AppScreens.splach, page: () => SignInDemo()),
        GetPage(name: AppScreens.splach, page: () => SplashScreen()),
        GetPage(name: AppScreens.onboarding, page: () => OnBoardingScreen()),
        GetPage(name: AppScreens.login, page: () => LoginPage()),
        GetPage(name: AppScreens.signup, page: () => SignupPage()),
        GetPage(name: AppScreens.dashboard, page: () => Dashboard()),
        GetPage(name: AppScreens.networth, page: () => NetWorth()),
        GetPage(name: AppScreens.cashflow, page: () => CashFlowScreen()),
        GetPage(name: AppScreens.income, page: () => IncomeScreen()),
        GetPage(name: AppScreens.transaction, page: () => TransactionsPage()),
        GetPage(name: AppScreens.budget, page: () => BudgetPage()),
        GetPage(name: AppScreens.expense, page: () => ExpensesPage()),
        GetPage(name: AppScreens.accounts, page: () => ConnectAccounts()),
        GetPage(name: AppScreens.schedule, page: () => ScheduleScreen()),
      ],
    );
  }
}
