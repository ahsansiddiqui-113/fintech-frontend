import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wealthnx/config_loader.dart';
import 'package:wealthnx/view/vitals/accounts/connect_accounts.dart';
import 'package:wealthnx/utils/app_urls.dart';

class ConnectAccountsController extends GetxController {
  final TextEditingController phoneNumberController = TextEditingController();
  final errorMessage = ''.obs;
  final phoneNumber = ''.obs;
  final hasPlaidConnection = false.obs;
  final isLoading = false.obs;

  String? _baseUrl;
  String? _plaidBaseUrl;

  @override
  void onInit() async {
    super.onInit();

    WakelockPlus.enable();

    await loadConfigData();
  }

  @override
  void onClose() {
    WakelockPlus.disable(); // ✅ Allow normal screen timeout when leaving

    super.onClose();
  }

  Future<void> loadConfigData() async {
    try {
      final config = await loadConfig();
      _baseUrl = config['BASE_URL'] ??
          "https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net";
      _plaidBaseUrl = config['PLAID_BASE_URL'];
      print('Config loaded: BASE_URL=$_baseUrl, PLAID_BASE_URL=$_plaidBaseUrl');
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  Future<void> openPlaidLogin() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final userId = prefs.getString('userId');

      if (authToken == null || authToken.isEmpty) {
        Get.snackbar('Error', 'Please log in to connect your bank account');
        return;
      }

      final url = AppEndpoints.baseUrl + 'link-token';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String linkToken = data['body']['link_token'];

        await prefs.setString('plaid_link_token', linkToken);
        if (userId != null) {
          await prefs.setString('user_id', userId);
        }
        await prefs.setString('auth_token', authToken);
        await prefs.setInt(
            'plaid_token_timestamp', DateTime.now().millisecondsSinceEpoch);

        final redirectUrl = 'https://www.google.com';
        final encodedRedirectUrl = Uri.encodeComponent(redirectUrl);
        final plaidUrl =
            'https://cdn.plaid.com/link/v2/stable/link.html?token=$linkToken&redirect_uri=$encodedRedirectUrl';

        print('Plaid Open url: ${plaidUrl}');

        if (await canLaunchUrl(Uri.parse(plaidUrl))) {
          print('Plaid Check 1');
          _setupAppResumeListener(authToken);
          await launchUrl(Uri.parse(plaidUrl),
              mode: LaunchMode.inAppBrowserView);
          Get.snackbar('Success', 'Bank connection process initiated');
          await prefs.setBool('plaid_process_active', true);
          await _createSandboxPublicToken(authToken);
        } else {
          Get.snackbar('Error', 'Could not open bank connection page');
        }
      } else {
        Get.snackbar('Error', 'Failed to connect: ${response.statusCode}');
      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred: $error');
    } finally {
      isLoading(false);
    }
  }

  void _setupAppResumeListener(String authToken) {
    WidgetsBinding.instance.addObserver(AppResumeObserver(
      onResume: () async {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('plaid_process_active') ?? false) {
          final publicToken = prefs.getString('plaid_public_token');
          if (publicToken != null && publicToken.isNotEmpty) {
            await _exchangePublicToken(publicToken, authToken);
          }
        }
      },
    ));
  }

  Future<void> _createSandboxPublicToken(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final linkToken = prefs.getString('plaid_link_token');
      print('Step 2:');
      print('Auth Token : ${authToken}');
      print('Link Token : ${linkToken}');
      // if (linkToken == null) return;

      final url = AppEndpoints.baseUrl + 'create-identity';

      print('Url : ${url}');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'link_token': linkToken}),
      );

      print('Responce: ${response.body}');

      if (response.statusCode == 200) {
        print('Plaid Check 2');
        final data = jsonDecode(response.body);
        final publicToken = data['body']['public_token'];

        prefs.setString('plaid_public_token', publicToken);
        _exchangePublicToken(publicToken, authToken);
        // print('Data : ${data}');
        // print('public token : ${publicToken}');
      }
    } catch (e) {
      print('Error creating sandbox token: $e');
    }
  }

  Future<void> _exchangePublicToken(
      String publicToken, String authToken) async {
    try {
      final url = AppEndpoints.baseUrl + 'exchange-token';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'public_token': publicToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'plaid_access_token', data['body']['access_token']);
        await prefs.setString('plaid_item_id', data['body']['item_id']);
        await prefs.setBool('plaid_process_active', false);
        await prefs.setBool('plaid_connection_successful', true);

        print('Responce : ${data}');

        hasPlaidConnection(true);
        await _fetchTransactions(authToken, data['body']['item_id']);
      }
    } catch (e) {
      print('Error exchanging token: $e');
    }
  }

  Future<void> _fetchTransactions(String authToken, String? itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final accessToken = prefs.getString('plaid_access_token');
      if (userId == null || accessToken == null) return;

      final url = AppEndpoints.baseUrl + '$userId/transactions';
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': accessToken,
          'start_date':
              "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
          'end_date':
              "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = data['body']['transactions'] ?? [];
        await prefs.setString(
            'last_transactions_fetch', DateTime.now().toIso8601String());
        Get.snackbar('Success', 'Loaded ${transactions.length} transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }
}
