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
