class VerseDetailModel {
  final int surahId;
  final int verseId;
  final String ayate;
  final bool isVerseRead;
  final String text;
  final String translation;

  VerseDetailModel({
    required this.surahId,
    required this.verseId,
    required this.ayate,
    required this.isVerseRead,
    required this.text,
    required this.translation,
  });

  factory VerseDetailModel.fromJson(Map<String, dynamic> json) {
    return VerseDetailModel(
      surahId: json['surahId'] ?? 0,
      verseId: json['verseId'] ?? 0,
      ayate: json['ayate'] ?? '',
      isVerseRead: json['isVerseRead'] ?? false,
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}

class AudioDetailModel {
  final String reciter;
  final String url;
  final String originalUrl;
  final String type;

  AudioDetailModel({
    required this.reciter,
    required this.url,
    required this.originalUrl,
    required this.type,
  });

  factory AudioDetailModel.fromJson(Map<String, dynamic> json) {
    return AudioDetailModel(
      reciter: json['reciter'] ?? '',
      url: json['url'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class SurahDetailResponse {
  final AudioDetailModel audio;
  final int surahId;
  final List<VerseDetailModel> verses;

  SurahDetailResponse({
    required this.audio,
    required this.surahId,
    required this.verses,
  });

  factory SurahDetailResponse.fromJson(Map<String, dynamic> json) {
    return SurahDetailResponse(
      audio: AudioDetailModel.fromJson(json['audio']),
      surahId: json['surahId'] ?? 0,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => VerseDetailModel.fromJson(v))
          .toList(),
    );
  }
}
