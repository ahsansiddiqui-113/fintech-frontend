import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/controller/wealth_genie/wealth_genie_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AgentDetailQueries extends StatelessWidget {
  AgentDetailQueries({super.key, this.title});

  String? title;

  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  final WealthGenieController _genieController =
      Get.find<WealthGenieController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: '$title',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title == 'Accountant Agent') ...[
                agentsExplore(
                  context,
                  agentType: 'Accountant',
                  title:
                      'Organizes your budgets, expenses, debts, and cashflows automatically turning every transaction into insights that make your money work smarter.',
                  sug1: 'How much money do I need to retire comfortably?',
                  sug2:
                      'What percentage of my income should go to rent/mortgage?',
                  sug3: 'Should I pay off debt or save/invest first?',
                  sug4: 'What’s the best way to consolidate debt?',
                  sug5: 'How does my credit score affect me?',
                )
              ] else if (title == 'Stock Agent') ...[
                agentsExplore(
                  context,
                  agentType: 'Stock',
                  title:
                      'Analyzes any stock in seconds: fundamentals, technicals, valuation, risk, news, and momentum then explains the “why” in plain English with charts.',
                  sug1:
                      'Will investing in ETF result in low income and I will loose better opportunities as compared to investing in stocks or crypto?',
                  sug2: 'How do I evaluate a stock before buying it?',
                  sug3:
                      'Are dividend paying stocks better than non-dvidend paying ones?',
                  sug4:
                      'What’s the difference between growth stocks and value stocks?',
                  sug5: 'How to protect myself from sharp market drawdowns?',
                )
              ] else if (title == 'Crypto Agent') ...[
                agentsExplore(
                  context,
                  agentType: 'Crypto',
                  title:
                      'Tracks coins, tokens, and DeFi trends in real time analyzing volatility, sentiment, and on chain signals so you always know what’s driving your crypto performance.',
                  sug1:
                      'How is crypto different from traditional money (fiat)?',
                  sug2: 'How do I buy cryptocurrency?',
                  sug3: 'What is a crypto wallet, and how does it work?',
                  sug4: 'How much should I invest in crypto?',
                  sug5: 'What are altcoins and meme coins?',
                )
              ] else if (title == 'Build Mode') ...[
                agentsExplore(
                  context,
                  agentType: 'Build Mode',
                  title:
                      'Transforms your ideas into interactive dashboards, visual mind maps, or data pages instantly no code, just creativity powered by intelligence.',
                  sug1: 'Please help me visualize my portfolio as a dashboard',
                  sug2: 'Please analyse XRP',
                  sug3: 'Give me a minichart for Apple',
                  sug4: 'Give me a mind map of my financial investments',
                  sug5: 'Give me a mind map of my investment',
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget agentsExplore(BuildContext context,
      {title, agentType, sug1, sug2, sug3, sug4, sug5}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(context,
            title: title, fontSize: 12, fontWeight: FontWeight.w400),
        addHeight(30),
        textWidget(context,
            title: 'Suggestions',
            fontSize: 14,
            color: context.gc(AppColor.grey),
            fontWeight: FontWeight.w400),
        addHeight(14),
        _buildFeatureCard(context, sug1, agentType: agentType),
        addHeight(14),
        _buildFeatureCard(context, sug2, agentType: agentType),
        addHeight(14),
        _buildFeatureCard(context, sug3, agentType: agentType),
        addHeight(14),
        _buildFeatureCard(context, sug4, agentType: agentType),
        addHeight(14),
        _buildFeatureCard(context, sug5, agentType: agentType),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, {agentType}) {
    return GestureDetector(
      onTap: () async {
        _messageController.text = title;

        Get.back();
        Get.back();
        Get.back();

        _genieController.clearHistory();
        _genieController.sessionMsgId.value =
            _genieController.generateSessionId();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'newSessionId', _genieController.sessionMsgId.value);

        _genieController.messageController.text =
            "@" + agentType + " " + '$title';
        _genieController.handleMessageSubmit();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 13, 12),
              Color.fromARGB(255, 5, 13, 12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: textWidget(context,
            title: title, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}
