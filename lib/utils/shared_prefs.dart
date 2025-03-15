import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _isFirstTimeKey = 'is_first_time';

  // Initialize with default value (true for first time)
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // If the key doesn't exist, it means it's the first time
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  // Set first time to false after user accepts terms
  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }
}