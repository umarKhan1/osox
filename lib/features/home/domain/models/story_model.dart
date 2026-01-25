import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.profileUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final name = json['full_name'] as String? ?? 'User';
    return UserModel(
      id: json['id'] as String,
      name: name,
      profileUrl:
          json['profile_url'] as String? ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
    );
  }

  final String id;
  final String name;
  final String profileUrl;

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': name, 'profile_url': profileUrl};
  }

  @override
  List<Object?> get props => [id, name, profileUrl];
}

enum StoryType { image, video }

class StoryModel extends Equatable {
  const StoryModel({
    required this.id,
    required this.userId,
    required this.contentUrl,
    required this.type,
    this.duration = const Duration(seconds: 5),
    this.isLive = false,
    this.isViewed = false,
    this.viewers = const [],
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contentUrl: json['content_url'] as String,
      type: json['type'] == 'video' ? StoryType.video : StoryType.image,
      duration: Duration(seconds: json['duration_seconds'] as int? ?? 5),
    );
  }

  final String id;
  final String userId;
  final String contentUrl;
  final StoryType type;
  final Duration duration;
  final bool isLive;
  final bool isViewed;
  final List<UserModel> viewers;

  int get viewerCount => viewers.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_url': contentUrl,
      'type': type.name,
      'duration_seconds': duration.inSeconds,
      'is_live': isLive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    contentUrl,
    type,
    duration,
    isLive,
    isViewed,
    viewers,
  ];
}

class UserStoriesModel extends Equatable {
  const UserStoriesModel({required this.user, required this.stories});

  final UserModel user;
  final List<StoryModel> stories;

  bool get hasLiveStory => stories.any((s) => s.isLive);
  bool get allViewed => stories.every((s) => s.isViewed);

  @override
  List<Object?> get props => [user, stories];
}
