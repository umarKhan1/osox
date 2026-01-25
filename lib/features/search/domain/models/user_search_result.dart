class UserSearchResult {
  UserSearchResult({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
}
