import 'package:get/get.dart';

class ToggleBtnController extends GetxController {
  var isDemo = true.obs; // default selected

  void toggle(bool demoSelected) {
    isDemo.value = demoSelected;
  }
}
