class SurahModel {
  final int number;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int totalVerses;
  final int revealedVerses; // For progress simulation
  final String translation;

  const SurahModel({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.totalVerses,
    required this.revealedVerses,
    this.translation = '',
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: _parseInt(json['id']) ?? _parseInt(json['surahId']) ?? 0,
      englishName: json['transliteration'] ?? '',
      arabicName: json['name'] ?? '',
      revelationType: (json['type'] as String? ?? '').toUpperCase(),
      totalVerses: _parseInt(json['total_verses']) ?? 0,
      revealedVerses: _parseInt(json['total_verses_read']) ?? 0,
      translation: json['translation'] ?? '',
    );
  }

  // Helper method to parse int from dynamic (handles both int and String)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class JuzModel {
  final int number;
  final List<JuzSurahModel> surahs;

  const JuzModel({required this.number, required this.surahs});

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return JuzModel(
      number: json['juzId'] ?? 0,
      surahs: (json['surahs'] as List<dynamic>? ?? [])
          .map((e) => JuzSurahModel.fromJson(e))
          .toList(),
    );
  }
}

class JuzSurahModel {
  final int number;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final String versesRange;
  final String translation;
  final int totalVerses;
  final int juzId;

  const JuzSurahModel({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.versesRange,
    this.translation = '',
    this.totalVerses = 0,
    this.juzId = 0,
  });

  factory JuzSurahModel.fromJson(Map<String, dynamic> json) {
    int verses = SurahModel._parseInt(json['total_verses']) ?? 0;
    return JuzSurahModel(
      number: SurahModel._parseInt(json['id']) ?? 0,
      englishName: json['transliteration'] ?? '',
      arabicName: json['name'] ?? '',
      revelationType: (json['type'] as String? ?? '').toUpperCase(),
      versesRange: '$verses VERSES',
      translation: json['translation'] ?? '',
      totalVerses: verses,
      juzId: SurahModel._parseInt(json['juzId']) ?? 0,
    );
  }
}
