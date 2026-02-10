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

  Future<List<AzkarModel>> fetchAzkar() async {
    final url = Uri.parse(azkarEndpoint);
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
          return data.map((e) => AzkarModel.fromJson(e)).toList();
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

  Future<List<AzkarModel>> fetchAzkarByGroup(String time) async {
    final url = Uri.parse('$azkarGroupEndpoint/$time');
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
          return data.map((e) => AzkarModel.fromJson(e)).toList();
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
}
