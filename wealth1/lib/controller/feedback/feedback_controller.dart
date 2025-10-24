import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/services/feedback_dialog_service.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_urls.dart';

class FeedbackController extends GetxController {
  final TextEditingController descriptionController = TextEditingController();
  final FeedbackDialogService _feedbackService = FeedbackDialogService();

  final List<String> feedbackOptions = [
    "Smooth Experience",
    "The app feels slow",
    "I really like the AI features",
    "Some features don't work as expected",
    "The layout feels confusing",
    "Other"
  ];

  final Rxn<int> selectedOption = Rxn<int>();

  bool get isButtonEnabled => selectedOption.value != null;

  void toggleOption(int index) {
    if (selectedOption.value == index) {
      selectedOption.value = null;
    } else {
      selectedOption.value = index;
    }
  }

  Future<void> submitFeedback() async {
    String? selected = selectedOption.value != null
        ? feedbackOptions[selectedOption.value!]
        : null;

    String description = descriptionController.text.trim();

    print("Selected option: $selected");
    print("Description: $description");

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await BaseClient().post(AppEndpoints.Feedback, {
        "feedType": selected,
        "feedDescription": description,
      });

      print("API Response: $response");

      if (Get.isDialogOpen == true) {
        Get.back();
        Get.back();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (response != null) {
        bool isSuccess = response['success'] == true ||
            response['status'] == true ||
            response['statusCode'] == 200 ||
            response['code'] == 200;

        if (isSuccess) {
          // Get current user ID and mark as shown
          final userId = await _feedbackService.getCurrentUserId();
          if (userId != null) {
            await _feedbackService.markFeedbackDialogAsShown(userId);
          }

          selectedOption.value = null;
          descriptionController.clear();

          Get.rawSnackbar(
            title: 'Success',
            message: response['message'] ?? 'Feedback Given Successfully',
            backgroundColor: Get.context!.gc(AppColor.primary),
            snackPosition: SnackPosition.TOP,
            borderRadius: 8,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (Get.isDialogOpen == true) {
              Get.back();
            }
          });
        } else {
          Get.rawSnackbar(
            title: 'Error',
            message: response['message'] ?? 'Something went wrong',
            backgroundColor: Get.context!.gc(AppColor.redColor),
            snackPosition: SnackPosition.TOP,
            borderRadius: 8,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
          );
        }
      } else {
        Get.rawSnackbar(
          title: 'Error',
          message: 'No response from server',
          backgroundColor: Get.context!.gc(AppColor.redColor),
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        );
      }
    } catch (error) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      print('Error submitting feedback: $error');
      Get.rawSnackbar(
        title: 'Error',
        message: 'Failed to submit feedback. Please try again.',
        backgroundColor: Get.context!.gc(AppColor.redColor),
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }

  Future<void> onDialogDismissed() async {
    // Get current user ID and mark as shown
    final userId = await _feedbackService.getCurrentUserId();
    if (userId != null) {
      await _feedbackService.markFeedbackDialogAsShown(userId);
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}