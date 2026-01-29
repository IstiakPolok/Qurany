import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/prayer_time_model.dart';

class PrayerService {
  static const String _baseUrl = 'https://islamicapi.com/api/v1';
  // Islamic API is free to use, so we don't need an API key for basic usage

  // Default prayer calculation method (Muslim World League)
  static const int _defaultMethod = 3;
  static const int _defaultSchool = 1; // Shafi
  static const String _defaultCalendar = 'UAQ';

  Future<PrayerTimeModel?> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date, // Added date parameter
    int method = _defaultMethod,
    int school = _defaultSchool,
    String calendar = _defaultCalendar,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'method': method.toString(),
        'school': school.toString(),
        'calender': calendar,
        'api_key': 'UKJeeyx8saSEziuhNKjpVw7DaPK8zzJ2TQNyghA4FwYDI31K',
      };

      if (date != null) {
        queryParams['date'] =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      final uri = Uri.parse(
        '$_baseUrl/prayer-time/',
      ).replace(queryParameters: queryParams);

      print('Fetching prayer times from: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Prayer API Response Status: ${response.statusCode}');
      print('Prayer API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['code'] == 200 && jsonData['status'] == 'success') {
          return PrayerTimeModel.fromJson(jsonData);
        } else {
          print('API Error: ${jsonData['message']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      return null;
    }
  }

  // Helper method to get method name from number
  static String getMethodName(int method) {
    switch (method) {
      case 1:
        return 'University of Islamic Sciences, Karachi';
      case 2:
        return 'Islamic Society of North America';
      case 3:
        return 'Muslim World League';
      case 4:
        return 'Umm Al-Qura University, Makkah';
      case 5:
        return 'Egyptian General Authority of Survey';
      case 7:
        return 'Institute of Geophysics, Tehran';
      case 8:
        return 'Gulf Region';
      case 9:
        return 'Kuwait';
      case 10:
        return 'Qatar';
      case 11:
        return 'MUIS, Singapore';
      case 12:
        return 'UOIF, France';
      case 13:
        return 'Diyanet, Turkey';
      case 14:
        return 'Russia';
      case 15:
        return 'Moonsighting Committee Worldwide';
      case 16:
        return 'Dubai (experimental)';
      case 17:
        return 'JAKIM, Malaysia';
      case 18:
        return 'Tunisia';
      case 19:
        return 'Algeria';
      case 20:
        return 'KEMENAG, Indonesia';
      case 21:
        return 'Morocco';
      case 22:
        return 'Lisbon, Portugal';
      case 23:
        return 'Jordan';
      case 0:
        return 'Jafari / Shia Ithna-Ashari';
      default:
        return 'Muslim World League';
    }
  }
}
