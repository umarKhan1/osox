class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}
