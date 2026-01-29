import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import '../model/knowledge_model.dart';

class KnowledgeService {
  final String _baseUrl =
      'https://yearningly-stemlike-shavon.ngrok-free.dev/api/knowledge';

  Future<List<KnowledgeModel>> getKnowledgeItems() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['data'];
          return items.map((item) => KnowledgeModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching knowledge items: $e');
      return [];
    }
  }
}
