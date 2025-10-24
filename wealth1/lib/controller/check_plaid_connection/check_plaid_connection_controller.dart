import 'dart:developer';

import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/utils/app_urls.dart';

class CheckPlaidConnectionController extends GetxController {
  /// Reactive states
  final isConnected = RxnBool();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
  }

  /// Check Plaid connection
  Future<void> checkConnection() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await BaseClient().get(AppEndpoints.connectedStatus);
      if (response == null) {
        isConnected.value = null;
        errorMessage.value = "No response from server";
        return;
      }

      if (response['status'] == true) {
        final body = response['body'];
        if (body != null && body['isPlaidConnected'] != null) {
          isConnected.value = body['isPlaidConnected'] == true;
        } else {
          isConnected.value = null;
          errorMessage.value = "Missing Plaid connection data";
        }
      } else {
        isConnected.value = false;
        errorMessage.value = response['message'] ?? "Unknown error";
      }
    } catch (e) {
      isConnected.value = false;
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
