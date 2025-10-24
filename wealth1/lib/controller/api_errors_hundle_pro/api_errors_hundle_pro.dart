// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wealthnx/utils/app_urls.dart';
// import 'package:wealthnx/view/authencation/login/login_page.dart';
//
// Future<void> fetchUserProfile() async {
//    final prefs = await SharedPreferences.getInstance();
//       final authToken = prefs.getString('auth_token');
//       final userId = prefs.getString('userId');
//       print('Auth Token: $authToken');
//       print('User ID: $userId');
//   var headers = {
//     'Authorization': 'Bearer $authToken', // Replace with actual token
//   };
//
//   var url = Uri.parse(
//     '${AppEndpoints.baseUrl}$userId${AppEndpoints.profileGet}',
//   );
//
//   try {
//     var request = http.Request('GET', url);
//     request.headers.addAll(headers);
//
//     http.StreamedResponse response = await request.send();
//
//     final statusCode = response.statusCode;
//     final responseBody = await response.stream.bytesToString();
//
//     switch (statusCode) {
//       case 200:
//         print('✅ Success: User profile fetched successfully.');
//         print(responseBody);
//         break;
//
//       case 401:
//         print('🔒 Unauthorized: Token may be invalid or expired.');
//         Get.defaultDialog(
//           title: 'Session Expired',
//           middleText: 'Please log in again.',
//           onConfirm: () async {
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.clear();
//             Get.offAll(LoginPage()); // Adjust the route as needed
//           },
//           textConfirm: 'Login',
//         );
//         break;
//
//       case 500:
//         print('❌ Server Error: Please try again later.');
//         break;
//
//       default:
//         print('⚠️ Unexpected Error: HTTP $statusCode');
//         print('Message: $responseBody');
//         break;
//     }
//   } catch (e) {
//     print('❗ Exception occurred: $e');
//   }
// }

