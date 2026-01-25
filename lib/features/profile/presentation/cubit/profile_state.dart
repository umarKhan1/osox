import 'package:equatable/equatable.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.profilePicUrl,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.posts,
    this.location = '',
    this.isFollowing = false,
    this.isFollower = false,
    this.stories = const [],
  });

  final String userId;
  final String fullName;
  final String bio;
  final String location;
  final String profilePicUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final List<PostModel> posts;
  final bool isFollowing;
  final bool isFollower;
  final List<StoryModel> stories;

  bool get isMutual => isFollowing && isFollower;
  bool get hasStories => stories.isNotEmpty;

  @override
  List<Object?> get props => [
    userId,
    fullName,
    bio,
    location,
    profilePicUrl,
    postsCount,
    followersCount,
    followingCount,
    posts,
    isFollowing,
    isFollower,
    stories,
  ];

  ProfileLoaded copyWith({
    String? userId,
    String? fullName,
    String? bio,
    String? location,
    String? profilePicUrl,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    List<PostModel>? posts,
    bool? isFollowing,
    bool? isFollower,
    List<StoryModel>? stories,
  }) {
    return ProfileLoaded(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      posts: posts ?? this.posts,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      stories: stories ?? this.stories,
    );
  }
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
