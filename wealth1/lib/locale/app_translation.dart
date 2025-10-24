import 'package:get/get.dart';
import 'english.dart';
import 'arabic.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': english(),
        'ar': arabic(),
      };
}
