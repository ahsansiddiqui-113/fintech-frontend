import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/connect_account/account_controller.dart';
import 'package:wealthnx/controller/connect_account/connect_account_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/controller/investment/investment_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/controller/transations/transations_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ConnectAccounts extends StatelessWidget {
  final ConnectAccountsController controller =
      Get.put(ConnectAccountsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Connect Account',
          onBackPressed: () {
            Get.find<CheckPlaidConnectionController>().checkConnection();
            Get.put(NetWorthController()).fetchNetWorth();
            Get.find<TransactionsController>().fetchTransations();
            Get.find<InvestmentController>().fetchInvestmentOverview();
            Get.find<ExpensesController>().fetchExpense();
            Get.find<BudgetController>().fetchBudgets();
            Get.find<IncomeController>().fetchIncome();
            Get.find<InvestmentController>().fetchInvestmentOverview();
            Get.put(AccountController()).fetchAccounts();
            Get.put(HomeController()).fetchExpenseCategories();

            Get.back();
          }),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(ImagePaths.appblogo, width: 100, height: 100),
            ),
            const SizedBox(height: 5),
            const Text(
              'Connect External Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Connect your financial accounts securely to get a complete view of your cash flow, investments, and financial health in one place.',
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.openPlaidLogin(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continue',
                            style: TextStyle(color: Colors.white)),
                  ),
                )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.find<TransactionsController>().fetchTransations();
                Get.find<InvestmentController>().fetchInvestmentOverview();
                Get.put(NetWorthController()).fetchNetWorth();
              },
              child: const Text('Skip', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AppResumeObserver extends WidgetsBindingObserver {
  final Function onResume;

  AppResumeObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
