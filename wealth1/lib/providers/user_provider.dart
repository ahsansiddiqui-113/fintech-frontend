import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config_loader.dart';

class UserProvider extends GetxController {
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final RxString _token = ''.obs;
  final RxString _baseUrl = ''.obs;
  final RxString _plaidBaseUrl = ''.obs;

  UserModel? get user => _user.value;

  String? get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    _loadConfig();
    _loadUserId();
  }

  Future<void> _loadConfig() async {
    final config = await loadConfig();
    _baseUrl.value = config['BASE_URL'] ?? '';
    _plaidBaseUrl.value = config['PLAID_BASE_URL'] ?? '';
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('auth_token');
    if (userId != null) {
      _user.value =
          UserModel(id: userId, fullName: '', email: '', token: '${token}');
    }
  }

  Future<void> logout() async {
    _token.value = '';
    _user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('auth_token');
    await prefs.remove('isLoggedIn');
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.token,
  });
}
