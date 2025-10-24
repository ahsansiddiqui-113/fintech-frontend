import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeedbackDialogService {
  static const String _feedbackShownKey = 'feedback_dialog_shown_users';

  /// Check if feedback dialog has been shown for a specific user
  Future<bool> hasShownFeedbackDialog(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_feedbackShownKey);

    if (storedData == null) {
      return false;
    }

    try {
      Map<String, dynamic> userFeedbackMap = json.decode(storedData);
      return userFeedbackMap[userId] == true;
    } catch (e) {
      print('Error reading feedback data: $e');
      return false;
    }
  }

  /// Mark feedback dialog as shown for a specific user
  Future<void> markFeedbackDialogAsShown(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_feedbackShownKey);
    Map<String, dynamic> userFeedbackMap = {};
    if (storedData != null) {
      try {
        userFeedbackMap = json.decode(storedData);
      } catch (e) {
        print('Error parsing stored data: $e');
      }
    }
    // Mark this user as having seen the feedback dialog
    userFeedbackMap[userId] = true;
    // Save back to SharedPreferences
    await prefs.setString(_feedbackShownKey, json.encode(userFeedbackMap));
  }

  /// Get the current user ID from SharedPreferences
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Reset feedback dialog for all users (for testing)
  Future<void> resetFeedbackDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedbackShownKey);
  }

  /// Reset feedback dialog for a specific user (for testing)
  Future<void> resetFeedbackDialogForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_feedbackShownKey);

    if (storedData != null) {
      try {
        Map<String, dynamic> userFeedbackMap = json.decode(storedData);
        userFeedbackMap.remove(userId);
        await prefs.setString(_feedbackShownKey, json.encode(userFeedbackMap));
      } catch (e) {
        print('Error resetting user feedback: $e');
      }
    }
  }

  /// Get all users who have seen the feedback dialog (for debugging)
  Future<List<String>> getUsersWhoHaveSeenFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_feedbackShownKey);

    if (storedData == null) {
      return [];
    }

    try {
      Map<String, dynamic> userFeedbackMap = json.decode(storedData);
      return userFeedbackMap.keys.where((key) => userFeedbackMap[key] == true).toList();
    } catch (e) {
      print('Error getting users list: $e');
      return [];
    }
  }
}