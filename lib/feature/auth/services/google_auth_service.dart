import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network_caller/endpoints.dart';

import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static final RxBool isLoading = false.obs;

  /// Private method to ensure GoogleSignIn is initialized
  static Future<void> _ensureInitialized() async {
    await _googleSignIn.initialize(
      //   serverClientId:
      //       "551512267457-u6q3vqnv2bf7567ecrbptv7b04m7t1h7.apps.googleusercontent.com",
      //
      serverClientId:
          '917319441883-gf0vcq0tohjkal87djhcntn7hbupoo0p.apps.googleusercontent.com',
    );
  }

  /// Sign in with Google
  static Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Ensure initialized
      await _ensureInitialized();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      // If user cancels the sign-in
      if (googleUser == null) {
        isLoading.value = false;
        return false;
      }

      // Obtain the auth details (idToken is here)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      developer.log('Google ID Token: $idToken', name: 'GoogleAuth');

      if (idToken != null) {
        print('✅ Obtained Google ID Token, sending to backend...');

        // Send token to backend
        try {
          final response = await http.post(
            Uri.parse(
              '$baseUrl/api/user/auth/google',
            ), // Use your backend endpoint here
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"token": idToken}),
          );

          print('Backend Response Status: ${response.statusCode}');
          print('Backend Response Body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Parse successful response
            final data = jsonDecode(response.body);
            print("✅ Backend Login Success: $data");

            // Save tokens to SharedPreferences
            if (data['data'] != null) {
              final accessToken = data['data']['accessToken'];
              final refreshToken = data['data']['refreshToken'];
              final email = data['data']['email'];

              // Add your preferred saving method here
              // Example:
              await SharedPreferencesHelper.saveAccessToken(accessToken);
              await SharedPreferencesHelper.saveRefreshToken(refreshToken);
              await SharedPreferencesHelper.saveEmail(email);
            }

            // Note: We are deliberately skipping Firebase Auth sign-in
            // as requested ("not firebase").
            isLoading.value = false;
            return true;
          } else {
            print("❌ Backend Login Failed");
            isLoading.value = false;
            return false;
          }
        } catch (e) {
          print("❌ Error sending token to backend: $e");
          isLoading.value = false;
          return false;
        }
      }

      isLoading.value = false;
      return false;
    } catch (e) {
      print('❌ Google Sign-In failed: $e');
      isLoading.value = false;
      Get.snackbar(
        'Sign In Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      // Silently fail or log
    }
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Helper method to split long strings for printing
  static List<String> _splitString(String text, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }
}
