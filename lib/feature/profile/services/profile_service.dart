import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import '../model/user_model.dart';

class ProfileService {
  Future<UserModel?> getProfile() async {
    final url = Uri.parse('$baseUrl/api/user/me');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
