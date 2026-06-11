import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

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
      print(' Initiating Apple Sign-In flow...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          // Important: Replace these with your actual Apple Service ID and Callback URL
          clientId:
              'backend.qurany.pro', // Service Identifier configured in Apple Developer Console
          redirectUri: Uri.parse(
            'https://backend.qurany.pro/api/user/auth/apple/callback',
          ),
        ),
      );

      final String? idToken = appleCredential.identityToken;
      print(
        ' Apple Credential Received. Identity Token length: ${idToken?.length ?? 0}',
      );
      print(' FULL APPLE ID TOKEN: $idToken');
      print(
        ' User Details: ${appleCredential.givenName} ${appleCredential.familyName}, Email: ${appleCredential.email}',
      );

      if (idToken != null) {
        String email = appleCredential.email ?? '';
        String name = '';
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          name =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
        }

        // Apple only sends email in the credential object on the very first login.
        // For subsequent logins, we must extract it from the idToken JWT payload.
        if (email.isEmpty) {
          try {
            final parts = idToken.split('.');
            if (parts.length >= 2) {
              final payloadStr = parts[1];
              final normalizedStr = base64Url.normalize(payloadStr);
              final payloadMap = jsonDecode(
                utf8.decode(base64Url.decode(normalizedStr)),
              );
              email = payloadMap['email'] ?? '';
            }
          } catch (e) {
            print('Error decoding Apple JWT to get email: $e');
          }
        }

        print('✅ Obtained Apple ID Token, sending to backend...');
        print(' Target Endpoint: $appleAuthEndpoint');

        try {
          final Map<String, dynamic> requestBody = {
            "email": email,
            "name": name.isEmpty ? "Apple User" : name,
            "avatarUrl": "",
            "authId": appleCredential.userIdentifier ?? "",
          };

          final response = await http.post(
            Uri.parse(appleAuthEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestBody),
          );

          print(' Backend Response Status: ${response.statusCode}');
          print(' Backend Response Body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            print("✅ Backend Login Success: $data");

            if (data['data'] != null) {
              final accessToken = data['data']['accessToken'];
              final refreshToken = data['data']['refreshToken'];
              final email = data['data']['email'];

              print(' Saving Tokens to SharedPreferences...');
              await SharedPreferencesHelper.saveAccessToken(accessToken);
              await SharedPreferencesHelper.saveRefreshToken(refreshToken);
              if (email != null) {
                await SharedPreferencesHelper.saveEmail(email);
              }
            }

            isLoading.value = false;
            return true;
          } else {
            print("❌ Backend Login Failed with status: ${response.statusCode}");
            isLoading.value = false;
            return false;
          }
        } catch (e) {
          print("❌ Error sending token to backend: $e");
          isLoading.value = false;
          return false;
        }
      } else {
        print('❌ identityToken is NULL');
      }

      isLoading.value = false;
      return false;
    } catch (e) {
      print(' Error during Apple Sign In: $e');
      isLoading.value = false;
      Get.snackbar(
        'Sign In Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
