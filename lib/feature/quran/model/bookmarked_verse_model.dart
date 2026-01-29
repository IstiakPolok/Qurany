class BookmarkedVerseModel {
  final String id;
  final String userId;
  final int surahId;
  final String name;
  final int verseId;
  final String ayate;
  final String text;
  final String translation;
  final String? time;
  final String createdAt;
  final String updatedAt;

  BookmarkedVerseModel({
    required this.id,
    required this.userId,
    required this.surahId,
    required this.name,
    required this.verseId,
    required this.ayate,
    required this.text,
    required this.translation,
    this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookmarkedVerseModel.fromJson(Map<String, dynamic> json) {
    return BookmarkedVerseModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      surahId: json['surahId'] ?? 0,
      name: json['name'] ?? '',
      verseId: json['verseId'] ?? 0,
      ayate: json['ayate'] ?? '',
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
      time: json['time'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'surahId': surahId,
      'name': name,
      'verseId': verseId,
      'ayate': ayate,
      'text': text,
      'translation': translation,
      'time': time,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
