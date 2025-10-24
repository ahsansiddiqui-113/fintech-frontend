import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/home-screens/wealth_genie_screens/agent_detail_queries.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ExploreAgents extends StatelessWidget {
  ExploreAgents({super.key});

  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: 'Explore Agents',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addHeight(),
              // Grid Cards (2x2)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                        context,
                        'Accountant Agent',
                        'Accounts Overview',
                        ImagePaths.wg7,
                        ImagePaths.notaccountant),
                    _buildFeatureCard(
                        context,
                        'Stock Agent',
                        'Stock Market Overview',
                        ImagePaths.wg3,
                        ImagePaths.notstocks),
                    _buildFeatureCard(
                        context,
                        'Crypto Agent',
                        'Crypto Overview',
                        ImagePaths.wg6,
                        ImagePaths.notcryptos),
                    _buildFeatureCard(context, 'Build Mode', 'Text to visuals',
                        ImagePaths.wg8, ImagePaths.buildMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle,
      String icon, String notconicon) {
    return GestureDetector(
      onTap: () {
        _messageController.text = title;
        if (_messageController.text == title) {
          Get.to(() => AgentDetailQueries(
                title: '${_messageController.text}',
              ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: context.gc(AppColor.black),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
            image: DecorationImage(image: AssetImage(ImagePaths.exploreback))),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              icon,
              color: Colors.white,
              fit: BoxFit.contain,
              width: 24,
              height: 24,
            ),
            Spacer(),
            textWidget(context,
                title: title, fontSize: 14, fontWeight: FontWeight.w500),
            addHeight(5),
            textWidget(context,
                title: subtitle, fontSize: 10, fontWeight: FontWeight.w400),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  notconicon,
                  // color: Colors.white,
                  fit: BoxFit.contain,
                  width: title == 'Build Mode' ? 100 : 65,
                  // height: 60,
                ),
                Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 30,
                  color: Colors.grey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
