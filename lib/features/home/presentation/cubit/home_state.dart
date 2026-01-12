import 'package:equatable/equatable.dart';
import 'package:osox/features/home/domain/models/story_model.dart';

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
  const HomeLoaded({required this.stories});

  final List<UserStoriesModel> stories;

  @override
  List<Object?> get props => [stories];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
