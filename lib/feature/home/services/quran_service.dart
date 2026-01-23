import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/model/surah_model.dart';
import 'package:qurany/feature/home/model/random_verse_model.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:flutter/foundation.dart';

class SurahResponse {
  final List<SurahModel> surahs;
  final int total;
  final int page;
  final int limit;

  SurahResponse({
    required this.surahs,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class QuranService {
  Future<SurahResponse> fetchSurahs({int page = 1, int limit = 10}) async {
    final url = Uri.parse(
      '$baseUrl/api/auth/quran/surah?page=$page&limit=$limit',
    );
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching surahs from: $url');
        print('Token: $token');
      }
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final meta = body['meta'] as Map<String, dynamic>?;
          return SurahResponse(
            surahs: data.map((e) => SurahModel.fromJson(e)).toList(),
            total: meta?['total'] ?? 0,
            page: meta?['page'] ?? 1,
            limit: meta?['limit'] ?? 10,
          );
        } else {
          throw Exception(body['message'] ?? 'Failed to load surahs');
        }
      } else {
        throw Exception('Failed to load surahs: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching surahs: $e');
      }
      rethrow;
    }
  }

  Future<SurahDetailResponse> fetchSurahById(
    int surahId, {
    int page = 1,
    int limit = 20,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/auth/quran/surah/$surahId?page=$page&limit=$limit',
    );
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching surah $surahId from: $url');
        print('Token: $token');
      }
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return SurahDetailResponse.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to load surah');
        }
      } else {
        throw Exception('Failed to load surah: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching surah: $e');
      }
      rethrow;
    }
  }

  Future<RandomVerseResponse> fetchRandomVerse() async {
    final url = Uri.parse('$baseUrl/api/auth/quran/random/verse');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching random verse from: $url');
        print('Token: $token');
      }
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return RandomVerseResponse.fromJson(body);
        } else {
          throw Exception(body['message'] ?? 'Failed to load random verse');
        }
      } else {
        throw Exception('Failed to load random verse: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching random verse: $e');
      }
      rethrow;
    }
  }
}
