class SurahModel {
  final int number;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int totalVerses;
  final int revealedVerses; // For progress simulation

  const SurahModel({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.totalVerses,
    required this.revealedVerses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['surahId'] ?? 0,
      englishName: json['transliteration'] ?? '',
      arabicName: json['name'] ?? '',
      revelationType: (json['type'] as String? ?? '').toUpperCase(),
      totalVerses: json['total_verses'] ?? 0,
      revealedVerses: json['total_verses_read'] ?? 0,
    );
  }

  static List<SurahModel> get sampleSurahs => [
    SurahModel(
      number: 1,
      englishName: "Al-Fatihah",
      arabicName: "الفاتحة",
      revelationType: "MECCAN",
      totalVerses: 7,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 2,
      englishName: "Al-Baqarah",
      arabicName: "البقرة",
      revelationType: "MEDINAN",
      totalVerses: 286,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 3,
      englishName: "Ali 'Imran",
      arabicName: "آل عمران",
      revelationType: "MEDINAN",
      totalVerses: 200,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 4,
      englishName: "An-Nisa",
      arabicName: "النساء",
      revelationType: "MEDINAN",
      totalVerses: 176,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 5,
      englishName: "Al-Ma'idah",
      arabicName: "المائدة",
      revelationType: "MEDINAN",
      totalVerses: 120,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 6,
      englishName: "Al-An'am",
      arabicName: "الأنعام",
      revelationType: "MECCAN",
      totalVerses: 165,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 7,
      englishName: "Al-A'raf",
      arabicName: "الأعراف",
      revelationType: "MECCAN",
      totalVerses: 206,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 8,
      englishName: "Al-Anfal",
      arabicName: "الأنفال",
      revelationType: "MEDINAN",
      totalVerses: 75,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 9,
      englishName: "At-Tawbah",
      arabicName: "التوبة",
      revelationType: "MEDINAN",
      totalVerses: 129,
      revealedVerses: 0,
    ),
    SurahModel(
      number: 10,
      englishName: "Yunus",
      arabicName: "يونس",
      revelationType: "MECCAN",
      totalVerses: 109,
      revealedVerses: 0,
    ),
  ];
}

class JuzModel {
  final int number;
  final List<JuzSurahModel> surahs;

  const JuzModel({required this.number, required this.surahs});

  static List<JuzModel> get sampleJuz => [
    JuzModel(
      number: 1,
      surahs: [
        JuzSurahModel(
          number: 1,
          englishName: "Al-Fatihah",
          arabicName: "الفاتحة",
          revelationType: "MECCAN",
          versesRange: "7 VERSES",
        ),
        JuzSurahModel(
          number: 2,
          englishName: "Al-Baqarah",
          arabicName: "البقرة",
          revelationType: "MEDINIAN",
          versesRange: "1 - 141 VERSES",
        ),
      ],
    ),
    JuzModel(
      number: 2,
      surahs: [
        JuzSurahModel(
          number: 2,
          englishName: "Al-Baqarah",
          arabicName: "البقرة",
          revelationType: "MEDINIAN",
          versesRange: "142 - 252 VERSES",
        ),
      ],
    ),
    JuzModel(
      number: 3,
      surahs: [
        JuzSurahModel(
          number: 2,
          englishName: "Al-Baqarah",
          arabicName: "البقرة",
          revelationType: "MEDINIAN",
          versesRange: "252 - 286 VERSES",
        ),
      ],
    ),
  ];
}

class JuzSurahModel {
  final int number;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final String versesRange;

  const JuzSurahModel({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.versesRange,
  });
}
