class KnowledgeModel {
  final String id;
  final String image;
  final String name;
  final String description;

  KnowledgeModel({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
  });

  factory KnowledgeModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'image': image,
      'title': name,
      'description': description,
    };
  }
}
