import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/profile/profile_model.dart';
import 'package:wealthnx/utils/app_urls.dart';

// class ProfileController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   final firstNameController = TextEditingController();
//   final RxString fullNameProfile = ''.obs;
//   final lastNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneNoController = TextEditingController();
//   final dobController = TextEditingController();
//   final addressController = TextEditingController();
//   final genderController = TextEditingController();
//   final martialStatusController = TextEditingController().obs;
//   final socialLinkController = TextEditingController();
//   final profilePicController = TextEditingController();
//   final RxString profilePic = ''.obs;
//
//   var firstName = ''.obs;
//   final isLoading = false.obs;
//   final profileData = Rxn<ProfileModel>();
//   final profileImageFile = Rxn<File>(); // Store the selected image file
//
//   static const List<String> categories = ['Select', 'Male', 'Female'];
//   static const List<String> martialStatus = ['Single', 'Married'];
//   final RxList<String> selectedCategories = <String>[].obs;
//   final RxString selectedIncomeType = 'Select'.obs;
//   // final RxString martialStatus = 'Select'.obs;
//
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     fetchProfileData();
//     // firstNameController.addListener(() {
//     //   firstName.value = firstNameController.text;
//     // });
//   }
//
//   // Pick image from gallery or camera
//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(source: source);
//       if (image != null) {
//         profileImageFile.value = File(image.path);
//         // Optionally, you can update profilePicController if needed
//         // profilePicController.text = image.path; // For local display before upload
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to pick image: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Fetch profile data
//   // Future<void> fetchProfileData() async {
//   //   try {
//   //     isLoading(true);
//
//   //     final response = await BaseClient().get(AppEndpoints.profileGet);
//   //     if (response != null) {
//   //       final dynamic jsonResponse =
//   //           response is String ? json.decode(response) : response;
//   //       profileData.value = ProfileModel.fromJson(jsonResponse);
//   //       fullNameProfile.value = '${profileData.value?.body?.firstName}' ?? '';
//   //       _loadProfileData();
//   //       isLoading(false);
//   //     }
//   //   } catch (e) {
//   //     isLoading(false);
//   //   }
//   //   // Get.snackbar(
//   //   //   'Error',
//   //   //   'Failed to fetch profile: ${e.toString()}',
//   //   //   snackPosition: SnackPosition.BOTTOM,
//   //   //   backgroundColor: Colors.red,
//   //   //   colorText: Colors.white,
//   //   // );
//   //   // } finally {
//   //   //   isLoading(false);
//   //   // }
//   // }
//   Future<void> fetchProfileData() async {
//     try {
//       isLoading.value = true;
//
//       final response = await BaseClient().get(AppEndpoints.profileGet);
//       if (response != null) {
//         final dynamic jsonResponse =
//             response is String ? json.decode(response) : response;
//         profileData.value = ProfileModel.fromJson(jsonResponse);
//         fullNameProfile.value = profileData.value?.body?.firstName ?? '';
//         _loadProfileData();
//       }
//     } catch (e) {
//       debugPrint('Error fetching profile: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void _loadProfileData() {
//     if (profileData.value?.body != null) {
//       final body = profileData.value!.body!;
//       profilePicController.text = body.profilePic ?? '';
//       profilePic.value = body.profilePic ?? '';
//       firstNameController.text = body.firstName ?? '';
//       lastNameController.text = body.lastName ?? '';
//       emailController.text = body.email ?? '';
//       phoneNoController.text = body.phoneNo ?? '';
//       dobController.text = body.dob ?? '';
//       addressController.text = body.adress ?? '';
//       genderController.text = body.gender ?? '';
//       martialStatusController.value.text = body.martialState ?? '';
//       socialLinkController.text = body.socialLink ?? '';
//
//       if (genderController.value.text == 'Male') {
//         selectedIncomeType.value = 'Male';
//       } else if (genderController.value.text == 'Female') {
//         selectedIncomeType.value = 'Female';
//       } else {
//         selectedIncomeType.value = 'Select';
//       }
//     }
//   }
//
//   // Update profile with image
//   Future<void> updateProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString('auth_token');
//     final userId = prefs.getString('userId');
//     print('Auth Token: $authToken');
//     print('User ID: $userId');
//     try {
//       if (!formKey.currentState!.validate()) return;
//
//       // isLoading(true);
//       Get.dialog(
//           const Center(
//             child: CircularProgressIndicator(),
//           ),
//           barrierDismissible: false);
//
//       var request = http.MultipartRequest(
//         'PUT',
//         Uri.parse(
//             '${AppEndpoints.baseUrl}$userId${AppEndpoints.profileUpdate}'),
//       );
//
//       // Add text fields
//       request.fields.addAll({
//         'firstName': firstNameController.value.text.trim(),
//         'lastName': lastNameController.text.trim(),
//         'email': emailController.text.trim(),
//         'phoneNo': phoneNoController.text.trim(),
//         'dob': dobController.text.trim(),
//         'address': addressController.text.trim(),
//         'gender': genderController.text.trim(),
//         'maritalState': martialStatusController.value.text.trim(),
//         'socialLink': socialLinkController.text.trim(),
//       });
//
//       // Add profile picture if selected
//       if (profileImageFile.value != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'profilePicture',
//             profileImageFile.value!.path,
//           ),
//         );
//       }
//
//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $authToken', // Replace with actual token
//       });
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         await fetchProfileData(); // Refresh data after update
//         Get.back(); // Close the loading dialog
//         // Clear the image file after successful upload
//         // profileImageFile.value = null; // Clear the selected image
//         Get.snackbar(
//           'Success',
//           'Profile updated successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         fetchProfileData();
//         firstNameController.addListener(() {
//           firstName.value = firstNameController.text;
//         });
//       } else {
//         Get.back(); // Close the loading dialog
//         // Clear the image file after failed upload
//         Get.snackbar(
//           'Error',
//           'Failed to update profile: ${response.reasonPhrase}',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.back(); // Close the loading dialog
//       Get.snackbar(
//         'Error',
//         'Failed to update profile: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       // Get.back();
//       // isLoading(false);
//     }
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     phoneNoController.dispose();
//     dobController.dispose();
//     addressController.dispose();
//     genderController.dispose();
//     martialStatusController.value.dispose();
//     socialLinkController.dispose();
//     profilePicController.dispose();
//   }
// }


