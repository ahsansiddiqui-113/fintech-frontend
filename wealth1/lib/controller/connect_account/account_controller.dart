import 'package:get/get.dart';
import 'package:wealthnx/models/account/accounts_model.dart';

import '../../base_client/base_client.dart';
import '../../utils/app_urls.dart';

class AccountController extends GetxController {
  var isLoading = true.obs;
  var accountResponse = Rx<AccountResponse?>(null);
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    try {
      isLoading(true);

      final response = await BaseClient().get(AppEndpoints.accounts);

      if (response != null) {
        accountResponse.value = AccountResponse.fromJson(response);
        errorMessage.value = '';
      } else {
        errorMessage.value = 'Failed to load accounts: ${response.statusCode}';
        Get.snackbar("Error", errorMessage.value.toString());

      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading(false);
    }
  }

}
