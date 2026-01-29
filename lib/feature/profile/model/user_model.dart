class UserModel {
  final String id;
  final String authId;
  final String email;
  final String role;
  final String type;
  final String lang;
  final String status;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? location;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.authId,
    required this.email,
    required this.role,
    required this.type,
    required this.lang,
    required this.status,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.location,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      authId: json['authId'],
      email: json['email'],
      role: json['role'],
      type: json['type'],
      lang: json['lang'],
      status: json['status'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'],
      location: json['location'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? 'User';
  }

  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '${firstName![0]}${lastName![0]}'.toUpperCase();
      }
      return firstName![0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }
}
