import 'dart:developer' as developer;

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
      // );
      serverClientId:
          '756089115715-f4l067kce9gjik5kbrrur5u9nb4ks0oo.apps.googleusercontent.com',
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

      // Obtain the access token (requires authorization step in v7+)
      final authorization = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile', 'openid']);
      final String accessToken = authorization.accessToken;
      developer.log('google Access Token: $accessToken', name: 'GoogleAuth');

      if (idToken == null || accessToken == null) {
        throw 'Unable to obtain authentication tokens';
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;
      if (user != null) {
        print('✅ Signed in with Google: ${user.email}');
        isLoading.value = false;
        print("skjdnfkjsndkjfnksjdf");
        final dd = await user?.getIdToken();
        developer.log('🔑 ID Token DEDDDDDDDDD: $dd', name: 'Firebase');
        return true;
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
