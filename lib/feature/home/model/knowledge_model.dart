class KnowledgeSection {
  final String id;
  final int serial;
  final String title;
  final String description;

  KnowledgeSection({
    required this.id,
    required this.serial,
    required this.title,
    required this.description,
  });

  factory KnowledgeSection.fromJson(Map<String, dynamic> json) {
    return KnowledgeSection(
      id: json['id']?.toString() ?? '',
      serial: json['serial'] is int
          ? json['serial']
          : int.tryParse(json['serial']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class KnowledgeModel {
  final String id;
  final String image;
  final String image1;
  final String image2;
  final String name;
  final String description;
  final String quickFact;
  final List<KnowledgeSection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeModel({
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

  factory KnowledgeModel.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List?;
    return KnowledgeModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      image1: json['image1'] ?? '',
      image2: json['image2'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quickFact: json['quick_fact'] ?? '',
      sections: sectionsList != null
          ? sectionsList.map((e) => KnowledgeSection.fromJson(e)).toList()
          : [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
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
