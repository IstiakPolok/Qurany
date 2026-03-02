class AzkarGroupModel {
  final String id;
  final String name;
  final String time;
  final String duration;
  final String? image;
  final List<AzkarItem> items;
  final String createdAt;
  final String updatedAt;

  AzkarGroupModel({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    this.image,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AzkarGroupModel.fromJson(Map<String, dynamic> json) {
    return AzkarGroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      image: json['image'],
      items:
          (json['azkar'] as List<dynamic>?)
              ?.map((e) => AzkarItem.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'duration': duration,
      'image': image,
      'azkar': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class AzkarItem {
  final String id;
  final String name;
  final String azkar;
  final String translation;
  final String? audio;
  final String azkarGroupId;
  final String time;
  final String createdAt;
  final String updatedAt;

  AzkarItem({
    required this.id,
    required this.name,
    required this.azkar,
    required this.translation,
    this.audio,
    required this.azkarGroupId,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    return AzkarItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      azkar: json['azkar'] ?? '',
      translation: json['translation'] ?? '',
      audio: json['audio'],
      azkarGroupId: json['azkarGroupId'] ?? '',
      time: json['time'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'azkar': azkar,
      'translation': translation,
      'audio': audio,
      'azkarGroupId': azkarGroupId,
      'time': time,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
