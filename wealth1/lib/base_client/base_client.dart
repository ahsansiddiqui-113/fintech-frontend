import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/controller/drawer/drawer_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/view/authencation/login/login_page.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class BaseClient {
  static const int timeOutDuration = 300;
  final CustomDrawerController _drawerController =
  Get.find<CustomDrawerController>();

  // Check internet connection
  Future<bool> checkInternet() async {
    try {
      var response = await http
          .get(Uri.parse("https://google.com"), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: timeOutDuration));
      return response.statusCode == 200;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  // Error Handlers
  void noInternet() async {
    var res = await checkInternet();
    showToast(res ? "failedToConnect".tr : "noInternet".tr);
  }

  void connectionTimeOut() {
    showToast("timeOutError".tr);
  }

  void methodNotAllowedError() {
    showToast("methodNotAllowed".tr);
  }

  void serverError() {
    // showToast("serverError".tr);
    print("serverError".tr);
  }

  final RxBool isUnauthorizedDialogOpen = false.obs;

  void unAuthenticatedError([String? message]) {
    if (isUnauthorizedDialogOpen.value) return;

    isUnauthorizedDialogOpen.value = true;

    Get.dialog(
      Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black, // Needed to make BackdropFilter work
            ),
          ),
          Center(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: Colors.grey, width: 0.25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ImagePaths.sessionExpire,
                      fit: BoxFit.contain,
                      height: 56,
                    ),
                    addHeight(40),
                    textWidget(
                      Get.context!,
                      title: "Session Expired".tr,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                    addHeight(12),
                    textWidget(
                        Get.context!,
                        title: "Your Will Be Redirect To Login Page".tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey
                    ),
                    addHeight(20),
                    buildAddButton(
                      title: 'Done',
                      margin: const EdgeInsets.only(top: 10),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        isUnauthorizedDialogOpen.value = false;
                        Get.offAll(() => LoginPage());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );

    // showToast(message ?? "tokenExpired".tr);
  }

  void badRequestError() {
    // showToast("badRequest".tr);
    print("badRequest".tr);
  }

  Future<void> accessDeniedError([String? message]) async {
    _drawerController.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => LoginPage());
    showToast(message ?? "accessDenied".tr);
  }

  void unknownError() {
    showToast("somethingWentWrong".tr);
  }

  void parseErrorOccurred(String error) {
    debugPrint(error);
    showToast("dataParseError".tr);
  }

  // Main GET method
  Future<dynamic> get(
      String url, {
        bool isAuthenticated = true,
        bool showSuccessToast = false,
        bool isNeedHeader = true,
        bool isCustom = false,
        bool hideErrors = false,
        bool returnOriginalResponse = false,
        bool skipUnauthorizedHandling = false, // New parameter
        Map<String, String>? extraHeaders,
      }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      String finalUrl =
      isCustom ? url : AppEndpoints.baseUrl + userId.toString() + url;
      final uri = Uri.parse(finalUrl);
      final headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: extraHeaders,
      );

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: GET');

      final response =
      await (isNeedHeader ? http.get(uri, headers: headers) : http.get(uri))
          .timeout(const Duration(seconds: timeOutDuration));

      debugPrint("Response StatusCode: ${response.statusCode}");

      return _processResponse(
        response: response,
        url: url,
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // Main POST method
  Future<dynamic> post(
      String url,
      dynamic body, {
        bool isAuthenticated = true,
        bool showSuccessToast = false,
        bool isNeedHeader = true,
        bool isCustom = false,
        bool hideErrors = false,
        bool returnOriginalResponse = false,
        bool skipUnauthorizedHandling = false, // New parameter
        Map<String, String>? extraHeaders,
      }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final authToken = prefs.getString('auth_token');

      debugPrint('=== POST REQUEST DETAILS ===');
      debugPrint('User ID: $userId');
      debugPrint('Auth Token: $authToken');
      String finalUrl = isCustom
          ? AppEndpoints.baseUrl + url
          : AppEndpoints.baseUrl + userId.toString() + url;
      final uri = Uri.parse(finalUrl);
      final headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: extraHeaders,
      );

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: POST');
      debugPrint('Request Body: ${jsonEncode(body)}');

      final response = await (isNeedHeader
          ? http.post(
        uri,
        body: jsonEncode(body),
        headers: headers,
      )
          : http.post(
        uri,
        body: jsonEncode(body),
      ))
          .timeout(const Duration(seconds: timeOutDuration));

      debugPrint('=== RESPONSE DETAILS ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Headers: ${response.headers}');

      return _processResponse(
        response: response,
        url: url,
        params: jsonEncode(body),
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // PUT method
  Future<dynamic> put(
      String url,
      dynamic body, {
        bool isAuthenticated = true,
        bool showSuccessToast = false,
        bool isNeedHeader = true,
        bool isCustom = false,
        bool hideErrors = false,
        bool returnOriginalResponse = false,
        bool skipUnauthorizedHandling = false, // New parameter
        Map<String, String>? extraHeaders,
      }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      String finalUrl = isCustom
          ? AppEndpoints.baseUrl + url
          : AppEndpoints.baseUrl + userId.toString() + url;
      final uri = Uri.parse(finalUrl);
      final headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: extraHeaders,
      );

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: PUT');
      debugPrint('Request Body: ${jsonEncode(body)}');

      final response = await (isNeedHeader
          ? http.put(
        uri,
        body: jsonEncode(body),
        headers: headers,
      )
          : http.put(
        uri,
        body: jsonEncode(body),
      ))
          .timeout(const Duration(seconds: timeOutDuration));

      debugPrint("Response StatusCode: ${response.statusCode}");

      return _processResponse(
        response: response,
        url: url,
        params: jsonEncode(body),
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // DELETE method
  Future<dynamic> delete(
      String url,
      dynamic body, {
        bool isAuthenticated = true,
        bool showSuccessToast = false,
        bool isNeedHeader = true,
        bool isCustom = false,
        bool hideErrors = false,
        bool returnOriginalResponse = false,
        bool skipUnauthorizedHandling = false, // New parameter
      }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      String finalUrl = isCustom
          ? AppEndpoints.baseUrl + url
          : AppEndpoints.baseUrl + userId.toString() + url;
      final uri = Uri.parse(finalUrl);
      final headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: {},
      );

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: DELETE');

      final response = await (isNeedHeader
          ? http.delete(
        uri,
        body: jsonEncode(body),
        headers: headers,
      )
          : http.delete(
        uri,
        body: jsonEncode(body),
      ))
          .timeout(const Duration(seconds: timeOutDuration));

      debugPrint("Response StatusCode: ${response.statusCode}");

      return _processResponse(
        response: response,
        url: url,
        params: jsonEncode(body),
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // Multipart POST request handler
  Future<dynamic> multiPartPost({
    required String url,
    required Map<String, dynamic> body,
    required Map<String, File> files,
    bool isAuthenticated = true,
    bool showSuccessToast = false,
    bool hideErrors = false,
    bool returnOriginalResponse = false,
    bool skipUnauthorizedHandling = false, // New parameter
  }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      String finalUrl = AppEndpoints.baseUrl + userId.toString() + url;

      var request = http.MultipartRequest('POST', Uri.parse(finalUrl));

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: POST MULTI_PART');
      debugPrint('Request Body: ${jsonEncode(body)}');

      Map<String, String> extraHeaders = {
        "Content-Type": "multipart/form-data;",
      };

      Map<String, String> headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: extraHeaders,
        isMultiPart: true,
      );

      request.headers.addAll(headers);
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      for (final entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            file.path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(
        response: response,
        url: url,
        params: jsonEncode(body),
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // Multipart PUT request handler
  Future<dynamic> multiPartPut({
    required String url,
    required Map<String, dynamic> body,
    required Map<String, File> files,
    bool isAuthenticated = true,
    bool showSuccessToast = false,
    bool hideErrors = false,
    bool returnOriginalResponse = false,
    bool skipUnauthorizedHandling = false, // New parameter
  }) async {
    try {
      // Get userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      String finalUrl = AppEndpoints.baseUrl + userId.toString() + url;

      var request = http.MultipartRequest('PUT', Uri.parse(finalUrl));

      debugPrint('Url: $finalUrl');
      debugPrint('Request Type: PUT MULTI_PART');
      debugPrint('Request Body: ${jsonEncode(body)}');

      Map<String, String> extraHeaders = {
        "Content-Type": "multipart/form-data;",
      };

      Map<String, String> headers = await _getHeaders(
        isAuthenticated: isAuthenticated,
        extraHeaders: extraHeaders,
        isMultiPart: true,
      );

      request.headers.addAll(headers);
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      for (final entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            file.path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(
        response: response,
        url: url,
        params: jsonEncode(body),
        showSuccessToast: showSuccessToast,
        hideErrors: hideErrors,
        returnOriginalResponse: returnOriginalResponse,
        skipUnauthorizedHandling: skipUnauthorizedHandling, // Pass to processor
      );
    } on SocketException {
      noInternet();
      rethrow;
    } on TimeoutException {
      connectionTimeOut();
      rethrow;
    } catch (e) {
      unknownError();
      rethrow;
    }
  }

  // Helper Methods
  Future<Map<String, String>> _getHeaders({
    required bool isAuthenticated,
    Map<String, String>? extraHeaders,
    bool isMultiPart = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': 'en', // Or get from language controller
    };

    if (!isMultiPart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }

    if (isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    debugPrint("Headers: ${headers.toString()}");
    return headers;
  }

  bool _isSessionDialogShown = false; // Global/static variable (at the top of BaseClient)

  dynamic _processResponse({
    required http.Response response,
    required String url,
    String? params,
    bool showSuccessToast = false,
    bool hideErrors = false,
    bool returnOriginalResponse = false,
    bool skipUnauthorizedHandling = false,
  }) {
    if (returnOriginalResponse) {
      return response;
    }

    print('Api Response : ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        return processRes(
          response: response,
          showSuccessToast: showSuccessToast,
          hideErrors: hideErrors,
          url: url,
        );

      case 400:
        badRequestError();
        return null;

      case 401:
        if (!skipUnauthorizedHandling) {
          // Show dialog only once
          if (!_isSessionDialogShown) {
            _isSessionDialogShown = true;

            String? message;
            try {
              var body = utf8.decode(response.bodyBytes);
              var d = jsonDecode(body);
              message = d["message"];
            } catch (e) {
              debugPrint("401 Unauthorized");
            }

            unAuthenticatedError(message);

            // Optional: reset the flag after some time (e.g., when user logs in again)
            Future.delayed(const Duration(seconds: 3), () {
              _isSessionDialogShown = false;
            });
          }
        }
        return null;

      case 403:
        String? message;
        try {
          var body = utf8.decode(response.bodyBytes);
          var d = jsonDecode(body);
          message = d["message"];
        } catch (e) {
          debugPrint("403 Access Denied");
        }
        accessDeniedError(message);
        return null;

      case 404:
        print("resourceNotFound".tr);
        return null;

      case 405:
        methodNotAllowedError();
        return null;

      case 500:
        serverError();
        return null;

      case 504:
        String? message;
        try {
          var body = utf8.decode(response.bodyBytes);
          var d = jsonDecode(body);
          message = d["message"];
        } catch (e) {
          debugPrint("504 Access Denied");
        }
        accessDeniedError(message);
        return null;

      default:
        unknownError();
        return null;
    }
  }

  // dynamic _processResponse({
  //   required http.Response response,
  //   required String url,
  //   String? params,
  //   bool showSuccessToast = false,
  //   bool hideErrors = false,
  //   bool returnOriginalResponse = false,
  //   bool skipUnauthorizedHandling = false, // New parameter
  // }) {
  //   if (returnOriginalResponse) {
  //     return response;
  //   }
  //   print('Api Responce : ${response.body}');
  //
  //   switch (response.statusCode) {
  //     case 200:
  //     case 201:
  //       return processRes(
  //         response: response,
  //         showSuccessToast: showSuccessToast,
  //         hideErrors: hideErrors,
  //         url: url,
  //       );
  //     case 400:
  //       badRequestError();
  //       return null;
  //     case 401:
  //     // Skip 401 handling if specified (e.g., for logout API)
  //     //   if (!skipUnauthorizedHandling) {
  //     //     debugPrint("401 Unauthorized - Skipping session expired handling");
  //     //     return null;
  //     //   }
  //       String? message;
  //       try {
  //         var body = utf8.decode(response.bodyBytes);
  //         var d = jsonDecode(body);
  //         message = d["message"];
  //       } catch (e) {
  //         debugPrint("401 Unauthorized");
  //       }
  //       unAuthenticatedError(message);
  //       return null;
  //     case 403:
  //       String? message;
  //       try {
  //         var body = utf8.decode(response.bodyBytes);
  //         var d = jsonDecode(body);
  //         message = d["message"];
  //       } catch (e) {
  //         debugPrint("403 Access Denied");
  //       }
  //       accessDeniedError(message);
  //       return null;
  //     case 404:
  //       print("resourceNotFound".tr);
  //       // showToast("resourceNotFound".tr);
  //       return null;
  //     case 405:
  //       methodNotAllowedError();
  //       return null;
  //     case 500:
  //       serverError();
  //       return null;
  //     case 504:
  //       String? message;
  //       try {
  //         var body = utf8.decode(response.bodyBytes);
  //         var d = jsonDecode(body);
  //         message = d["message"];
  //       } catch (e) {
  //         debugPrint("504 Access Denied");
  //       }
  //       accessDeniedError(message);
  //       return null;
  //     default:
  //       unknownError();
  //       return null;
  //   }
  // }

  dynamic processRes({
    String? title,
    required http.Response response,
    bool showSuccessToast = false,
    bool hideErrors = false,
    String url = "",
  }) {
    try {
      var body = utf8.decode(response.bodyBytes);
      var data = jsonDecode(body);

      if (data['status'] != null && data['status'].runtimeType == int) {
        if (data['status'] != 200) {
          var message = data['message'];
          if (!hideErrors) {
            showToast(message ?? "somethingWentWrong".tr);
          }
          return null;
        } else {
          if (showSuccessToast && data['message'] != null) {
            showToast(data['message']);
          }
          return data;
        }
      }
      return data;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        debugPrint(stacktrace.toString());
      }
      parseErrorOccurred(e.toString());
      return null;
    }
  }
}