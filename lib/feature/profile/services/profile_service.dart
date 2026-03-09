import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
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

  Future<UserModel?> uploadAvatar(String filePath) async {
    final url = Uri.parse('$baseUrl/api/user/me');
    final client = http.Client();
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final filename = p.basename(file.path);

      // Determine mime type from extension
      final ext = p.extension(filename).toLowerCase().replaceAll('.', '');
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'gif'
          ? 'image/gif'
          : 'image/jpeg';

      final request = http.MultipartRequest('PATCH', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        })
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ),
        );

      final streamed = await client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      // ignore: avoid_print
      print('[DEBUG] uploadAvatar status: ${response.statusCode}');
      // ignore: avoid_print
      print('[DEBUG] uploadAvatar body: ${response.body}');
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          return UserModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading avatar: $e');
      return null;
    } finally {
      client.close();
    }
  }

  Future<UserModel?> uploadAvatarBytes(List<int> bytes, String filename) async {
    final url = Uri.parse('$baseUrl/api/user/me');
    final client = http.Client();
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final ext = p.extension(filename).toLowerCase().replaceAll('.', '');
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'gif'
          ? 'image/gif'
          : 'image/jpeg';

      final request = http.MultipartRequest('PATCH', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        })
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ),
        );

      final streamed = await client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      // ignore: avoid_print
      print('[DEBUG] uploadAvatarBytes status: ${response.statusCode}');
      // ignore: avoid_print
      print('[DEBUG] uploadAvatarBytes body: ${response.body}');
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          return UserModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading avatar bytes: $e');
      return null;
    } finally {
      client.close();
    }
  }
}
