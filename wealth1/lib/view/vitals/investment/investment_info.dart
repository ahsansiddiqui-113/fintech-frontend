import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/services/crypto_news_services.dart';
import 'package:wealthnx/utils/app_helper.dart';

import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto_tab.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/overview_tab.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stocks_tab.dart';
import 'package:wealthnx/view/vitals/investment/widgets/investment_search.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class InvestmentInfo extends StatefulWidget {
  const InvestmentInfo({super.key});

  @override
  _InvestmentInfoState createState() => _InvestmentInfoState();
}

class _InvestmentInfoState extends State<InvestmentInfo> {
  String selectedTab = 'Overview';

  final connectivityController = Get.find<CheckPlaidConnectionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
        title: 'Investments',
        automaticallyImplyLeading: true,
        actions: [
          if (connectivityController.isConnected.value == false) ...[
            toggleBtnDemoReal(context)
          ] else ...[
            Container(
              margin: EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => InvestmentSearch());
                },
                child: Icon(Icons.search),
              ),
            ),
          ],
        ],
      ),
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
                  _buildTab('Overview'),
                  _buildTab('Crypto'),
                  _buildTab('Stocks'),
                  // SizedBox(width: 10),
                  // _buildTab('Funds'),
                  // SizedBox(width: 10),
                  // _buildTab('Other'),
                ],
              ),
            ),
          ),
          // SizedBox(height: 20),

          // ----------- Main Selected Tab -----------
          Expanded(
              child: selectedTab == 'Overview'
                  ? OverviewTab()
                  : selectedTab == 'Crypto'
                      ? CryptoTab()
                      : selectedTab == 'Stocks'
                          ? StocksTab()
                          : Center(child: Text("Coming Soon"))),
        ],
      ),
    );
  }

// ---------- Tabs ---------
  Widget _buildTab(String title) {
    bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
          cryptoType = title;
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
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

//-----------
}
