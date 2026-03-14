import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class GuestAuthService {
  static final RxBool isLoading = false.obs;

  /// Sign in as a guest
  static Future<bool> signInAsGuest() async {
    try {
      isLoading.value = true;

      print('✅ Initiating Guest Login...');

      final response = await http.post(
        Uri.parse(guestLoginEndpoint),
        headers: {"Content-Type": "application/json"},
      );

      print('Guest Login Response Status: ${response.statusCode}');
      print('Guest Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          final accessToken = userData['accessToken'];
          final refreshToken = userData['refreshToken'];
          final email = userData['email'];

          // Save tokens and email to SharedPreferences
          await SharedPreferencesHelper.saveAccessToken(accessToken);
          await SharedPreferencesHelper.saveRefreshToken(refreshToken);
          await SharedPreferencesHelper.saveEmail(email);
          
          print('✅ Guest Login Success and Tokens Saved');
          isLoading.value = false;
          return true;
        } else {
          print('❌ Guest Login Failed: ${data['message']}');
        }
      } else {
        print('❌ Guest Login Server Error: ${response.statusCode}');
      }

      isLoading.value = false;
      return false;
    } catch (e) {
      print('❌ Guest Login Error: $e');
      isLoading.value = false;
      Get.snackbar(
        'Guest Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
