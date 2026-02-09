class VerseDetailModel {
  final int surahId;
  final int verseId;
  final String ayate;
  final bool isVerseRead;
  final String text;
  final String translation;
  final String transliteration;
  final Map<String, AudioDetailModel> audio;

  VerseDetailModel({
    required this.surahId,
    required this.verseId,
    required this.ayate,
    required this.isVerseRead,
    required this.text,
    required this.translation,
    required this.transliteration,
    required this.audio,
  });

  factory VerseDetailModel.fromJson(Map<String, dynamic> json) {
    Map<String, AudioDetailModel> audioMap = {};
    if (json['audio'] != null && json['audio'] is Map) {
      (json['audio'] as Map<String, dynamic>).forEach((key, value) {
        audioMap[key] = AudioDetailModel.fromJson(value);
      });
    }

    return VerseDetailModel(
      surahId: json['surahId'] ?? 0,
      verseId: json['verseId'] ?? 0,
      ayate: json['ayate'] ?? '',
      isVerseRead: json['isRead'] ?? false,
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
      transliteration: json['transliteration'] ?? '',
      audio: audioMap,
    );
  }

  VerseDetailModel copyWith({bool? isVerseRead}) {
    return VerseDetailModel(
      surahId: surahId,
      verseId: verseId,
      ayate: ayate,
      isVerseRead: isVerseRead ?? this.isVerseRead,
      text: text,
      translation: translation,
      transliteration: transliteration,
      audio: audio,
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
  final AudioDetailModel? audio;
  final int surahId;
  final List<VerseDetailModel> verses;

  SurahDetailResponse({
    this.audio,
    required this.surahId,
    required this.verses,
  });

  factory SurahDetailResponse.fromJson(Map<String, dynamic> json) {
    // This factory might need to be adjusted or used differently
    // since the new API response is a List, not an object with 'verses'
    return SurahDetailResponse(
      audio: json['audio'] != null
          ? AudioDetailModel.fromJson(json['audio'])
          : null,
      surahId: json['surahId'] ?? 0,
      verses:
          (json['verses'] as List<dynamic>?)
              ?.map((v) => VerseDetailModel.fromJson(v ?? {}))
              .toList() ??
          [],
    );
  }

  // Helper to create from List for the new API
  factory SurahDetailResponse.fromList(List<dynamic> list) {
    final verses = list.map((v) => VerseDetailModel.fromJson(v)).toList();
    final firstVerseSurahId = verses.isNotEmpty ? verses.first.surahId : 0;

    // Attempt to extract a default audio from the first verse if needed,
    // or just leave it null as audio is now granular.
    AudioDetailModel? defaultAudio;
    if (verses.isNotEmpty && verses.first.audio.isNotEmpty) {
      // Example: defaulting to mishary if available, or first available
      if (verses.first.audio.containsKey('mishary')) {
        defaultAudio = verses.first.audio['mishary'];
      } else {
        defaultAudio = verses.first.audio.values.first;
      }
    }

    return SurahDetailResponse(
      surahId: firstVerseSurahId,
      verses: verses,
      audio: defaultAudio,
    );
  }
}
