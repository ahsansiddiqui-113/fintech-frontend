import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _fullNameKey = 'name';

  /// Save user session with details
  static Future<void> saveSession({
    required String email,
    required String id,
    required String fullName,
    required String password,
    required String token,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
  }

  /// Get user session details
  static Future<Map<String, String?>> getUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "email": prefs.getString(_emailKey),
      "password": prefs.getString(_passwordKey),
      "full_name": prefs.getString(_fullNameKey),
      "token": prefs.getString(_tokenKey),
      "userId": prefs.getString(_userIdKey),
    };
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Logout and clear session
  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored values
  }
}
