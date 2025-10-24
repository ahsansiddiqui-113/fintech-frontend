import 'package:get/get.dart';
import 'package:wealthnx/models/investment/investment_overview_model.dart';

class StocksController extends GetxController {
  final Rx<InvestmentOverview?> investmentOverview =
      Rx<InvestmentOverview?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }
}