class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final RxString fullNameProfile = ''.obs;
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNoController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final genderController = TextEditingController();
  final martialStatusController = TextEditingController().obs;
  final socialLinkController = TextEditingController();
  final profilePicController = TextEditingController();
  final RxString profilePic = ''.obs;

  var firstName = ''.obs;
  final isLoading = false.obs;
  final profileData = Rxn<ProfileModel>();
  final profileImageFile = Rxn<File>(); // Store the selected image file

  static const List<String> categories = ['Select', 'Male', 'Female'];
  static const List<String> martialStatus = ['Single', 'Married'];
  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedIncomeType = 'Select'.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;

      final response = await BaseClient().get(AppEndpoints.profileGet);
      if (response != null) {
        final dynamic jsonResponse =
        response is String ? json.decode(response) : response;
        profileData.value = ProfileModel.fromJson(jsonResponse);
        fullNameProfile.value = profileData.value?.body?.firstName ?? '';
        _loadProfileData();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadProfileData() {
    if (profileData.value?.body != null) {
      final body = profileData.value!.body!;
      profilePicController.text = body.profilePic ?? '';
      profilePic.value = body.profilePic ?? '';
      firstNameController.text = body.firstName ?? '';
      lastNameController.text = body.lastName ?? '';
      emailController.text = body.email ?? '';
      phoneNoController.text = body.phoneNo ?? '';
      if (body.dob != null && body.dob!.isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(body.dob!);
          dobController.text = "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
        } catch (e) {
          dobController.text = body.dob ?? '';
        }
      } else {
        dobController.text = '';
      }
      addressController.text = body.adress ?? '';
      genderController.text = body.gender ?? '';
      martialStatusController.value.text = body.martialState ?? '';
      socialLinkController.text = body.socialLink ?? '';

      if (genderController.text == 'Male') {
        selectedIncomeType.value = 'Male';
      } else if (genderController.text == 'Female') {
        selectedIncomeType.value = 'Female';
      } else {
        selectedIncomeType.value = 'Select';
      }
    }
  }

  void setDateOfBirth(DateTime date) {
    // Format for display: DD/MM/YYYY
    dobController.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
  String getFormattedDobForApi() {
    if (dobController.text.isEmpty) return '';

    try {
      List<String> parts = dobController.text.split('/');
      if (parts.length == 3) {
        String day = parts[0];
        String month = parts[1];
        String year = parts[2];
        return "$year-$month-$day";
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    return '';
  }


  // Update profile with image
  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('userId');
    print('Auth Token: $authToken');
    print('User ID: $userId');
    try {
      isLoading.value = true;
      if (!formKey.currentState!.validate()) return;

      // Get.dialog(
      //     const Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //     barrierDismissible: false);

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            '${AppEndpoints.baseUrl}$userId${AppEndpoints.profileUpdate}'),
      );

      // Add text fields
      request.fields.addAll({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNo': phoneNoController.text.trim(),
        'dob': getFormattedDobForApi(),
        'address': addressController.text.trim(),
        'gender': genderController.text.trim(),
        'maritalState': martialStatusController.value.text.trim(),
        'socialLink': socialLinkController.text.trim(),
      });

      // Add profile picture if selected
      if (profileImageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            profileImageFile.value!.path.toString(),
          ),
        );
      }

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $authToken',
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
print('responseBody ${response.statusCode}');
      if (response.statusCode == 200) {
        await fetchProfileData();
       // Get.back(); // Close the loading dialog
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchProfileData();
        firstNameController.addListener(() {
          firstName.value = firstNameController.text;
        });
        isLoading.value = false;
      } else {
        // Get.back(); // Close the loading dialog
        Get.snackbar(
          'Error',
          'Failed to update : ${response.reasonPhrase}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
      }
    } catch (e) {
       //Get.back(); // Close the loading dialog
      Get.snackbar(
        'Error',
        'Failed to update profile : ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNoController.dispose();
    dobController.dispose();
    addressController.dispose();
    genderController.dispose();
    martialStatusController.value.dispose();
    socialLinkController.dispose();
    profilePicController.dispose();
    super.dispose();
  }
}