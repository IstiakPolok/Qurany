class TafsirModel {
  final int surahId;
  final int verseId;
  final String ayate;
  final String verse;
  final String text;

  TafsirModel({
    required this.surahId,
    required this.verseId,
    required this.ayate,
    required this.verse,
    required this.text,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      surahId: json['surahId'] ?? 0,
      verseId: json['verseId'] ?? 0,
      ayate: json['ayate'] ?? '',
      verse: json['verse'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
