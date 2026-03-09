import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class AppleSignInService {
  static final isLoading = false.obs;

  /// Generates a cryptographically secure random nonce, to be included in the
  /// credential request.
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> signInWithApple() async {
    try {
      isLoading.value = true;

      // To prevent replay attacks
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credentials from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // final OAuthCredential credential = AppleAuthProvider.credential(
      //   idToken: appleCredential.identityToken,
      //   rawNonce: rawNonce,
      // );

      // await FirebaseAuth.instance.signInWithCredential(credential);

      return true;
    } catch (e) {
      print('Error during Apple Sign In: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
