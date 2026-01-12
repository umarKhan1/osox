import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.profileUrl,
  });

  final String id;
  final String name;
  final String profileUrl;

  @override
  List<Object?> get props => [id, name, profileUrl];
}

enum StoryType { image, video }

class StoryModel extends Equatable {
  const StoryModel({
    required this.id,
    required this.contentUrl,
    required this.type,
    this.duration = const Duration(seconds: 5),
    this.isLive = false,
    this.isViewed = false,
    this.viewers = const [],
  });

  final String id;
  final String contentUrl;
  final StoryType type;
  final Duration duration;
  final bool isLive;
  final bool isViewed;
  final List<UserModel> viewers;

  int get viewerCount => viewers.length;

  @override
  List<Object?> get props => [
    id,
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
