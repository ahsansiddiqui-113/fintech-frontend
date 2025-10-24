import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/dashboard/dashboard_controller.dart';
import 'package:wealthnx/controller/expenses/expenses_controller.dart';
import 'package:wealthnx/controller/home/home_controller.dart';
import 'package:wealthnx/controller/networth/networth_controller.dart';
import 'package:wealthnx/controller/notification/notification_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_info.dart';
import 'package:wealthnx/view/vitals/vitals.dart';
import 'package:wealthnx/home-screens/wealth_genie.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/view/dashboard/home/home.dart';

import 'drawer/drawer.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});
  static final List<Widget> _widgetOptions = <Widget>[
    Home(),
    WealthGenieView(),
    VitalsScreen(),
    InvestmentInfo(),
  ];

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final connectivityController = Get.find<CheckPlaidConnectionController>();
  final ExpensesController _expenseController = Get.put(ExpensesController());
  final NetWorthController _networthController = Get.put(NetWorthController());
  final HomeController _homeController = Get.put(HomeController());
  final DashboardController _dashboardController =
      Get.put(DashboardController());

  final CommonController _commonController = Get.put(CommonController());
  final NotificationController notificationController = Get.put(NotificationController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int currentIndex = _dashboardController.selectedIndex.value;
      return Scaffold(
        drawer: CustomDrawer(),
        body: Dashboard._widgetOptions[currentIndex],
        bottomNavigationBar:currentIndex == 0 ? null: Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: context.gc(AppColor.black)),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.gc(AppColor.black), width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
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
            ),
          ),
        ),
      );
    });
  }
}
