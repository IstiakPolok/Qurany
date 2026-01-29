class RecentReadingModel {
  final int surahId;
  final String surahName;
  final String arabicName;
  final int lastVerseId;
  final int totalVerses;
  final DateTime lastReadAt;

  RecentReadingModel({
    required this.surahId,
    required this.surahName,
    required this.arabicName,
    required this.lastVerseId,
    required this.totalVerses,
    required this.lastReadAt,
  });

  double get readingPercentage {
    if (totalVerses == 0) return 0.0;
    return (lastVerseId / totalVerses * 100).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'surahId': surahId,
      'surahName': surahName,
      'arabicName': arabicName,
      'lastVerseId': lastVerseId,
      'totalVerses': totalVerses,
      'lastReadAt': lastReadAt.toIso8601String(),
    };
  }

  factory RecentReadingModel.fromJson(Map<String, dynamic> json) {
    return RecentReadingModel(
      surahId: json['surahId'] ?? 0,
      surahName: json['surahName'] ?? '',
      arabicName: json['arabicName'] ?? '',
      lastVerseId: json['lastVerseId'] ?? 0,
      totalVerses: json['totalVerses'] ?? 0,
      lastReadAt: DateTime.parse(
        json['lastReadAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
