import 'package:get/get.dart';
import 'package:wealthnx/controller/cashflow/cashflow_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/models/bank_list/bank_list.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/budget/budget_page.dart';
import 'package:wealthnx/view/vitals/cash_flow/cash_flow.dart';
import 'package:wealthnx/view/vitals/income/income.dart';
import 'package:wealthnx/view/vitals/expenses/expenses.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/networth/networth.dart';
import 'package:wealthnx/view/vitals/transations/transactions.dart';

import '../../base_client/base_client.dart';

class VitalsController extends GetxController {
  var isLoading = false.obs;
  var bankTotals = <BankInstitution>[].obs;

  final RxBool hasFetchedBankList = false.obs;

  final List<Map<String, dynamic>> categories = [
    {'title': 'Net Worth', 'icon': ImagePaths.dollar},
    {'title': 'Cash Flow', 'icon': ImagePaths.banknote},
    {'title': 'Income', 'icon': ImagePaths.profit},
    {'title': 'Expense', 'icon': ImagePaths.calculator},
    {'title': 'Transactions', 'icon': ImagePaths.capital},
    {'title': 'Budget', 'icon': ImagePaths.assetM},
    // {'title': 'Accounts', 'icon': ImagePaths.wallet},
  ];

  void handleCategoryTap(String title,) {
    switch (title) {
      case 'Net Worth':
        Get.find<NetWorthController>().totalSpend.value =
            Get.find<NetWorthController>().networth.value?.body?.totalNetWorth ?? 0;
        Get.to(() => NetWorth());
        break;
      case 'Cash Flow':
        Get.find<CashFlowController>().totalCashFlowAmount.value =
            Get.find<CashFlowController>().cashflow.value?.body?.cashflow ?? 0;
        Get.to(() => CashFlowScreen());
        break;
      case 'Income':
        Get.find<IncomeController>().totalIncomeAmount.value =
            Get.find<IncomeController>().income.value?.body?.totalIncomeAmount ?? 0;
        Get.to(() => IncomeScreen());
        break;
      case 'Expense':
        Get.find<ExpensesController>().totalExpenceAmount.value =
            Get.find<ExpensesController>().expense.value?.body?.totalExpense ?? 0;
        Get.to(() => ExpensesPage());
        break;
      case 'Transactions':
        Get.to(() => TransactionsPage());
        break;
      case 'Budget':
        Get.to(() => BudgetPage());
        break;

      // case 'Accounts':
      //   Get.to(() => ConnectAccounts());
      //   break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchBankTotals();
  }

  Future<void> fetchBankTotals() async {
    // if (hasFetchedBankList.value && !force) return;

    try {
      isLoading(true);

      final response = await BaseClient().get('${AppEndpoints.bankList}');

      print('Response Bank: ${response}');

      if (response != null) {
        final data = BankTotalsResponse.fromJson(response);
        bankTotals.assignAll(data.body);
      }
    } catch (e) {
      print("Error fetching bank totals: $e");
    } finally {
      isLoading(false);
    }
  }
}
