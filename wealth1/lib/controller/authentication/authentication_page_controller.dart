import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/utils/app_helper.dart';

class AuthenticationPageController extends GetxController {
  var faceIdEnabled = false.obs;
  var fingerprintEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBiometricStatus();
  }

  void toggleFaceId(bool value) async {
    faceIdEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      // Enable biometric storage
      final userId = prefs.getString('userId');
      final email = prefs.getString('email');
      final password = prefs.getString('password');
      // final bioUserId = prefs.getString('bioUserId');
      // final bioEmail = prefs.getString('bioEmail');
      // final bioPassword = prefs.getString('bioPassword');

      if (userId != null && email != null && password != null) {
        await prefs.setString('bioUserId', userId);
        await prefs.setString('bioEmail', email);
        await prefs.setString('bioPassword', password);
        showToast('Biometric Enabled');
      }
    } else {
      // Disable biometric storage
      await prefs.remove('bioUserId');
      await prefs.remove('bioEmail');
      await prefs.remove('bioPassword');
      showToast('Biometric Disabled');
    }
  }

  void toggleFingerprint(bool value) {
    fingerprintEnabled.value = value;
  }

  Future<void> loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final bioUserId = prefs.getString('bioUserId');
    final bioEmail = prefs.getString('bioEmail');
    final bioPassword = prefs.getString('bioPassword');

    print('Print UserId: $userId');
    print('Print BioUserId: $bioUserId');
    print('Print Email: $bioEmail');
    print('Print Password: $bioPassword');

    faceIdEnabled.value =
        ((bioUserId != null && bioUserId.isNotEmpty) && bioUserId == userId);
  }
}
