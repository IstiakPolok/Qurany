class NoteListItem {
  final String id;
  final String title;
  final String description;
  final int surahId;
  final int verseId;
  final bool isFavorite;
  final bool isDeleted;
  final String createdAt;
  final NoteVerseData? verseData;

  NoteListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.surahId,
    required this.verseId,
    required this.isFavorite,
    required this.isDeleted,
    required this.createdAt,
    this.verseData,
  });

  factory NoteListItem.fromJson(Map<String, dynamic> json) {
    return NoteListItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Note',
      description: json['description']?.toString() ?? '',
      surahId: (json['surahId'] as int?) ?? 0,
      verseId: (json['verseId'] as int?) ?? 0,
      isFavorite: json['isFavorite'] == true,
      isDeleted: json['isDeleted'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      verseData: json['verseData'] != null
          ? NoteVerseData.fromJson(json['verseData'] as Map<String, dynamic>)
          : null,
    );
  }

  String get formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Created ${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class NoteVerseData {
  final String text;
  final String translation;
  final String transliteration;
  final String ayate;

  NoteVerseData({
    required this.text,
    required this.translation,
    required this.transliteration,
    required this.ayate,
  });

  factory NoteVerseData.fromJson(Map<String, dynamic> json) {
    return NoteVerseData(
      text: json['text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
      transliteration: json['transliteration']?.toString() ?? '',
      ayate: json['ayate']?.toString() ?? '',
    );
  }
}
