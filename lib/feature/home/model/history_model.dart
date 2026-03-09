class HistoryModel {
  final String id;
  final String image;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryModel({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
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
