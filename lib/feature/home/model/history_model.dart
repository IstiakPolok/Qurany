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
