import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hijri_special_day_model.dart';
import 'dart:developer' as developer;

class IslamicMiscService {
  static const String _baseUrl = 'https://api.ayahlight.co.uk/api/v1/misc';

  Future<List<HijriSpecialDayModel>> getHijriSpecialDays(int hijriYear) async {
    try {
      final uri = Uri.parse('$_baseUrl/all-hijri-special-days/').replace(
        queryParameters: {'hijri_year': hijriYear.toString()},
      );

      developer.log('Fetching Hijri special days from: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      developer.log('Hijri Special Days API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => HijriSpecialDayModel.fromJson(item)).toList();
      } else {
        developer.log('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      developer.log('Error fetching Hijri special days: $e');
      return [];
    }
  }
}
