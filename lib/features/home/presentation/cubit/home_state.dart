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
  const HomeLoaded({required this.stories, required this.posts});

  final List<UserStoriesModel> stories;
  final List<PostModel> posts;

  @override
  List<Object?> get props => [stories, posts];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
