import 'package:equatable/equatable.dart';
import 'package:osox/features/home/domain/models/story_model.dart';

import 'package:osox/features/posts/domain/models/post_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.stories,
    required this.posts,
    this.isUploading = false,
  });

  final List<UserStoriesModel> stories;
  final List<PostModel> posts;
  final bool isUploading;

  HomeLoaded copyWith({
    List<UserStoriesModel>? stories,
    List<PostModel>? posts,
    bool? isUploading,
  }) {
    return HomeLoaded(
      stories: stories ?? this.stories,
      posts: posts ?? this.posts,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [stories, posts, isUploading];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
