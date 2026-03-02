import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class MemorizationService {
  Future<int?> getAverageAccuracy() async {
    final url = Uri.parse(avgAccuracyEndpoint);
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
          return (data['data'] as num).toInt();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching average accuracy: $e');
      return null;
    }
  }

  Future<int?> getCompletedVerses() async {
    final url = Uri.parse(completedVersesEndpoint);
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
          return (data['data'] as num).toInt();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching completed verses: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getCompletedSurahs({
    int page = 1,
    int limit = 3,
  }) async {
    final url = Uri.parse('$completedSurahEndpoint?page=$page&limit=$limit');
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
          return data['data'] as List<dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching completed surahs: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPronunciation({
    required int surahId,
    required int verseId,
    required String audioPath,
  }) async {
    final url = Uri.parse('$recitationCheckEndpoint/$surahId/$verseId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else {
        print('Error response: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error checking pronunciation: $e');
      return null;
    }
  }
}
