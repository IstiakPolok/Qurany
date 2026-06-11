class HistorySection {
  final String id;
  final int serial;
  final String title;
  final String description;

  HistorySection({
    required this.id,
    required this.serial,
    required this.title,
    required this.description,
  });

  factory HistorySection.fromJson(Map<String, dynamic> json) {
    return HistorySection(
      id: json['id']?.toString() ?? '',
      serial: json['serial'] is int
          ? json['serial']
          : int.tryParse(json['serial']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class HistoryModel {
  final String id;
  final String image;
  final String image1;
  final String image2;
  final String name;
  final String description;
  final String quickFact;
  final List<HistorySection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryModel({
    required this.id,
    required this.image,
    required this.image1,
    required this.image2,
    required this.name,
    required this.description,
    required this.quickFact,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List?;
    return HistoryModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      image1: json['image1'] ?? '',
      image2: json['image2'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quickFact: json['quick_fact'] ?? '',
      sections: sectionsList != null
          ? sectionsList.map((e) => HistorySection.fromJson(e)).toList()
          : [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class BookmarkedHistoryModel {
  final String bookmarkId;
  final String historyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HistoryModel history;

  BookmarkedHistoryModel({
    required this.bookmarkId,
    required this.historyId,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  factory BookmarkedHistoryModel.fromJson(Map<String, dynamic> json) {
    final historyJson = json['history'];
    return BookmarkedHistoryModel(
      bookmarkId: (json['id'] ?? '').toString(),
      historyId: (json['historyId'] ?? '').toString(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      history: HistoryModel.fromJson(
        historyJson is Map<String, dynamic> ? historyJson : {},
      ),
    );
  }
}
