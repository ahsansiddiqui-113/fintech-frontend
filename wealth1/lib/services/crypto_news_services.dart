import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/models/investment/crypto_investment/crypto_news_model.dart';
import 'package:wealthnx/models/net_worth/net_worth';
import 'package:wealthnx/utils/app_urls.dart';

import '../models/expense/expense_category.dart';
import '../models/investment/investment_overview_model.dart';

String cryptoType = 'Crypto';

class ApiService {
  Future<List<CryptoNewsModel>> fetchNews(
      {required String newsId, required bool crypto}) async {
    try {
      final response = await http
          .get(Uri.parse(
              '${crypto == true ? AppEndpoints.cryptoNews : AppEndpoints.stockNews}$newsId${AppEndpoints.cryptoNewsApikey}'))
          .timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      print(response.request);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => CryptoNewsModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load news: ${response.statusCode}');
        return [];
        // throw HttpException('Failed to load news: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection : $e');
      return [];
      // throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      debugPrint('HttpException error: $e');
      return [];
      // throw Exception('HTTP error: $e');
    } on FormatException catch (e) {
      debugPrint('FormatException error: $e');
      return [];
      // throw Exception('Invalid response format: $e');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return [];
      // throw Exception('Unexpected error: $e');
    }
  }

