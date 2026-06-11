import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/profile/controller/profile_controller.dart';
import 'package:qurany/feature/auth/controllers/auth_controller.dart';

class UsageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _capsKeyPrefix = 'cached_cap_';
  static const String _usageKeyPrefix = 'local_usage_';

  /// Resolves the active user ID robustly across controllers
  static String getActiveUserId() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>().user.value;
        if (profile != null && profile.id.isNotEmpty) {
          return profile.id;
        }
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<AuthController>()) {
        final firebaseUser = Get.find<AuthController>().firebaseUser.value;
        if (firebaseUser != null && firebaseUser.uid.isNotEmpty) {
          return firebaseUser.uid;
        }
      }
    } catch (_) {}

    return 'guest';
  }

  /// Fetches the metered limits/caps, utilizing Firestore (remote-configurable)
  /// with offline caching and default fallbacks.
  static Future<Map<String, int>> getCaps() async {
    final Map<String, int> caps = {
      'ai_companion': 5,
      'practice_session': 3,
    };

    try {
      final doc = await _db.collection('app_config').doc('limits').get().timeout(
        const Duration(seconds: 3),
      );
      if (doc.exists) {
        final data = doc.data();
        final aiCap = data?['ai_companion_cap'] as int? ?? 5;
        final practiceCap = data?['practice_session_cap'] as int? ?? 3;
        
        caps['ai_companion'] = aiCap;
        caps['practice_session'] = practiceCap;

        // Cache locally for offline usage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('${_capsKeyPrefix}ai_companion', aiCap);
        await prefs.setInt('${_capsKeyPrefix}practice_session', practiceCap);
        
        return caps;
      }
    } catch (e) {
      debugPrint('[UsageService] Failed to fetch remote caps (offline/error): $e');
    }

    // Attempt to read from local cache if remote fetch failed
    try {
      final prefs = await SharedPreferences.getInstance();
      final aiCap = prefs.getInt('${_capsKeyPrefix}ai_companion') ?? 5;
      final practiceCap = prefs.getInt('${_capsKeyPrefix}practice_session') ?? 3;
      caps['ai_companion'] = aiCap;
      caps['practice_session'] = practiceCap;
    } catch (e) {
      debugPrint('[UsageService] Failed to read cached caps: $e');
    }

    return caps;
  }

  /// Calculates the usage count in the rolling 7-day window.
  /// Automatically falls back to local SharedPreferences if Firestore is inaccessible.
  static Future<int> getUsageCount(String userId, String feature) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    try {
      // Query Firestore for documents in the rolling 7-day window
      final querySnapshot = await _db
          .collection('users_usage')
          .doc(userId)
          .collection(feature)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .get()
          .timeout(const Duration(seconds: 3));

      final count = querySnapshot.docs.length;

      // Extract timestamps and sync local cache
      final List<String> timestamps = querySnapshot.docs.map((doc) {
        final timestamp = doc.data()['timestamp'] as Timestamp?;
        return (timestamp ?? Timestamp.fromDate(now)).toDate().toIso8601String();
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('${_usageKeyPrefix}$feature', timestamps);

      return count;
    } catch (e) {
      debugPrint('[UsageService] Firestore getUsageCount failed, falling back to local: $e');
    }

    // Local fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      final localTimestamps = prefs.getStringList('${_usageKeyPrefix}$feature') ?? [];
      
      // Filter out timestamps older than 7-days
      final filtered = localTimestamps.where((isoStr) {
        try {
          final date = DateTime.parse(isoStr);
          return date.isAfter(sevenDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();

      // Update filtered list back to local storage
      await prefs.setStringList('${_usageKeyPrefix}$feature', filtered);
      return filtered.length;
    } catch (e) {
      debugPrint('[UsageService] Local fallback getUsageCount failed: $e');
    }

    return 0; // Default to 0 in worst case to avoid trapping the user
  }

  /// Increments the usage count of a feature by adding a new timestamp.
  /// Writes to both Firestore and local SharedPreferences.
  static Future<void> incrementUsage(String userId, String feature) async {
    final now = DateTime.now();

    // 1. Update local cache immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      final localTimestamps = prefs.getStringList('${_usageKeyPrefix}$feature') ?? [];
      localTimestamps.add(now.toIso8601String());
      await prefs.setStringList('${_usageKeyPrefix}$feature', localTimestamps);
    } catch (e) {
      debugPrint('[UsageService] Error caching usage locally: $e');
    }

    // 2. Write to Firestore
    try {
      await _db
          .collection('users_usage')
          .doc(userId)
          .collection(feature)
          .add({
        'timestamp': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 2));
      debugPrint('[UsageService] Successfully recorded $feature usage in Firestore');
    } catch (e) {
      debugPrint('[UsageService] Firestore incrementUsage failed (will rely on cache): $e');
    }
  }
}
