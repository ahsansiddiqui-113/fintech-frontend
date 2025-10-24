import 'dart:async';
import 'package:get/get.dart';
import 'package:wealthnx/controller/feedback/feedback_controller.dart';
import 'package:wealthnx/services/feedback_dialog_service.dart';
import 'package:wealthnx/view/feedback/feedback_screen_dialog.dart';

class FeedbackDialogTrigger {
  static Timer? _timer;
  static final FeedbackDialogService _feedbackService = FeedbackDialogService();

  /// Shows feedback dialog after 30 seconds if not shown before for the current user
  static Future<void> triggerAfterLogin() async {
    _timer?.cancel();

    // Get current user ID
    final userId = await _feedbackService.getCurrentUserId();
    if (userId == null) {
      print('No user ID found. Cannot show feedback dialog.');
      return;
    }
    // Check if this user has already seen the feedback dialog
    bool hasShown = await _feedbackService.hasShownFeedbackDialog(userId);
    if (hasShown) {
      print('Feedback dialog already shown for user: $userId. Skipping...');
      return;
    }

    print('Feedback dialog will be shown for user: $userId in 30 seconds...');

    // Set timer for 30 seconds
    _timer = Timer(const Duration(seconds: 180), () async {
      // Double-check before showing
      final currentUserId = await _feedbackService.getCurrentUserId();

      if (currentUserId == null) {
        print('User ID not found at trigger time.');
        return;
      }

      bool hasShownAgain = await _feedbackService.hasShownFeedbackDialog(currentUserId);

      if (!hasShownAgain && Get.context != null) {
        print('Showing feedback dialog for user: $currentUserId');
        _showFeedbackDialog();
      } else {
        print('Feedback dialog already shown. Skipping...');
      }
    });
  }

  /// Show the feedback dialog
  static void _showFeedbackDialog() {
    Get.dialog(
      FeedbackScreenDialog(
        onPressed: () async {
          final controller = Get.find<FeedbackController>();
          await controller.onDialogDismissed();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }

  /// Cancel the timer (call this if user logs out before 30 seconds)
  static void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    print('Feedback dialog timer cancelled.');
  }
}