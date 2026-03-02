import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qurany/core/network_caller/endpoints.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/model/surah_model.dart';
import 'package:qurany/feature/home/model/random_verse_model.dart';
import 'package:qurany/feature/home/model/azkar_model.dart';
import 'package:qurany/feature/home/model/history_model.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/model/tafsir_model.dart';
import 'package:qurany/feature/quran/model/bookmarked_verse_model.dart';
import 'package:qurany/feature/profile/model/note_list_item.dart';
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

class TafsirResponse {
  final List<TafsirModel> tafsirs;
  final int total;
  final int page;
  final int limit;

  TafsirResponse({
    required this.tafsirs,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class ApiActionResult {
  final bool success;
  final String message;

  ApiActionResult({required this.success, required this.message});
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
    int limit = 6,
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
          final List<dynamic> data = body['data'] ?? [];
          return SurahDetailResponse.fromList(data);
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
        print('========================================');
        print('🔹 Fetching random verse from: $url');
        print('🔹 Token: $token');
        print('🔹 Token length: ${token?.length ?? 0}');
      }
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('🔹 Response status: ${response.statusCode}');
        print('🔹 Response body: ${response.body}');
        print('========================================');
      }

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
        print('❌ Error fetching random verse: $e');
      }
      rethrow;
    }
  }

  Future<String> fetchAiVerseReflection({
    required int surahId,
    required int verseId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/auth/quran/random/verse/ai/$surahId/$verseId',
    );
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('========================================');
        print('🔹 Fetching AI verse reflection from: $url');
        print('🔹 Token length: ${token?.length ?? 0}');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('🔹 AI reflection status: ${response.statusCode}');
        print('🔹 AI reflection body: ${response.body}');
        print('========================================');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load reflection: ${response.statusCode}');
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to load reflection');
      }

      final data = body['data'];
      if (data is String) {
        return data;
      }

      throw Exception('Invalid reflection payload');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching AI reflection: $e');
      }
      rethrow;
    }
  }

  Future<TafsirResponse> fetchTafsir(
    int surahId, {
    int page = 1,
    int limit = 6,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/quran/tafsir/$surahId?page=$page&limit=$limit',
    );
    try {
      if (kDebugMode) {
        print('Fetching tafsir for surah $surahId from: $url');
      }
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final meta = body['meta'] as Map<String, dynamic>?;
          return TafsirResponse(
            tafsirs: data.map((e) => TafsirModel.fromJson(e)).toList(),
            total: meta?['total'] ?? 0,
            page: meta?['page'] ?? 1,
            limit: meta?['limit'] ?? 5,
          );
        } else {
          throw Exception(body['message'] ?? 'Failed to load tafsir');
        }
      } else {
        throw Exception('Failed to load tafsir: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tafsir: $e');
      }
      rethrow;
    }
  }

  Future<List<JuzModel>> fetchJuz() async {
    final url = Uri.parse('$baseUrl/api/auth/quran/juz');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching Juz from: $url');
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
          return data
              .map((e) => JuzModel.fromJson(e))
              .where((juz) => juz.surahs.isNotEmpty) // Filter out empty Juz
              .toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load Juz');
        }
      } else {
        throw Exception('Failed to load Juz: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Juz: $e');
      }
      rethrow;
    }
  }

  Future<List<SurahModel>> fetchBookmarkedSurahs() async {
    final url = Uri.parse('$baseUrl/api/auth/bookmark/surah/');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching bookmarked surahs from: $url');
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
        if (kDebugMode) {
          print('Raw response body: ${response.body}');
        }
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed body: $body');
          print('Success: ${body['success']}');
        }
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          if (kDebugMode) {
            print('Data list length: ${data.length}');
            print(
              'First item if exists: ${data.isNotEmpty ? data[0] : "empty"}',
            );
          }
          final surahs = data.map((e) {
            if (kDebugMode) {
              print('Parsing surah item: $e');
            }
            return SurahModel.fromJson(e);
          }).toList();
          if (kDebugMode) {
            print('Parsed ${surahs.length} bookmarked surahs');
          }
          return surahs;
        } else {
          throw Exception(
            body['message'] ?? 'Failed to load bookmarked surahs',
          );
        }
      } else {
        throw Exception(
          'Failed to load bookmarked surahs: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bookmarked surahs: $e');
      }
      rethrow;
    }
  }

  Future<bool> toggleBookmarkSurah(int surahId) async {
    final url = Uri.parse('$baseUrl/api/auth/bookmark/surah/$surahId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Toggling bookmark for surah $surahId at: $url');
      }
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Toggle bookmark response status: ${response.statusCode}');
        print('Toggle bookmark response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling bookmark: $e');
      }
      return false;
    }
  }

  Future<List<BookmarkedVerseModel>> fetchBookmarkedVerses() async {
    final url = Uri.parse('$baseUrl/api/auth/bookmark/verse');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('Fetching bookmarked verses from: $url');
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
        if (kDebugMode) {
          print('Raw response body: ${response.body}');
        }
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed body: $body');
          print('Success: ${body['success']}');
        }
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          if (kDebugMode) {
            print('Data list length: ${data.length}');
          }
          final verses = data.map((e) {
            if (kDebugMode) {
              print('Parsing verse item: $e');
            }
            return BookmarkedVerseModel.fromJson(e);
          }).toList();
          if (kDebugMode) {
            print('Parsed ${verses.length} bookmarked verses');
          }
          return verses;
        } else {
          throw Exception(
            body['message'] ?? 'Failed to load bookmarked verses',
          );
        }
      } else {
        throw Exception(
          'Failed to load bookmarked verses: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bookmarked verses: $e');
      }
      rethrow;
    }
  }

  Future<bool> deleteBookmarkedVerse(int surahId, int verseId) async {
    final url = Uri.parse('$baseUrl/api/auth/bookmark/verse/$surahId/$verseId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print(
          'Deleting bookmarked verse $verseId from surah $surahId at: $url',
        );
      }
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print(
          'Delete bookmarked verse response status: ${response.statusCode}',
        );
        print('Delete bookmarked verse response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting bookmarked verse: $e');
      }
      return false;
    }
  }

  Future<bool> toggleBookmarkVerse(int surahId, int verseId) async {
    final url = Uri.parse('$baseUrl/api/auth/bookmark/verse/$surahId/$verseId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print(
          'Toggling bookmark for verse $verseId in surah $surahId at: $url',
        );
      }
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Toggle bookmark verse response status: ${response.statusCode}');
        print('Toggle bookmark verse response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling bookmark verse: $e');
      }
      return false;
    }
  }

  Future<List<AzkarGroupModel>> fetchAzkar() async {
    final url = Uri.parse(azkarGroupEndpoint);
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((e) => AzkarGroupModel.fromJson(e)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load azkar');
        }
      } else {
        throw Exception('Failed to load azkar: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AzkarItem>> fetchAzkarByGroup(String time) async {
    final url = Uri.parse('$azkarGroupEndpoint');
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final groups = data.map((e) => AzkarGroupModel.fromJson(e)).toList();
          final matchingGroup = groups.firstWhere(
            (g) => g.time == time || g.name == time,
            orElse: () => groups.first,
          );
          return matchingGroup.items;
        } else {
          throw Exception(body['message'] ?? 'Failed to load azkar group');
        }
      } else {
        throw Exception('Failed to load azkar group: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiActionResult> bookmarkAzkarGroup(String azkarGroupId) async {
    final url = Uri.parse('$baseUrl/api/auth/azkar/bookmark/$azkarGroupId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Bookmark azkar group status: ${response.statusCode}');
        print('Bookmark azkar group body: ${response.body}');
      }

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {}

      final message = (body?['message'] ?? '').toString();
      final normalizedMessage = message.toLowerCase();
      final apiSuccess = body?['success'] == true;
      final alreadyExists = normalizedMessage.contains('already exists');

      return ApiActionResult(
        success: apiSuccess || alreadyExists,
        message: message.isNotEmpty
            ? message
            : 'Failed to bookmark (status: ${response.statusCode})',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error bookmarking azkar group: $e');
      }
      return ApiActionResult(success: false, message: 'Failed to bookmark: $e');
    }
  }

  Future<List<String>> fetchAzkarBookmarkedGroupIds() async {
    final url = Uri.parse('$baseUrl/api/auth/azkar/bookmark');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Fetch azkar bookmarks status: ${response.statusCode}');
        print('Fetch azkar bookmarks body: ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch bookmarks: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid bookmarks payload');
      }

      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to fetch bookmarks');
      }

      final data = decoded['data'];
      if (data is! List) {
        return const <String>[];
      }

      return data
          .map((e) {
            if (e is Map<String, dynamic>) {
              return (e['azkarGroupId'] ?? '').toString();
            }
            return '';
          })
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching azkar bookmarks: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, String>> fetchAzkarBookmarkedGroupIdToBookmarkId() async {
    final url = Uri.parse('$baseUrl/api/auth/azkar/bookmark');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Fetch azkar bookmarks(map) status: ${response.statusCode}');
        print('Fetch azkar bookmarks(map) body: ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch bookmarks: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid bookmarks payload');
      }
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to fetch bookmarks');
      }

      final data = decoded['data'];
      if (data is! List) {
        return const <String, String>{};
      }

      final Map<String, String> result = {};
      for (final entry in data) {
        if (entry is! Map<String, dynamic>) continue;
        final groupId = (entry['azkarGroupId'] ?? '').toString();
        final bookmarkId = (entry['id'] ?? '').toString();
        if (groupId.isNotEmpty && bookmarkId.isNotEmpty) {
          result[groupId] = bookmarkId;
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching azkar bookmarks(map): $e');
      }
      rethrow;
    }
  }

  Future<ApiActionResult> deleteAzkarBookmark(String bookmarkId) async {
    final url = Uri.parse('$baseUrl/api/auth/azkar/bookmark/$bookmarkId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Delete azkar bookmark status: ${response.statusCode}');
        print('Delete azkar bookmark body: ${response.body}');
      }

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {}

      final message = (body?['message'] ?? '').toString();
      final apiSuccess = body?['success'] == true;

      return ApiActionResult(
        success: apiSuccess,
        message: message.isNotEmpty
            ? message
            : (apiSuccess
                  ? 'Removed from bookmark'
                  : 'Failed to remove bookmark (status: ${response.statusCode})'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting azkar bookmark: $e');
      }
      return ApiActionResult(success: false, message: 'Failed to remove: $e');
    }
  }

  Future<List<HistoryModel>> fetchHistory() async {
    final url = Uri.parse(historyEndpoint);
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((e) => HistoryModel.fromJson(e)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load history');
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> bookmarkHistory(String historyId) async {
    final url = Uri.parse('$baseUrl/api/auth/history/bookmark/$historyId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (kDebugMode) {
        print('Bookmark history status: ${response.statusCode}');
        print('Bookmark history body: ${response.body}');
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Error bookmarking history: $e');
      return false;
    }
  }

  Future<bool> toggleVerseProgress(int surahId, int verseId) async {
    final url = Uri.parse('$verseProgressEndpoint/$surahId/$verseId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        print('Progress toggle response: $body');
        return body['success'] == true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling verse progress: $e');
      }
    }
    return false;
  }

  Future<Map<int, int>> fetchSurahProgress() async {
    final url = Uri.parse(surahProgressEndpoint);
    final maxRetries = 2; // Maximum number of retries
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final token = await SharedPreferencesHelper.getAccessToken();
        if (kDebugMode) {
          print('========================================');
          print('🔹 Fetching surah progress from: $url');
          print('🔹 Token: $token');
          print('🔹 Token length: ${token?.length ?? 0}');
        }
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (kDebugMode) {
          print('🔹 Progress response status: ${response.statusCode}');
          print('🔹 Progress response body: ${response.body}');
          print('========================================');
        }

        // If the request is successful, process the response
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body['success'] == true) {
            final List<dynamic> data = body['data'];
            final Map<int, int> progressMap = {};
            // Process data and map surahId to readCount
            for (var item in data) {
              final int surahId = int.tryParse(item['surahId'].toString()) ?? 0;
              final int readCount = int.tryParse(item['Read'].toString()) ?? 0;
              if (kDebugMode) {
                print('Mapping surahId $surahId to readCount $readCount');
              }
              if (surahId > 0) {
                progressMap[surahId] = readCount;
              }
            }

            if (kDebugMode) {
              print('Final progressMap: $progressMap');
            }
            return progressMap; // Return the progress map
          } else {
            throw Exception(body['message'] ?? 'Failed to load progress');
          }
        } else {
          throw Exception('Failed to load progress: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount > maxRetries) {
          if (kDebugMode) {
            print('❌ Error fetching surah progress: $e');
          }
          return {}; // Return empty map after max retries
        }
        // Retry with a delay before the next attempt
        if (kDebugMode) {
          print('Retrying... attempt $retryCount');
        }
        await Future.delayed(Duration(seconds: 2)); // Delay before retrying
      }
    }
    return {}; // Return empty map if retries fail
  }

  Future<List<NoteListItem>> fetchNotes() async {
    final url = Uri.parse(noteEndpoint);
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('========================================');
        print('🔹 Fetching notes from: $url');
        print('🔹 Token length: ${token?.length ?? 0}');
      }
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (kDebugMode) {
        print('🔹 fetchNotes status: ${response.statusCode}');
        print('🔹 fetchNotes body: ${response.body}');
        print('========================================');
      }
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final data = body['data'] as List<dynamic>;
          return data
              .map((e) => NoteListItem.fromJson(e as Map<String, dynamic>))
              .where((n) => !n.isDeleted)
              .toList();
        }
        throw Exception(body['message'] ?? 'Failed to fetch notes');
      }
      throw Exception('Failed to fetch notes: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ fetchNotes error: $e');
      rethrow;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    final url = Uri.parse('$baseUrl/api/auth/note/$noteId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (kDebugMode) {
        print('========================================');
        print('🔹 Deleting note: $noteId');
        print('🔹 Token length: ${token?.length ?? 0}');
      }
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (kDebugMode) {
        print('🔹 deleteNote response status: ${response.statusCode}');
        print('🔹 deleteNote response body: ${response.body}');
        print('========================================');
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('❌ deleteNote error: $e');
      return false;
    }
  }

  Future<String?> createNote({
    required String description,
    required int surahId,
    required int verseId,
    required int id,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/note');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final requestBody = {
        'description': description,
        'surahId': surahId,
        'verseId': verseId,
        'verse': id,
      };
      if (kDebugMode) {
        print('========================================');
        print('🔹 Creating note at: $url');
        print('🔹 id: $id | surahId: $surahId | verseId: $verseId');
        print('🔹 description: $description');
        print('🔹 Token length: ${token?.length ?? 0}');
        print('🔹 Request body: ${jsonEncode(requestBody)}');
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (kDebugMode) {
        print('🔹 createNote response status: ${response.statusCode}');
        print('🔹 createNote response body: ${response.body}');
        print('========================================');
      }
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message'] as String? ?? 'Note created successfully';
      }
      // Note already exists → update it instead
      if (response.statusCode == 400 &&
          (data['message'] as String? ?? '').contains('already exists')) {
        final existingId = data['data']?['id'] as String?;
        if (existingId != null) {
          if (kDebugMode) {
            print(
              '🔄 Note already exists (id: $existingId) — switching to updateNote',
            );
          }
          final updated = await updateNote(
            noteId: existingId,
            description: description,
            surahId: surahId,
            verseId: verseId,
          );
          return updated ? 'Note updated successfully' : null;
        }
      }
      if (kDebugMode) {
        print('❌ createNote failed: ${data['message']}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ createNote error: $e');
      }
      return null;
    }
  }

  Future<bool> updateNote({
    required String noteId,
    required String description,
    required int surahId,
    required int verseId,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/note/$noteId');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final requestBody = {
        'description': description,
        'surahId': surahId,
        'verseId': verseId,
      };
      if (kDebugMode) {
        print('========================================');
        print('🔹 Updating note at: $url');
        print('🔹 noteId: $noteId | surahId: $surahId | verseId: $verseId');
        print('🔹 description: $description');
        print('🔹 Token length: ${token?.length ?? 0}');
        print('🔹 Request body: ${jsonEncode(requestBody)}');
      }
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (kDebugMode) {
        print('🔹 updateNote response status: ${response.statusCode}');
        print('🔹 updateNote response body: ${response.body}');
        print('========================================');
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      if (kDebugMode) {
        final data = jsonDecode(response.body);
        print('❌ updateNote failed: ${data["message"]}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ updateNote error: $e');
      return false;
    }
  }
}
