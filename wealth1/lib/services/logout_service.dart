import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';

class LogoutService {
  final BaseClient _baseClient = BaseClient();

  Future<void> performLogout() async {
    try {
      await _baseClient.post("${AppEndpoints.logOut}",
        {},
        skipUnauthorizedHandling: true,
        isCustom: true,
      );
    } catch (e) {
      await _clearLocalData();
      Get.offAll(() => LoginPage());
    }
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}