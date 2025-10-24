import 'package:flutter/material.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/coins_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/my_portfolio_screen.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/other_your_investment.dart';
import 'package:wealthnx/view/vitals/investment/widgets/crypto_list_section.dart';
import 'package:wealthnx/view/vitals/investment/widgets/historical_graph.dart';
import 'package:wealthnx/view/vitals/investment/widgets/my_portfolio.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';

class OtherTabs extends StatefulWidget {
  const OtherTabs({super.key});

  @override
  State<OtherTabs> createState() => _OtherTabsState();
}

class _OtherTabsState extends State<OtherTabs> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          //------ Stock Section ------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Others Investments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '+21%(24h)',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // SizedBox(height: 20),

          //------ Graph Section ------

          HistoricalGarph(),
          SizedBox(height: 20),

          //------Other List Section ------

          SectionName(
            title: 'Your Investments',
            titleOnTap: 'View All',
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => CoinsScreen()),
              // );
            },
          ),
          const SizedBox(height: 16),
          OtherYourInvestment(),

          SizedBox(height: 20),

          //------Btn Section ------

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => ExpensesInfo()),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add Investment',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
