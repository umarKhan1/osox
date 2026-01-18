import 'package:equatable/equatable.dart';
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
    required this.username,
    required this.fullName,
    required this.bio,
    required this.profilePicUrl,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.posts,
  });

  final String username;
  final String fullName;
  final String bio;
  final String profilePicUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final List<PostModel> posts;

  @override
  List<Object?> get props => [
    username,
    fullName,
    bio,
    profilePicUrl,
    postsCount,
    followersCount,
    followingCount,
    posts,
  ];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