  // general news api calling
  Future<List<CryptoNewsModel>> fetchGeneralNewsWithPagination(
      {int page = 0, int limit = 10}) async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://financialmodelingprep.com/stable/news/general-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => CryptoNewsModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load news: ${response.statusCode}');
        return [];
        // throw HttpException('Failed to load news: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint('No internet connection');
      return [];
      // throw Exception('No internet connection');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return [];
      // throw Exception('Unexpected error: $e');
    }
  }

  // press realse aapi call
  // In ApiService class
  Future<List<CryptoNewsModel>> fetchPressReleaseNewsWithPagination({
    int page = 0,
    int limit = 10,
    required String cryptoType, // 'Stocks' | 'Crypto'
  }) async {
    String apiUrl;

    if (cryptoType == 'Crypto') {
      apiUrl =
          'https://financialmodelingprep.com/stable/news/crypto-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}';
    } else {
      // default to Stocks
      apiUrl =
          'https://financialmodelingprep.com/stable/news/stock-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}';
    }

    // log
    // print('Final News API: $apiUrl');

    try {
      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => CryptoNewsModel.fromJson(e)).toList();
      } else {
        throw HttpException('Failed to load news: ${response.statusCode}');
      }
    } on SocketException {
      return [];
    } catch (_) {
      return [];
    }
  }

  // Future<List<CryptoNewsModel>> fetchPressReleaseNewsWithPagination(
  //     {int page = 0, int limit = 10}) async {
  //   String apiUrl =
  //       'https://financialmodelingprep.com/stable/news/stock-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}';
  //
  //   if (cryptoType == 'Crypto') {
  //     apiUrl =
  //         'https://financialmodelingprep.com/stable/news/crypto-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}';
  //   } else if (cryptoType == 'Stocks') {
  //     apiUrl =
  //         'https://financialmodelingprep.com/stable/news/stock-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}';
  //   }
  //
  //   print('Final News API: ${apiUrl}');
  //   try {
  //     final response = await http
  //         .get(Uri.parse(apiUrl.toString()))
  //         // 'https://financialmodelingprep.com/stable/news/press-releases-latest?page=$page&limit=$limit${AppEndpoints.cryptoNewsApikey}'))
  //         .timeout(const Duration(seconds: 30));
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = jsonDecode(response.body);
  //       return jsonData.map((json) => CryptoNewsModel.fromJson(json)).toList();
  //     } else {
  //       throw HttpException('Failed to load news: ${response.statusCode}');
  //     }
  //   } on SocketException {
  //     return [];
  //     // throw Exception('No internet connection');
  //   } catch (e) {
  //     return [];
  //     // throw Exception('Unexpected error: $e');
  //   }
  // }

  // forgot send otp api call
  Future<http.Response> forgotPassword(String email) async {
    final url =
        Uri.parse('${AppEndpoints.forgotPassword}/users/forgot-password');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email}),
        )
        .timeout(Duration(minutes: 1));

    return response;
  }

  // forgot password verify otp api call
  Future<http.Response> forgotOtpVerify(
      {required String email, required String otpCode}) async {
    final url = Uri.parse('${AppEndpoints.baseUrl}otp-verify-forgot');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, "code": otpCode}),
        )
        .timeout(Duration(minutes: 1));

    return response;
  }

  // forgot password cahnge password api call
  Future<http.Response> forgotChangePassword(
      {required String email,
      required String password,
      required String otpCode}) async {
    final url = Uri.parse('${AppEndpoints.baseUrl}reset-password');

    // print("OTP data2 otp : $otpCode");
    // print("OTP data2  email : $email");
    // print("OTP data2 password : $password");

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            "newPassword": password,
            "code": otpCode
          }), // Replace "newPassword" with the actual new password
        )
        .timeout(Duration(minutes: 1));

    return response;
  }

  // Login api call
  Future<http.Response> loginApi(
      {required String email, required String password}) async {
    final url = Uri.parse('${AppEndpoints.baseUrl}${AppEndpoints.signIn}');

    print('Test Email: $email,Test Password: $password');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(Duration(minutes: 1));
    print('Login Response: ${response.body}');

    return response;
  }

  Future<List<NetWorthSummary>> fetchNetWorthSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    try {
      final uri = Uri.parse('${AppEndpoints.baseUrl}$userId/networth/summary');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> body = jsonData['body'] ?? [];
          return body.map((item) => NetWorthSummary.fromJson(item)).toList();
        } else {
          // Get.snackbar(
          //   'Error',
          //   jsonData['message'] ?? 'Failed to fetch data',
          //   backgroundColor: Colors.red,
          //   colorText: Colors.white,
          //   snackPosition: SnackPosition.BOTTOM,
          // );

          debugPrint('${jsonData['message']} Failed to fetch data');
          return [];
        }
      } else {
        // Get.snackbar(
        //   'HTTP Error',
        //   '${response.statusCode} - ${response.reasonPhrase}',
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );

        debugPrint(
            'HTTP Error ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on TimeoutException {
      // Get.snackbar(
      //   'Timeout',
      //   'Request timed out. Please try again.',
      //   backgroundColor: Colors.orange,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      debugPrint('Request timed out. Please try again.');
      return [];
    } catch (e) {
      // Catch any kind of unexpected error — network, parsing, etc.
      // Get.snackbar(
      //   'Error',
      //   'Something went wrong. Please try again.',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      debugPrint('fetchNetWorthSummary error: $e');
      return [];
    }
  }

  // new expense api call expense details page 1st graph data
  Future<List<ExpenseCategory>> fetchExpenseCategoryBreakdown(
      {required String apiEndPoint}) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    try {
      final uri = Uri.parse('${AppEndpoints.baseUrl}$userId${apiEndPoint}');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(minutes: 1));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> body = jsonData['body'];
          return body.map((item) => ExpenseCategory.fromJson(item)).toList();
        } else {
          // throw Exception(
          //     jsonData['message'] ?? 'Failed to fetch expense data');
          // Get.snackbar(
          //   'HTTP Error',
          //   '${jsonData['message']} Failed to fetch expense data',
          //   backgroundColor: Colors.red,
          //   colorText: Colors.white,
          //   snackPosition: SnackPosition.BOTTOM,
          // );
          debugPrint('${jsonData['message']} Failed to fetch data');
          return [];
        }
      } else {
        // Get.snackbar(
        //   'HTTP Error',
        //   '${response.statusCode} - ${response.reasonPhrase}',
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        debugPrint(
            'HTTP Error ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException {
      // throw Exception('Network error: Please check your internet connection');
      debugPrint('Network error: Please check your internet connection');
      return [];
    } on TimeoutException {
      debugPrint('Request timed out. Please try again.');
      return [];
    } catch (e) {
      debugPrint('fetchExpenseCategoryBreakdown error: $e');
      return [];
    }
  }

  // my protofolio
  Future<List<CryptoModel>> fetchHomeMyPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    try {
      final uri = Uri.parse(
          '${AppEndpoints.baseUrl}$userId${AppEndpoints.portfolioHomePage}');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(minutes: 1));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> body = jsonData['body'];
          return body.map((item) => CryptoModel.fromJson(item)).toList();
        } else {
          debugPrint(
              jsonData['message'] ?? 'Failed to fetch my protofolio data');
          return [];
        }
      } else {
        // throw Exception(
        //     'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        debugPrint(
            'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException {
      debugPrint('Network error: Please check your internet connection');
      return [];
      // throw Exception('Network error: Please check your internet connection');
    } on TimeoutException {
      return [];
      // throw Exception('Request timed out');
    } catch (e) {
      return [];
      // throw Exception('Unexpected error: $e');
    }
  }
}
