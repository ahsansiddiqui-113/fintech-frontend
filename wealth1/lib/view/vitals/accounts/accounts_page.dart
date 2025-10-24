import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/connect_account/account_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  String selectedTab = 'All';

  final AccountController controller = Get.put(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
          title: 'Accounts',
          onBackPressed: () {
            Get.find<CheckPlaidConnectionController>().checkConnection();
            // Get.find<TransactionsController>().fetchTransations();
            // Get.find<InvestmentController>().fetchInvestmentOverview();
            // Get.put(NetWorthController()).fetchNetWorth();
            Get.put(HomeController()).fetchExpenseCategories();
            // Get.put(HomeController()).fetchTodaySchedules();

            Get.back();
          }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation tabs
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
            child: Container(
              // color: Colors.amber,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.4))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab('All'),
                  _buildTab('Banks /Credit Card'),
                  _buildTab('Investments'),
                ],
              ),
            ),
          ),

          // ----------- Main Selected Tab -----------
          Expanded(
              child: Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : (controller.accountResponse.value?.body == null)
                      ? Center(child: Text('No Accounts Found'))
                      : (selectedTab == 'All'
                          ? buildAllAccounts()
                          : selectedTab == 'Banks /Credit Card'
                              ? buildBankAccounts()
                              : selectedTab == 'Investments'
                                  ? _buildInvestmentAccounts()
                                  : Center(child: Text("Coming Soon"))))),
        ],
      ),
      bottomNavigationBar: buildAddButton(
        title: 'Add Account',
        onPressed: () {
          Get.to(() => ConnectAccounts());
        },
      ),
    );
  }

  Widget buildAllAccounts() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 10),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text('No accounts found'));

          // Center(child: Text(controller.errorMessage.value));
        } else if (controller.accountResponse.value != null) {
          return ListView.builder(
            itemCount: controller.accountResponse.value?.body.length,
            itemBuilder: (context, index) {
              final account = controller.accountResponse.value?.body[index];
              return buildIncomeDetailItem(
                  context,
                  index: index,
                  title: '${account?.bankName}',
                  amount: '${account?.total}',
                  length: controller.accountResponse.value?.body.length,
                  subtitle:
                      '...${account?.accountNumber.substring(0, 4)} ${account?.subtype}',
                  persentage: '',
                  icon: (account?.bankLogo?.toString() == 'null' ||
                          account?.bankLogo?.toString() == null)
                      ? ImagePaths.expensewallet
                      : AppEndpoints.profileBaseUrl + '${account?.bankLogo}');
            },
          );
        } else {
          return const Center(child: Text('No accounts found'));
        }
      }),
    );
  }

  Widget buildBankAccounts() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SectionName(
              title: 'Banks',
              titleOnTap: '',
              onTap: () {},
            ),
            addHeight(12),
            SizedBox(
              height: 195,
              child: ListView.builder(
                itemCount: controller.accountResponse.value?.body.length,
                itemBuilder: (context, index) {
                  final account = controller.accountResponse.value?.body[index];
                  if (account?.type == 'Bank') {
                    return buildIncomeDetailItem(
                        context,
                        index: index,
                        title: '${account?.bankName}',
                        amount: '${account?.total}',
                        length: controller.accountResponse.value?.body.length,
                        subtitle:
                            '...${account?.accountNumber.substring(0, 4)} ${account?.subtype}',
                        persentage: '',
                        icon: (account?.bankLogo?.toString() == 'null' ||
                                account?.bankLogo?.toString() == null)
                            ? ImagePaths.expensewallet
                            : AppEndpoints.profileBaseUrl +
                                '${account?.bankLogo}');
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            addHeight(21),
            SectionName(
              title: 'Loan',
              titleOnTap: '',
              onTap: () {},
            ),
            addHeight(12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: controller.accountResponse.value?.body.length,
                itemBuilder: (context, index) {
                  final account = controller.accountResponse.value?.body[index];
                  if (account?.type == 'Loan') {
                    return buildIncomeDetailItem(
                        context,
                        index: index,
                        title: '${account?.bankName}',
                        amount: '${account?.total}',
                        length: controller.accountResponse.value?.body.length,
                        subtitle:
                            '...${account?.accountNumber.substring(0, 4)} ${account?.subtype}',
                        persentage: '',
                        icon: (account?.bankLogo?.toString() == 'null' ||
                                account?.bankLogo?.toString() == null)
                            ? ImagePaths.expensewallet
                            : AppEndpoints.profileBaseUrl +
                                '${account?.bankLogo}');
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            addHeight(21),
            SectionName(
              title: 'Credit Card',
              titleOnTap: '',
              onTap: () {},
            ),
            addHeight(12),
            SizedBox(
              height: 195,
              child: ListView.builder(
                itemCount: controller.accountResponse.value?.body.length,
                itemBuilder: (context, index) {
                  final account = controller.accountResponse.value?.body[index];
                  if (account?.type == 'Credit') {
                    return buildIncomeDetailItem(
                      context,
                        index: index,
                        title: '${account?.bankName}',
                        amount: '${account?.total}',
                        length: controller.accountResponse.value?.body.length,
                        subtitle:
                            '...${account?.accountNumber.substring(0, 4)} ${account?.subtype}',
                        persentage: '',
                        icon: (account?.bankLogo?.toString() == 'null' ||
                                account?.bankLogo?.toString() == null)
                            ? ImagePaths.expensewallet
                            : AppEndpoints.profileBaseUrl +
                                '${account?.bankLogo}');
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentAccounts() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 10),
      child: Column(
        children: [
          SectionName(
            title: 'Crypto & Stocks ',
            titleOnTap: '',
            onTap: () {},
          ),
          addHeight(12),
          addHeight(12),
          SizedBox(
            height: 195,
            child: ListView.builder(
              itemCount: controller.accountResponse.value?.body.length,
              itemBuilder: (context, index) {
                final account = controller.accountResponse.value?.body[index];
                if (account?.type == 'Investment') {
                  return buildIncomeDetailItem(
                    context,
                      index: index,
                      title: '${account?.bankName}',
                      amount: '${account?.total}',
                      length: controller.accountResponse.value?.body.length,
                      subtitle:
                          '...${account?.accountNumber.substring(0, 4)} ${account?.subtype}',
                      persentage: '',
                      icon: (account?.bankLogo?.toString() == 'null' ||
                              account?.bankLogo?.toString() == null)
                          ? ImagePaths.expensewallet
                          : AppEndpoints.profileBaseUrl +
                              '${account?.bankLogo}');
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isSelected ? Colors.white : Colors.transparent))),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
