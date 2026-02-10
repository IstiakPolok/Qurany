import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class AskAiService {
  Future<Map<String, dynamic>?> sendMessage(String query) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.post(
        Uri.parse(askAiChatEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
