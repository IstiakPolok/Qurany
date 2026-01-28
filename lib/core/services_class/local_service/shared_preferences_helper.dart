import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'token';
  static const String _selectedRoleKey = 'selectedRole';
  static const String _categoriesKey = "categories";
  static const String _isWelcomeDialogShownKey =
      'isDriverVerificationDialogShown';
  static const String _feelingKey = 'user_feeling';

  // Save categories (id and name only)
  static Future<void> saveCategories(
    List<Map<String, String>> categories,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final categoriesJson = jsonEncode(categories);
    await prefs.setString(_categoriesKey, categoriesJson);
  }

  // Retrieve categories (id and name only)
  static Future<List<Map<String, String>>> getCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      return List<Map<String, String>>.from(jsonDecode(categoriesJson));
    }
    return [];
  }

  // Save access token
  static Future<void> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool tokenSaved = await prefs.setString(_accessTokenKey, token);
      bool loginFlagSaved = await prefs.setBool('isLogin', true);

      print('Token saved: $tokenSaved'); // Should print true
      print('Login flag saved: $loginFlagSaved'); // Should print true
    } catch (e) {
      print('Error saving token to SharedPreferences: $e');
    }
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Clear access token
  static Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey); // Clear the token
    await prefs.remove(_selectedRoleKey); // Clear the role
    await prefs.remove('isLogin'); // Clear the login status
  }

  // Retrieve selected role
  static Future<String?> getSelectedRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRoleKey);
  }

  static Future<bool?> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  // Save the flag indicating the dialog has been shown
  static Future<void> setWelcomeDialogShown(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isWelcomeDialogShownKey, value);
  }

  // Retrieve the flag to check if the dialog has been shown
  static Future<bool> isWelcomeDialogShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isWelcomeDialogShownKey) ?? false;
  }

  // Key for showOnboard
  static const String _showOnboardKey = 'showOnboard';

  // Save the showOnboard flag
  static Future<void> setShowOnboard(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showOnboardKey, value);
  }

  // Retrieve the showOnboard flag
  static Future<bool> getShowOnboard() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showOnboardKey) ??
        false; // Default to false if not set
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ??
        'me'; // Default to 'me' if not found
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  static Future<void> saveAccessToken(String token) async {
    await saveToken(token);
  }

  static Future<void> logoutUser() async {
    await clearAllData();
    // Get.offAll(() => LoginView());
  }

  // Save the User ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Retrieve the User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Save compass style preference
  static Future<void> saveCompassStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('compass_style', style);
  }

  // Retrieve compass style preference
  static Future<String> getCompassStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('compass_style') ?? 'Classic'; // Default to Classic
  }

  // --- Preference Flow Helpers ---

  // Language
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_language') ?? 'English';
  }

  // Arabic Script
  static Future<void> saveArabicScript(String script) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arabic_script', script);
  }

  static Future<String> getArabicScript() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arabic_script') ?? 'Imlaei';
  }

  // Reciter
  static Future<void> saveReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_reciter', reciter);
  }

  static Future<String> getReciter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('quran_reciter') ?? 'Mishary Rashid Alafasy';
  }

  // Goals (List<String>)
  static Future<void> saveGoals(List<String> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_goals', goals);
  }

  static Future<List<String>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_goals') ?? ['Memorize Quran'];
  }

  // Feeling
  static Future<void> saveFeeling(Map<String, String> feeling) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feelingKey, jsonEncode(feeling));
  }

  static Future<Map<String, String>?> getFeeling() async {
    final prefs = await SharedPreferences.getInstance();
    final feelingJson = prefs.getString(_feelingKey);
    if (feelingJson != null) {
      return Map<String, String>.from(jsonDecode(feelingJson));
    }
    return null;
  }

  static Future<void> clearFeeling() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feelingKey);
  }

  // Recent Reading History
  static const String _recentReadingKey = 'recent_reading_history';

  static Future<void> saveRecentReading({
    required int surahId,
    required String surahName,
    required String arabicName,
    required int lastVerseId,
    required int totalVerses,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history
    List<Map<String, dynamic>> history = await getRecentReadingHistory();

    // Remove existing entry for this surah if it exists
    history.removeWhere((item) => item['surahId'] == surahId);

    // Add new entry at the beginning
    history.insert(0, {
      'surahId': surahId,
      'surahName': surahName,
      'arabicName': arabicName,
      'lastVerseId': lastVerseId,
      'totalVerses': totalVerses,
      'lastReadAt': DateTime.now().toIso8601String(),
    });

    // Keep only the last 3 items
    if (history.length > 3) {
      history = history.sublist(0, 3);
    }

    // Save back to preferences
    await prefs.setString(_recentReadingKey, jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> getRecentReadingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_recentReadingKey);
    if (historyJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }
    return [];
  }

  static Future<void> clearRecentReadingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentReadingKey);
  }
}
