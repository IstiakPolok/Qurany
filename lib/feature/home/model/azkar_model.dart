class AzkarModel {
  final String id;
  final String image;
  final String name;
  final String time;
  final String duration;
  final String azkar;
  final String translation;
  final String createdAt;
  final String updatedAt;

  AzkarModel({
    required this.id,
    required this.image,
    required this.name,
    required this.time,
    required this.duration,
    required this.azkar,
    required this.translation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      azkar: json['azkar'] ?? '',
      translation: json['translation'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'time': time,
      'duration': duration,
      'azkar': azkar,
      'translation': translation,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
